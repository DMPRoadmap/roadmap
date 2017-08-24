import { isFunction } from './isType';

export default class DomManipulator {
  constructor(selector) {
    if (document) {
      document.addEventListener('DOMContentLoaded', () => {
        this.element = document.querySelector(selector);

        if (isFunction(this.callback)) {
          this.callback();
        }
      });
    }
  }
  onReady(callback) {
    this.callback = callback;
  }
  getElement() {
    return this.element;
  }
}

