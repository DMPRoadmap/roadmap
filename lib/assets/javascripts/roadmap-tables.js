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

});