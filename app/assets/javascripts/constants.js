import { isObject, isString } from './utils/isType';

let constants = {};
export default key => constants[key];
$(() => {
  // js-constants is defined in views/layouts/application.html.erb
  const target = $('#js-constants');
  if (isObject(target) && isString(target.val())) {
    constants = JSON.parse(target.val());
  }
});
