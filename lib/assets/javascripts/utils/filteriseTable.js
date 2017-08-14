/* 
  filteriseTable adds filter capabilities to an HTML table 
  table rows are shown/hidden as the user enters text into the filter input field 
  all rows are made visible when the user clicks the 'clear' icon
*/
(function(ctx){

  var filter = (function(el){
    var query = $(el).val(),
        regex = new RegExp(query, 'i');

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
			var id = $(this).attr("id");

      /* initialize a debounced listener for the filter box */
	    var debounced = (function(){
	      var funcs = {};
	      return {
	        has: function(id){
	          return funcs[id] !== undefined;
	        },
	        get: function(id){
	          return funcs[id];
	        },
	        set: function(id, func){
	          funcs[id] = dmproadmap.utils.debounce(func);
	        }
	      }
	    })();
			
      /* Bind the clear function to the clear icon's click event */
      $(options.selector).focus(function(){
        if(!debounced.has(id)){
            debounced.set(id, filter); 
        }
      }).blur(function(){
        if(debounced.has(id)){  
          debounced.get(id).cancel();
				}
      })
			
			$(options.selector).siblings("#clear_filter").click(function(e){
        e.preventDefault();
        clear(options.selector);

        if(debounced.has(id)){  
          debounced.get(id).cancel();
				}
      });
    }
  });

})(define('dmproadmap.utils.filteriseTable'));