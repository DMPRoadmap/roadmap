/* 
  tablesorter is an external library located in vendor/tablesorter.

  it does not provide us with icons though, so we add our own below along
  with logic to change them to up/down arrows when the user sorts the column
*/

(function(ctx){
  ctx.init = ctx.init || (function(options){
    if($ && options && options.selector){
      /* Bind the table to the external tablesorter JS (see vendor/tablesorter) */
      $(options.selector).tablesorter({
        theme: 'bootstrap_3',
        headerTemplate: '{content} {icon}',
        cssIconAsc: 'fa fa-sort-asc',
        cssIconDesc: 'fa fa-sort-desc',
        cssIconNone: 'fa fa-sort'
      }); 
    }
  });
})(define('dmproadmap.utils.collateTable'));