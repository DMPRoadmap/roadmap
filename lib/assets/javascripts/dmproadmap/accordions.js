$(document).ready(function(){
  $(".accordion").accordion({heightStyle: "content"});
  
  $(".accordion h2, .accordion h3").click(function(e){
    $.each($(this).parent().children("h2"), function(idx, section){
      if($(section).hasClass("ui-accordion-header-active")){
        $(section).children("span.fa").removeClass("fa-plus").addClass("fa-minus");
      }else{
        $(section).children("span.fa").removeClass("fa-minus").addClass("fa-plus");
      }
    });
  });
});