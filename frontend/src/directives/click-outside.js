/**
 * v-click-outside directive
 * 
 * Usage:
 * v-click-outside="onClickOutside"
 * 
 * This directive will call the provided function when the user
 * clicks outside of the element it's attached to.
 */

export const vClickOutside = {
  beforeMount(el, binding) {
    el._clickOutside = (event) => {
      // Check if click was outside the el and its children
      if (!(el === event.target || el.contains(event.target))) {
        // Call the provided method
        binding.value(event);
      }
    };
    document.addEventListener('click', el._clickOutside, true);
  },
  unmounted(el) {
    document.removeEventListener('click', el._clickOutside, true);
  }
};

export default {
  install(app) {
    app.directive('click-outside', vClickOutside);
  }
};
