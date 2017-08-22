    var <%= id %>_crosswalk = <%= raw JSON.generate(json) %>;
    
    // When the user selects a value from the combobox, place the corresponding id in the hidden field
    $(document).ready(function(){
      var combo = $("#<%= id %>");
      var clear = $(combo).siblings(".combobox-clear-button");
      
      // Pull the id out of the json hash based on the text the user selected
      $(combo).keyup(function(){
        var selection = <%= id %>_crosswalk[$(this).val()];
        $("#<%= id.gsub("_#{attribute}", "_id") %>").val(selection === 'undefined' ? '' : selection).change();
      }).focus(function(){
        var selection = <%= id %>_crosswalk[$(this).val()];
        $("#<%= id.gsub("_#{attribute}", "_id") %>").val(selection === 'undefined' ? '' : selection).change();
      });
      
      // Initialize the clear buttons on load
      // Replace the default js-combobox clear button [X] with a fontawesome icon
      $(clear).html('<i class="fa fa-times-circle" aria-hidden="true"></i>');
      $(clear).css("display", $(combo).val().trim().length <= 0 ? 'none' : 'inline');
  
      // Function to hide/show the clear button when text changed in the dropdown
      // -------------------------------------------------------------
      $(combo).keyup(function(){
        $(clear).css("display", $(combo).val().trim().length <= 0 ? 'none' : 'inline');
      }).change(function(){
        $(clear).css("display", $(combo).val().trim().length <= 0 ? 'none' : 'inline');
      });

      // Hide the clear button if it gets clicked
      // -------------------------------------------------------------
      $(clear).click(function(){
        $(this).css("display", 'none');
        $(combo).val("").focus();//.keyup();
      });
      
      // Display the error message if the value in the auto complete is not an item from the list
      $("#<%= id.gsub("_#{attribute}", "_id") %>").on('change', function(){
        if($(this).val().trim().length > 1 || $(combo).val().trim().length < 1){
          $("#<%= id %>_error").html("").attr('role', '');
          $("#<%= id %>").removeClass('red-border');
        }else{
          $("#<%= id %>_error").html("<%= err_msg %>").attr('role', 'alert');
          $("#<%= id %>").addClass('red-border');
        }
      });
    });