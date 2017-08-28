$(document).ready(function(){
  $(".accordion").accordion({
    active: false,
    collapsible: true,
    heightStyle: "content"
  });
  
  /* swap out the plus/minus icons */
  $(".accordion h2, .accordion h3").click(function(e){
    $.each($(this).parent().children("h2"), function(idx, section){
      if($(section).hasClass("ui-accordion-header-active")){
        $(section).children("span.fa").removeClass("fa-plus").addClass("fa-minus");
      }else{
        $(section).children("span.fa").removeClass("fa-minus").addClass("fa-plus");
      }
    });
  });

  /* expand/collapse all controls */
  $("a.expand-accordions").click(function(e){
    e.preventDefault();
    var accordion = $(this).attr('href');
    $(accordion).children(".accordion-section").css('display', 'block');
    $(accordion).children("h2, h3").children("span.fa").removeClass("fa-plus").addClass("fa-minus");
  });
  $("a.collapse-accordions").click(function(e){
    e.preventDefault();
    var accordion = $(this).attr('href');
    $(accordion).children(".accordion-section").css('display', 'none');
    $(accordion).children("h2, h3").children("span.fa").removeClass("fa-minus").addClass("fa-plus");
  });
});