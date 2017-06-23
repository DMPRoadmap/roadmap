$(function(){

  $(".tablesorter").tablesorter({
    dateFormat: "uk"
  }); 

  $(".tablesorter thead th.tablesorter-headerUnSorted:not(.sorter-false) div")
  .append('<span class="fa fa-sort" title="sort"></span>')
  .click(function(e){
    if($(this).find("span.fa").hasClass('fa-sort') || $(this).find("span.fa").hasClass('fa-sort-asc')){
      $(this).find("span.fa").removeClass('fa-sort').removeClass('fa-sort-asc').addClass('fa-sort-desc');
    }else{
      $(this).find("span.fa").removeClass('fa-sort-desc').addClass('fa-sort-asc');
    }
  });

  // Table filter search
  $("#filter").keyup(function(e){
    var query = $(this).val(),
        regex = new RegExp(query, 'i'),
        matched = false;
        
    if(query.length < 2){
      $(this).closest("table").find("tbody tr").show();
      $(this).closest("table").find("tbody tr.no-matches").hide();
      
    }else{
      $.each($(this).closest("table").find("tbody tr"), function(idx, ctx){
        if($(ctx).text().match(regex)){
          $(ctx).show();
        }else{
          $(ctx).hide();
        }
      });
    }
  });

  // Table filter clear
  $('#clear_filter').click(function(e){
    e.preventDefault();

    $("#filter").val('');
    $(this).closest("table").find("tbody tr").show();
    $(this).closest("table").find("tbody tr.no-matches").hide();
  });

  $('#filter_form').submit(function(e){ e.preventDefault(); });
  
});