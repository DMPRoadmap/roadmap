$(document).ready(function() {

  // Prevent the click handler from being registered multiple times.
  // This is due to the buggy way this is included.
  if (window['has_export_js'])
    return;

  window['has_export_js'] = true;

  $.expr.filters.indeterminate = function(element) {
    return $(element).prop('indeterminate');
  };

  $("select#format").change(function(){
    if ($(this).val() == 'pdf') {
      $("#pdf-format-options").show();
      $("#settings-toggle > small").show();
    }
    else {
      $("#pdf-format-options").hide();
      $("#settings-toggle > small").hide();
    }
  });

  $("input:checkbox, select:not(#format)").change(function(){
    $(".unsaved_changes_alert").show();
  });

  $("select:not(#format)").change(function(){
    $(".unsaved_changes_alert").show();
  });

  $('.check_select > legend').append('<input type="checkbox" class="toggle" />');

  $('.resetbutton').click(function(){
    $('input:checkbox').prop('checked',true);
    $("select:not(#format)").each(function(){
      $(this).val($(this).data("default"));
    });
    $(".unsaved_changes_alert").hide();
    $("#settings-toggle > small").text(__('(Using template PDF formatting values)'));
  });

  $('.savebutton').click(function(){
    var custom = false;
    $("select:not(#format)").each(function(){
      if ($(this).val() != $(this).data("default")) {
        custom = true;
      }
    });
    if (custom) {
      $("#settings-toggle > small").text(__('(Using custom PDF formatting values)'));
    }
    else {
      $("#settings-toggle > small").text(__('(Using template PDF formatting values)'));
    }
    $(".unsaved_changes_alert").hide();
  });

  $('.check_select').each(function() {
    var container = $(this),
           toggle = container.find('> legend > .toggle'),
           checks = container.find('> ol > li > input[type=checkbox], li > fieldset > legend > input[type=checkbox]');


    function checked(toggle) {
      var checks = toggle.prop('checks'),
         checked = checks.filter(':checked').length,
         indeterminate = checks.filter(':indeterminate').length;

      return {
        'indeterminate' : ((checked > 0 && checked < checks.length) || indeterminate > 0),
              'checked' : (checked == checks.length)
      };
    }

    function toggleParent(toggle) {
      var parent_toggle = toggle.prop('toggle');

      if (parent_toggle)
        parent_toggle.prop(checked(parent_toggle));
    }

    checks.prop('toggle', toggle);
    toggle.prop('checks', checks);
    toggle.prop('id', container.find('> legend > label').prop('for'));
    toggle.prop(checked(toggle));
    toggleParent(toggle);

    checks.change(function() {
      toggle.prop(checked(toggle));
      toggleParent(toggle);
    });

    toggle.change(function() {
      $(".unsaved_changes_alert").show();
      checks.prop({ 'checked': toggle.is(':checked'), 'indeterminate': false});

      checks.each(function() {
        var child_checks = $(this).prop('checks');

        if (child_checks)
          child_checks.prop({ 'checked': toggle.is(':checked'), 'indeterminate': toggle.is(':indeterminate') });

      });
    });
  });
  /*----------------
    Listener for select that displays the formatting options (e.g. csv, html, pdf, txt, etc.)
  ------------------*/
  $('.export-format-selection').click(function(e){
    e.preventDefault();
    if($(this).val() === 'pdf'){
      $('#pdf-format-options').show();
    }else{
      $('#pdf-format-options').hide();
    }
  });

  /*----------------
    Listener for select that disables the unanswered questions
  ------------------*/
  $('.question-headings').click(function(e){
    if($(this).is(':checked')){
      $('.unanswered-questions').removeAttr("disabled");
    }else{
      $('.unanswered-questions').prop("checked", false);
      $('.unanswered-questions').prop("disabled", true);
    }
  });
});