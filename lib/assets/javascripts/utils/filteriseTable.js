/* 
  filteriseTable adds filter capabilities to an HTML table 
  table rows are shown/hidden as the user enters text into the filter input field 
  all rows are made visible when the user clicks the 'clear' icon
*/
(function(ctx){

  var filter = (function(el){
    var query = $(el).val(),
        regex = new RegExp(query, 'i'),
        matched = false;

    if(query.length < 3){
      $(el).closest("table").find("tbody tr").show();
  
    }else{
      $.each($(el).closest("table").find("tbody tr"), function(idx, tr){
        if($(tr).text().match(regex)){
          $(tr).show();
        }else{
          $(tr).hide();
        }
      });
    }
  });

  var clear = (function(el){
    $(el).val('');
    $(el).closest("table").find("tbody tr").show();
  });

  ctx.init = ctx.init || (function(options){
    if($ && options && options.selector){
      /* Bind the keyup  function to the input field's keyup event */
      $(options.selector).keyup(function(e){
        filter(this);
      });

      /* Bind the clear function to the clear icon's click event */
      $(options.selector).siblings("#clear_filter").click(function(e){
        e.preventDefault();
        clear(options.selector);
      });
    }
  });

})(define('dmproadmap.utils.filteriseTable'));