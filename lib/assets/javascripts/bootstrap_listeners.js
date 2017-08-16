$(document).ready(function(){
    $('.accordion-body').on('show.bs.collapse', function(){
        $(this).parent().find('.icon-plus').removeClass('icon-plus').addClass('icon-minus');
    }).on('hide.bs.collapse', function(){
        $(this).parent().find('.icon-minus').removeClass('icon-minus').addClass('icon-plus');
    });
    $('.accordion-home').on('show', function() {
        $(this).parent().find('.plus-laranja').removeClass('plus-laranja').addClass('minus-laranja');
    }).on('hide', function(){
        $(this).parent().find('.minus-laranja').removeClass('minus-laranja').addClass('plus-laranja');
    });
    $('.accordion-project').on('show', function() {
        $(this).parent().find('.plus-laranja').removeClass('plus-laranja').addClass('minus-laranja');
    }).on('hide', function(){
        $(this).parent().find('.minus-laranja').removeClass('minus-laranja').addClass('plus-laranja');
    });
    // Initialises all tooltips present on a page
    $('.has-tooltip').tooltip({ placement: "right", trigger: "focus" });
    $(".help").popover();
    //Initiliases all popovers on a page
    $('[data-toggle="popover"]').on('click', function(e){
        e.preventDefault();
    }).popover();
});