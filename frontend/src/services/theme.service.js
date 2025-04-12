/**
 * ThemeService - Manages theme preferences for the application
 * 
 * This service handles:
 * - Applying themes ('dark', 'light', or 'system')
 * - Loading themes from localStorage
 * - System preference detection
 * - Theme preference persistence
 */
class ThemeService {
  /**
   * Apply theme to the application
   * @param {string} theme - The theme to apply ('light', 'dark', or 'system')
   */
  applyTheme(theme) {
    console.log('Applying theme:', theme);
    const htmlEl = document.documentElement;
    
    // First, remove all theme classes to start fresh
    htmlEl.classList.remove('dark', 'light');
    
    if (theme === 'system') {
      // Check system preference
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      
      if (prefersDark) {
        console.log('System prefers dark mode');
        htmlEl.classList.add('dark');
      } else {
        console.log('System prefers light mode');
        htmlEl.classList.add('light');
      }
      
      // Listen for changes in system preference
      this.setupSystemPreferenceListener();
    } else {
      // Remove listeners if we're explicitly setting a theme
      this.removeSystemPreferenceListener();
      
      // Set explicit theme
      if (theme === 'dark') {
        console.log('Setting explicit dark theme');
        htmlEl.classList.add('dark');
      } else {
        console.log('Setting explicit light theme');
        htmlEl.classList.add('light');
      }
    }
    
    // Store theme in localStorage as fallback
    localStorage.setItem('theme_preference', theme);
    console.log('Theme saved to localStorage:', theme);
  }
  
  /**
   * Load theme from localStorage or apply default
   * @returns {string} The loaded theme
   */
  loadTheme() {
    const savedTheme = localStorage.getItem('theme_preference') || 'dark';
    console.log('Loading theme from localStorage:', savedTheme);
    this.applyTheme(savedTheme);
    return savedTheme;
  }
  
  /**
   * Set up listener for system theme preference changes
   */
  setupSystemPreferenceListener() {
    // Remove existing listener first
    this.removeSystemPreferenceListener();
    
    // Create new listener
    this.systemPreferenceListener = (e) => {
      const htmlEl = document.documentElement;
      
      // Clear existing classes first
      htmlEl.classList.remove('dark', 'light');
      
      if (e.matches) {
        // System switched to dark mode
        htmlEl.classList.add('dark');
      } else {
        // System switched to light mode
        htmlEl.classList.add('light');
      }
    };
    
    // Add listener
    window.matchMedia('(prefers-color-scheme: dark)')
      .addEventListener('change', this.systemPreferenceListener);
  }
  
  /**
   * Remove system theme preference listener
   */
  removeSystemPreferenceListener() {
    if (this.systemPreferenceListener) {
      window.matchMedia('(prefers-color-scheme: dark)')
        .removeEventListener('change', this.systemPreferenceListener);
      this.systemPreferenceListener = null;
    }
  }
}

export default new ThemeService();
