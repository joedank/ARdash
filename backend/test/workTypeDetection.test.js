/**
 * Work Type Detection Service Test
 * 
 * This test file verifies that the work type detection service properly
 * splits condition text into fragments and detects work types in each.
 */

'use strict';

// Mocks
const mockWorkTypeDetectionService = {
  _detectFragment: jest.fn(),
  _combineResults: jest.fn((...args) => args[0]), // Just return first arg for simplicity
  detect: require('../src/services/workTypeDetectionService').detect, // Use the actual detect method
};

// Get constants from the original service for use in tests
const { MIN, HARD_CREATE } = require('../src/services/workTypeDetectionService');

// Test
describe('WorkTypeDetectionService', () => {
  describe('detect method', () => {
    beforeEach(() => {
      jest.clearAllMocks();
      // Setup mock responses for _detectFragment
      mockWorkTypeDetectionService._detectFragment
        .mockImplementation((fragment) => {
          if (fragment.includes('awning')) {
            return [{ workTypeId: 'awning-id', name: 'Awning Install', score: 0.95 }];
          } else if (fragment.includes('cabinet')) {
            return [{ workTypeId: 'cabinet-id', name: 'Cabinet Replacement', score: 0.87 }];
          } else if (fragment.includes('subfloor')) {
            return [{ workTypeId: 'subfloor-id', name: 'Subfloor Repair', score: 0.91 }];
          } else {
            return [];
          }
        });
    });

    it('should return empty array for text shorter than minimum length', async () => {
      const text = 'Too short';
      const result = await mockWorkTypeDetectionService.detect(text);
      expect(result).toEqual([]);
      expect(mockWorkTypeDetectionService._detectFragment).not.toHaveBeenCalled();
    });
    
    it('should split text and call _detectFragment for each part', async () => {
      const text = 'Repair subfloor. Replace cabinets. Install awning.';
      await mockWorkTypeDetectionService.detect(text);
      
      // Should call _detectFragment 3 times, once for each part
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledTimes(3);
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Repair subfloor');
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Replace cabinets');
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Install awning');
    });
    
    it('should combine and deduplicate results from multiple fragments', async () => {
      const text = 'Repair subfloor. Replace cabinets. Install awning.';
      const result = await mockWorkTypeDetectionService.detect(text);
      
      // Should return combined results with 3 distinct work types
      expect(result.length).toBe(3);
      expect(result.map(r => r.workTypeId)).toContain('subfloor-id');
      expect(result.map(r => r.workTypeId)).toContain('cabinet-id');
      expect(result.map(r => r.workTypeId)).toContain('awning-id');
      
      // Results should be sorted by score (highest first)
      expect(result[0].workTypeId).toBe('awning-id'); // 0.95
      expect(result[1].workTypeId).toBe('subfloor-id'); // 0.91
      expect(result[2].workTypeId).toBe('cabinet-id'); // 0.87
    });
    
    it('should handle duplicate work types and keep highest score', async () => {
      // Mock _detectFragment to return the same work type with different scores
      mockWorkTypeDetectionService._detectFragment
        .mockImplementation((fragment) => {
          if (fragment.includes('tile')) {
            return [{ workTypeId: 'tile-id', name: 'Tile Installation', score: 0.95 }];
          } else if (fragment.includes('ceramic')) {
            return [{ workTypeId: 'tile-id', name: 'Tile Installation', score: 0.87 }];
          } else {
            return [];
          }
        });
      
      const text = 'Install ceramic tile. Tile the bathroom floor.';
      const result = await mockWorkTypeDetectionService.detect(text);
      
      // Should only return one tile result with the highest score
      expect(result.length).toBe(1);
      expect(result[0].workTypeId).toBe('tile-id');
      expect(result[0].score).toBe(0.95);
    });
    
    it('should split on multiple delimiters including newlines and "and"', async () => {
      const text = 'Repair subfloor\nReplace cabinets and Install awning;Final touches';
      await mockWorkTypeDetectionService.detect(text);
      
      // Should call _detectFragment 4 times, once for each part
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledTimes(4);
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Repair subfloor');
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Replace cabinets');
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Install awning');
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Final touches');
    });
    
    it('should return up to 10 suggestions', async () => {
      // Create mock that returns multiple different work types
      const mockResults = [];
      for (let i = 1; i <= 15; i++) {
        mockResults.push({
          workTypeId: `type-${i}`,
          name: `Work Type ${i}`,
          score: 1 - (i * 0.02) // Descending scores: 0.98, 0.96, 0.94...
        });
      }
      
      // Make _detectFragment return all 15 work types for any input
      mockWorkTypeDetectionService._detectFragment.mockReturnValue(mockResults);
      
      const text = 'This is a complex project with many work types.';
      const result = await mockWorkTypeDetectionService.detect(text);
      
      // Should limit to 10 suggestions
      expect(result.length).toBe(10);
      
      // Should keep the highest scoring ones
      expect(result[0].workTypeId).toBe('type-1');
      expect(result[9].workTypeId).toBe('type-10');
    });
    
    it('should filter out fragments that are too short', async () => {
      const text = 'Fix roof. OK. Replace windows.';
      await mockWorkTypeDetectionService.detect(text);
      
      // Should only call _detectFragment twice, skipping the "OK" fragment
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledTimes(2);
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Fix roof');
      expect(mockWorkTypeDetectionService._detectFragment).toHaveBeenCalledWith('Replace windows');
    });
    
    it('should handle generic verbs properly', async () => {
      // Override mock implementation to test token handling
      mockWorkTypeDetectionService._detectFragment.mockImplementation((fragment) => {
        // This mock is for testing the token filtering in the detect() method
        // The real token filtering happens in _detectFragment, which we're not testing here
        if (fragment === 'Door replacement') {
          return [{ workTypeId: 'door-id', name: 'Door Replacement', score: 0.90 }];
        } else if (fragment === 'Window install') {
          return [{ workTypeId: 'window-id', name: 'Window Installation', score: 0.85 }];
        } else {
          return [];
        }
      });
      
      const text = 'Door replacement. Window install.';
      const result = await mockWorkTypeDetectionService.detect(text);
      
      // Should return both types
      expect(result.length).toBe(2);
      expect(result.map(r => r.workTypeId)).toContain('door-id');
      expect(result.map(r => r.workTypeId)).toContain('window-id');
    });
    
    it('should include fragments with score < HARD_CREATE in unmatched list', async () => {
      // Override mock implementation to test the HARD_CREATE threshold
      mockWorkTypeDetectionService._detectFragment.mockImplementation((fragment) => {
        if (fragment.includes('Cleaning skylight')) {
          return [{ workTypeId: 'skylight-id', name: 'Skylight Replacement', score: 0.44 }];
        } else if (fragment.includes('Ceramic roofing')) {
          return [{ workTypeId: 'ceramic-id', name: 'Ceramic Roof Installation', score: 0.70 }];
        } else {
          return [];
        }
      });
      
      const text = 'Cleaning skylight. Ceramic roofing tile replacement.';
      const result = await mockWorkTypeDetectionService.detect(text);
      
      // Verify result has the expected structure
      expect(result).toHaveProperty('existing');
      expect(result).toHaveProperty('unmatched');
      
      // Fragment with 0.44 score (< HARD_CREATE 0.60) should appear in both existing and unmatched
      expect(result.existing.some(item => item.workTypeId === 'skylight-id')).toBe(true);
      expect(result.unmatched).toContain('Cleaning skylight');
      
      // Fragment with 0.70 score (>= HARD_CREATE 0.60) should only appear in existing, not in unmatched
      expect(result.existing.some(item => item.workTypeId === 'ceramic-id')).toBe(true);
      expect(result.unmatched).not.toContain('Ceramic roofing tile replacement');
    });
  });
});