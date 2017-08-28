$(document).ready(function(){
  $('#edit_guidance_submit').click( function(e){
      var alert_message = [];

      //verify if text area is not nil
      var editorContent = tinyMCE.get('guidance-text').getContent();
      if (editorContent == ''){
          alert_message.push(__('add guidance text'));
      }
      //verify dropdown with questions has a selected option if guidance for a question being used
      if($('#guidance_theme_ids').val() == undefined || $('#guidance_theme_ids').val() == ''){
        alert_message.push(__('select at least one theme'));
      }
      //verify if guidance group is selected
      if ( ($('#guidance_guidance_group_id').val() == '') || $('#guidance_guidance_group_id').val() == undefined  ) {
        alert_message.push(__('select a guidance group'));
      }

      if(alert_message.length == 0){
        $('#edit_guidance_form').submit();
        return false;
      }
      else if (alert_message.length != 0){
          var message = '',
              self = this;
          
          $('#edit_guidance_alert_dialog').dialog({
            modal: true,
            width: '400px',
            title: 'Before submitting, please:',
      
            open: function(e, ui){
              // This duplicates functionality in modals.js. We should make this a 
              // standard modal OR convert to use the standard error handling we decide on
              $("button.ui-dialog-titlebar-close").remove();
              $(".ui-dialog-titlebar").append('<span class="fa fa-close modal-close"></span>');
        
              $("span.modal-close").click(function(e){
                e.preventDefault();
                $(this).parent(".ui-dialog-titlebar").siblings("div.modal").dialog('close');
              });
              
              $("#missing_fields_edit_guidance").empty();
              $.each(alert_message, function(key, value){
                  message += "<li> "+value+"</li>";
              });
              $("#missing_fields_edit_guidance").append(message);
            }
          });
          delete message;
      }
      delete alert_message;
      e.preventDefault();
  });
});