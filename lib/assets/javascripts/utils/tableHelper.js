import 'tablesorter/dist/js/jquery.tablesorter.min';
import debounce from '../utils/debounce';
import { isObject, isString } from './isType';

export const collateTable = (options) => {
  if (isObject(options) && isString(options.selector)) {
    $(options.selector).tablesorter({
      theme: 'bootstrap_3',
      headerTemplate: '{content} {icon}',
      cssIconAsc: 'fa fa-sort-asc',
      cssIconDesc: 'fa fa-sort-desc',
      cssIconNone: 'fa fa-sort',
    });
  }
};

export const filteriseTable = (options) => {
  if (isObject(options) && isString(options.selector)) {
    const filter = ((el) => {
      const query = $(el).val();
      const regex = new RegExp(query, 'i');

      $.each($(el).closest('table').find('tbody tr'), (idx, tr) => {
        if (regex.test($(tr).text())) {
          $(tr).show();
        } else {
          $(tr).hide();
        }
      });
    });

    const clear = (el) => {
      const formEl = $(el).closest('form');
      formEl.find(options.selector).val('');
      formEl.closest('table').find('tbody tr').show();
    };

    /* initialize a debounced listener for the filter box */
    const debounced = debounce(filter);

    /* Bind the clear function to the clear icon's click event */
    $(options.selector).keyup((e) => {
      debounced(e.currentTarget);
    });

    $('.clear_filter').click((e) => {
      e.preventDefault();
      clear(e.target);
      debounced.cancel();
    });
  }
};
