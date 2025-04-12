/**
 * Theme Audit Utility
 * 
 * This utility helps identify elements that might be missing proper light mode styling
 * by scanning the DOM for elements with dark: classes but no corresponding light mode styles.
 */

export default class ThemeAudit {
  /**
   * Start the theme audit process
   * @param {boolean} highlightElements - Whether to visually highlight problematic elements
   * @returns {object} - Audit results with counts and problematic elements
   */
  static run(highlightElements = true) {
    console.log('Starting theme audit...');
    
    // Store results
    const results = {
      totalElements: 0,
      potentialIssues: 0,
      elements: []
    };
    
    // Get all elements in the DOM
    const allElements = document.querySelectorAll('*');
    results.totalElements = allElements.length;
    
    // Check each element for dark: classes without light mode alternatives
    allElements.forEach(element => {
      const classAttr = element.getAttribute('class');
      if (!classAttr) return;
      
      const classes = classAttr.split(' ');
      const darkClasses = classes.filter(cls => cls.startsWith('dark:'));
      
      // If element has dark: classes, check for potential issues
      if (darkClasses.length > 0) {
        const potentialIssue = this._checkForLightModeStyles(element, darkClasses);
        
        if (potentialIssue) {
          results.potentialIssues++;
          results.elements.push({
            element: element,
            darkClasses: darkClasses,
            suggestion: potentialIssue.suggestion
          });
          
          // Highlight the element if requested
          if (highlightElements) {
            this._highlightElement(element);
          }
        }
      }
    });
    
    console.log(`Theme audit complete: ${results.potentialIssues} potential issues found out of ${results.totalElements} elements.`);
    console.table(results.elements.map(e => ({
      Element: e.element.tagName,
      DarkClasses: e.darkClasses.join(', '),
      Suggestion: e.suggestion
    })));
    
    return results;
  }
  
  /**
   * Check if an element has proper light mode styles to complement dark: classes
   * @param {Element} element - The DOM element to check
   * @param {string[]} darkClasses - Array of dark: classes found
   * @returns {object|null} - Details about potential issue or null if no issues
   */
  static _checkForLightModeStyles(element, darkClasses) {
    // Common paired classes to check for
    const commonPairs = {
      'dark:bg-gray-900': ['bg-white', 'bg-gray-50', 'bg-gray-100'],
      'dark:bg-gray-800': ['bg-white', 'bg-gray-50', 'bg-gray-100'],
      'dark:bg-gray-700': ['bg-gray-100', 'bg-gray-200', 'bg-gray-300'],
      'dark:text-white': ['text-gray-900', 'text-gray-800', 'text-black'],
      'dark:text-gray-300': ['text-gray-700', 'text-gray-600', 'text-gray-500'],
      'dark:text-gray-400': ['text-gray-600', 'text-gray-500', 'text-gray-400'],
      'dark:border-gray-700': ['border-gray-200', 'border-gray-300', 'border-gray-100']
    };
    
    // Check for missing light mode styles
    for (const darkClass of darkClasses) {
      // Skip dynamic classes or those without common pairs
      if (!commonPairs[darkClass]) continue;
      
      // Get possible light mode classes for this dark mode class
      const possibleLightClasses = commonPairs[darkClass];
      
      // Check if element has any of the possible light mode classes
      const hasLightClass = possibleLightClasses.some(lightClass => 
        element.classList.contains(lightClass)
      );
      
      // If no light mode class found, report issue
      if (!hasLightClass) {
        return {
          darkClass: darkClass,
          suggestion: `Consider adding one of: ${possibleLightClasses.join(', ')}`
        };
      }
    }
    
    return null;
  }
  
  /**
   * Highlight an element with potential theme issues
   * @param {Element} element - The DOM element to highlight
   */
  static _highlightElement(element) {
    // Save original styles
    const originalOutline = element.style.outline;
    const originalPosition = element.style.position;
    
    // Add highlight styles
    element.style.outline = '2px dashed red';
    element.style.position = element.style.position === 'static' ? 'relative' : element.style.position;
    
    // Add a tooltip
    const tooltip = document.createElement('div');
    tooltip.style.position = 'absolute';
    tooltip.style.top = '0';
    tooltip.style.right = '0';
    tooltip.style.backgroundColor = 'red';
    tooltip.style.color = 'white';
    tooltip.style.padding = '2px 5px';
    tooltip.style.fontSize = '10px';
    tooltip.style.borderRadius = '2px';
    tooltip.style.zIndex = '9999';
    tooltip.style.pointerEvents = 'none';
    tooltip.textContent = '⚠️ Theme issue';
    
    element.appendChild(tooltip);
    
    // Remove highlight after 10 seconds
    setTimeout(() => {
      element.style.outline = originalOutline;
      element.style.position = originalPosition;
      if (element.contains(tooltip)) {
        element.removeChild(tooltip);
      }
    }, 10000);
  }
  
  /**
   * Generate a report of theme audit findings
   * @param {object} results - Audit results from run()
   * @returns {string} - HTML report
   */
  static generateReport(results) {
    if (!results || !results.elements) {
      return '<p>No audit results available. Run ThemeAudit.run() first.</p>';
    }
    
    let report = `
      <div style="font-family: sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
        <h2>Theme Audit Report</h2>
        <p>Found ${results.potentialIssues} potential issues out of ${results.totalElements} elements.</p>
        
        <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
          <thead>
            <tr style="background-color: #f2f2f2;">
              <th style="padding: 8px; text-align: left; border: 1px solid #ddd;">Element</th>
              <th style="padding: 8px; text-align: left; border: 1px solid #ddd;">Dark Classes</th>
              <th style="padding: 8px; text-align: left; border: 1px solid #ddd;">Suggestion</th>
            </tr>
          </thead>
          <tbody>
    `;
    
    results.elements.forEach(item => {
      report += `
        <tr>
          <td style="padding: 8px; text-align: left; border: 1px solid #ddd;">${item.element.tagName}</td>
          <td style="padding: 8px; text-align: left; border: 1px solid #ddd;">${item.darkClasses.join(', ')}</td>
          <td style="padding: 8px; text-align: left; border: 1px solid #ddd;">${item.suggestion}</td>
        </tr>
      `;
    });
    
    report += `
          </tbody>
        </table>
        
        <h3 style="margin-top: 30px;">How to Fix</h3>
        <p>For each issue found, add the suggested light mode class to provide proper styling in light mode. For example, if an element has <code>dark:bg-gray-900</code> but no light background, add <code>bg-white</code>.</p>
        
        <h3>Common Patterns</h3>
        <ul>
          <li><strong>Background Colors:</strong> dark:bg-gray-900 → bg-white</li>
          <li><strong>Text Colors:</strong> dark:text-white → text-gray-900</li>
          <li><strong>Border Colors:</strong> dark:border-gray-700 → border-gray-200</li>
        </ul>
      </div>
    `;
    
    return report;
  }
}
