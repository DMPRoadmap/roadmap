/* 
  filteriseTable adds filter capabilities to an HTML table 
  table rows are shown/hidden as the user enters text into the filter input field 
  all rows are made visible when the user clicks the 'clear' icon
*/
(function(ctx){

  var filter = (function(el){
    var query = $(el).val(),
        regex = new RegExp(query, 'i');

    $.each($(el).closest("table").find("tbody tr"), function(idx, tr){
      if(regex.test($(tr).text())){
        $(tr).show();
      }else{
        $(tr).hide();
      }
    });
  });

  var clear = (function(el){
    $(el).val('');
    $(el).closest("table").find("tbody tr").show();
  });

  ctx.init = ctx.init || (function(options){
    if($ && options && options.selector){
      var id = $(this).attr("id");

      /* initialize a debounced listener for the filter box */
      var debounced = dmproadmap.utils.debounce(filter);

      /* Bind the clear function to the clear icon's click event */
      $(options.selector).keyup(function(){
        debounced(this); 
      });

      $(options.selector).siblings("#clear_filter").click(function(e){
        e.preventDefault();
        clear(this);
        debounced.cancel();
      });
    }
  });

})(define('dmproadmap.utils.filteriseTable'));