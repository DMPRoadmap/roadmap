import 'number-to-text/converters/en-us';
import { convertToText } from 'number-to-text/index';
import { isFunction } from './isType';
import { enableValidations, disableValidations } from './validation';

const getLinks = elem =>
  $(elem).find('.link').map((i, el) => {
    const link = $(el);
    const linkVal = link.find('input[name="link_link"]').val();
    const textVal = link.find('input[name="link_text"]').val();
    if (linkVal || textVal) { // Validations are enabled if non-empty value is found
      enableValidations(link);
      return { link: linkVal, text: textVal };
    }
    // If linkVal and textVal are empty trigger delete handler
    link.find('.delete').first().trigger('click');
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
  }
  return eachLinks;
};
eachLinks.done = (cb) => {
  if (isFunction(cb)) {
    cb();
  }
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
    const nbrLinks = linksLength(target);
    if (nbrLinks < max) {
      const lastLink = target.closest('.links').find('.link').last();
      const clonedLink = lastLink.clone();
      changeIds(clonedLink);
      clearVals(clonedLink);
      // disableVaidations since a cloned element might contain invalid value for link_{link|text}
      disableValidations(clonedLink);
      lastLink.after(clonedLink);
      // enableValidations for the newly added inputs
      enableValidations(clonedLink);
      // Hide the add link if we have now reached the limit
      if (nbrLinks + 1 >= max) {
        $(target).closest('.links').find('a.new').addClass('hide');
      }
    }
  });

  $('.links').on('click', '.delete', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const max = maxNumberLinks(target);
    const nbrLinks = linksLength(target);
    if (nbrLinks > 1) {
      // If this brought us below the max nbr of links then show the add new link
      if ((nbrLinks - 1) < max) {
        target.closest('.links').find('a.new').removeClass('hide');
      }
      target.closest('.link').remove();
    } else {
      const link = target.closest('.link');
      clearVals(link);
      disableValidations(link);
    }
  });
  $('.links').find('.max-number-links').each((i, el) => {
    const target = $(el);
    const max = target.closest('.links').attr('data-max-number-links');
    target.text(convertToText(max).toLowerCase());
  });
});

export { eachLinks as default };
