import getConstant from './constants';

//
//
$(() => {
  $('body').on('click', '.card .more-info a', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const info = $(link).siblings('div.info');

      if (info.length > 0) {
        if (info.hasClass('hidden')) {
          info.removeClass('hidden');
          link.text(`${getConstant('LESS_INFO')}`);
        } else {
          info.addClass('hidden');
          link.text(`${getConstant('MORE_INFO')}`);
        }
      }
    }
  });

  $('body').on('click', '.card a.facet', (e) => {
    const link = $(e.target);

    if (link.length > 0) {
      const textField = $('#research_output_repository_search_term');

      if (textField.length > 0) {
        textField.val(link.text());
      }
    }
  });
});
