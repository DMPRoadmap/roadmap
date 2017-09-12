import 'bootstrap-sass/assets/javascripts/bootstrap/collapse';
import expandCollapseAll from '../../utils/expandCollapseAll';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();
  $('a[data-toggle="collapse"').click((e) => {
    if ($(e.target).hasClass('fa-plus')) {
      $(e.target).removeClass('fa-plus').addClass('fa-minus');
    } else {
      $(e.target).removeClass('fa-minus').addClass('fa-plus');
    }
  });
});
/*
$(document).ready(function(){
  // ------------------
  //  Popup button listeners for when answers are not saved
  // ------------------
  $(".cancel-section-collapse").click(function () {
      var section_id = $(this).attr('data-section');
      $("#collapse-" + section_id).collapse("show");
      $('#section-' + section_id + '-collapse-alert').modal("hide");
  });

  $(".discard-section-collapse").click(function () {
      var section_id = $(this).attr('data-section');
      $('#section-' + section_id + '-collapse-alert').modal("hide");
  });

  $(".save-section-collapse").click(function () {
      var section_id = $(this).attr('data-section');
      $("#collapse-" + section_id).find("input[type='submit']").click();
      $('#section-' + section_id + '-collapse-alert').modal("hide");
  });
  // ------------------
  //  Listener for clicks in any of the right column of question tabs (e.g. Guidances, Notes)
  // ------------------
  $('.right_column_tab_link').click(function(e){
      e.preventDefault();
      // Find current active tab and hide it
      var active = $(this).closest('.question_right_column_ul').children().filter('.active');
      active.removeClass('active');
      $(this).closest('.question-area-right-column').find('div.'+active.attr('class')).hide();
      // Select the clicked tab as active and display its content
      active = $(this).parent();
      $(this).closest('.question-area-right-column').find('div.'+active.attr('class')).show();
      active.addClass('active');
  });
  // ------------------
  //  Accordion toggling for displaying/hiding guidances. 
  //  TODO moving to lib/assets/javascripts/annotations when partials for guidances are created  
  // ------------------
  $('.accordion-guidance-link').on('click', function (e) {
      e.stopPropagation();
      e.preventDefault();
      var accordion_body = $($(this).attr("href"));
      accordion_body.toggleClass("in");   //adds or removes 'in' class from accordion_body  
      if(accordion_body.hasClass('in')){    //accordion expanded
          $(this).children(".plus-laranja").removeClass("plus-laranja")
          .addClass("minus-laranja");    //display minus
      }
      else {  //accordion collapsed
          $(this).children(".minus-laranja").removeClass("minus-laranja")
          .addClass("plus-laranja");   //display plus
      }
  });
});
*/
