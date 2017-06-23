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

	// TODO: SEE if any of the below still controls the table search boxes
 var no_matches_message = $('<tr style="display: none;"><td colspan="20">' + __('No matches') + '</td></tr>').appendTo($('#dmp_table tbody')),
                   rows = $('#dmp_table tbody tr'),
                 filter = $('#filter');

 filter.keyup(function() {
   var query = $(this).val(),
         len = query.length,
   filter_re = new RegExp(query, 'i'),
     matched = false;

   if (len < 2) {
     rows.show();
     no_matches_message.hide();
     return;
   }

   no_matches_message.hide();

   rows.each(function() {
     var row = $(this);
     row.text().match(filter_re) ? (matched = true && row.show()) : row.hide();
   });

   if (!matched)
     no_matches_message.show();
 });

 $('#clear_filter').click(function(e) {
   e.preventDefault();

   filter.val('');
   rows.show();
   no_matches_message.hide();
 });

$('#filter_form').submit(function(e) { e.preventDefault() } );
});