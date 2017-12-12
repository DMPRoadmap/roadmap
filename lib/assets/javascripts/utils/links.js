import 'number-to-text/converters/en-us';
import { convertToText } from 'number-to-text/index';
import { isFunction, isObject } from './isType';
import { isValidText } from './isValidInputType';
import { enableValidations, disableValidations } from './validation';

const getLinks = elem =>
  $(elem).find('.link').map((i, el) => {
    const linkVal = $(el).find('input[name="link_link"]').val();
    const textVal = $(el).find('input[name="link_text"]').val();
    if (linkVal.length > 0 && textVal.length > 0) {
      return { link: linkVal, text: textVal };
    }
    return undefined;
  }).get();

/*
 * Iterates through any links class found and for each one found,
 * executes the function cb by passing two parameters: the data-context value
 * and value param being an Array of link objects (e.g. [{ link: String, text: String }, ...])
 * that represent the values for the input texts introduced.
*/
export const eachLinks = (cb) => {
  if (isFunction(cb)) {
    $('.links').each((i, el) => {
      cb($(el).attr('data-context'), getLinks(el));
    });
    eachLinks.done();
  }
  return eachLinks;
};
eachLinks.done = (cb) => {
  if (isFunction(cb)) {
    cb();
  }
};

const enableLinkValidations = (ctx) => {
  if (isObject(ctx)) {
    let validatable = false;
    const fields = $(ctx).find('input');

    // Determine if ANY one of the values has been populated
    fields.each((i, el) => {
      if (isValidText($(el).val())) {
        validatable = true;
      }
    });

    // If one field has been populated make both fields required otherwise remove any validations
    if (validatable) {
      $(ctx).find('input').attr('aria-required', 'true');
      enableValidations(ctx);
    } else {
      $(ctx).find('input').removeAttr('aria-required');
      disableValidations(ctx);
    }
  }
};
const addValidationHandlers = (ctx) => {
  $(ctx).find('input').on('blur', () => {
    enableLinkValidations(ctx);
  });
};

$(() => {
  const regExp = /([^\d]*)(\d)+/;
  const replacer = (match, p1, p2) => `${p1}${(p2 * 1) + 1}`;
  const replacerFor = (i, el) => $(el).attr('for', $(el).attr('for').replace(regExp, replacer));
  const replacerId = (i, el) => $(el).attr('id', $(el).attr('id').replace(regExp, replacer));
  const changeIds = (jqueryElem) => {
    jqueryElem.find('label').each(replacerFor);
    jqueryElem.find('input[type="text"]').each(replacerId);
  };
  const clearVals = (jqueryElem) => {
    jqueryElem.find('input[type="text"]').each((i, el) => {
      $(el).val('');
    });
  };
  const linksLength = jqueryElem => jqueryElem.closest('.links').find('.link').length;
  const maxNumberLinks = jqueryElem => jqueryElem.closest('.links').attr('data-max-number-links') * 1;

  $('.links').on('click', '.new', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const max = maxNumberLinks(target);
    if (linksLength(target) < max) {
      const lastLink = target.closest('.links').find('.link').last();
      const clonedLink = lastLink.clone();
      changeIds(clonedLink);
      clearVals(clonedLink);
      disableValidations(clonedLink);
      addValidationHandlers(clonedLink);
      lastLink.after(clonedLink);
    }
  });
  $('.links').on('click', '.delete', (e) => {
    e.preventDefault();
    const target = $(e.target);
    if (linksLength(target) > 1) {
      target.closest('.link').remove();
    }
  });

  $('.links').find('.max-number-links').each((i, el) => {
    const target = $(el);
    const max = target.closest('.links').attr('data-max-number-links');
    target.text(convertToText(max).toLowerCase());
  });

  // Initialize validation on entries with data and add change handlers to toggle validation
  $('.link').each((i, el) => {
    enableLinkValidations(el);
    addValidationHandlers(el);
  });
});

export { eachLinks as default };
