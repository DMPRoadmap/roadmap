/* 
  tablesorter is an external library located in vendor/tablesorter.

  it does not provide us with icons though, so we add our own below along
  with logic to change them to up/down arrows when the user sorts the column
*/

(function(ctx){
  var swapIcons = (function(el){
    if($(el).find("span.fa").hasClass('fa-sort') || $(el).find("span.fa").hasClass('fa-sort-asc')){
      $(el).find("span.fa").removeClass('fa-sort').removeClass('fa-sort-asc').addClass('fa-sort-desc');
    }else{
      $(el).find("span.fa").removeClass('fa-sort-desc').addClass('fa-sort-asc');
    }
  });
  
  ctx.init = ctx.init || (function(options){
    if($ && options && options.selector){
      /* Bind the table to the external tablesorter JS (see vendor/tablesorter) */
      $(options.selector).tablesorter(); 
    
      /* Tablesorter doesn't provide icons so we add our own here */
      /* we also bind their click event to display the up/down arrow */
      $(options.selector + " th.tablesorter-headerUnSorted:not(.sorter-false) div.tablesorter-header-inner")
      .append('<span class="fa fa-sort" title="sort"></span>')
      .click(function(e){
        swapIcons(this);
      });
    }
  });
})(define('dmproadmap.utils.collateTable'));