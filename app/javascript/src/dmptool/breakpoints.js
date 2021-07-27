// SCSS Breakpoints to JS //

// Get list of breakpoints from --breakpoints variable defined in _breakpoints-js.scss, make into array, destructure into "minwidth#" variables, then export them for js module use:

const breakpoints = window.getComputedStyle(document.documentElement).getPropertyValue('--breakpoints');

const breakpointsArr = breakpoints.split(',');

export const [minwidth1, minwidth2] = breakpointsArr;
