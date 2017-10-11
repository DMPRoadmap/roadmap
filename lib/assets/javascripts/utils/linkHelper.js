import { isString } from './isType';

$(() => {
  const restfulLinks = $('a[data-method]');

  restfulLinks.map((idx, el) => {
    const method = $(el).attr('data-method');
    const target = $(el).attr('href');
    const token = $('meta[name="csrf-token"]').attr('content');

    if (isString(method) && isString(target)) {
      const html = `<form action="${target}" method="POST" style="display:none">
        <input type="hidden" name="_method" value="${method.toUpperCase()}" />
        <input type="hidden" name="authenticity_token" value="${token}" />
        </form>`;
      $(el).append(html);

      $(el).click((e) => {
        e.preventDefault();
        $(e.currentTarget).find('form').submit();
      });
    }
    return true;
  });
});
