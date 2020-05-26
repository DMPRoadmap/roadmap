import { isString, isNumber } from './isType';

/*
  Scrolls browser window to the selector specified
  @param selector - String CSS selector
  @param duration (optional) - Number or String that determines how long the animation will run
*/
export const scrollTo = (selector, duration) => {
  if (isString(selector)) {
    $('html, body').animate({
      scrollTop: $(selector).offset().top,
    }, isNumber(duration) || isString(duration) ? duration : 500);
  }
};

export { scrollTo as default };
