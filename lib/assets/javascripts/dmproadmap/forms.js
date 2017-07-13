// ---------------------------------------------------------------------------
function remoteSave(target, method, data){
  $("div.roadmap-info-box span:not(.aria-only)").parent().css('visibility', 'hidden').fadeOut()

  // Update the visbility when the user clicks on the radio button
  $.ajax({
    url: target, 
    type: method,
    data: data,
    contentType: 'application/json',
    accepts: 'application/json'
  }).done(function(data){
    $("#notification-area span:not(.aria-only)").html(data['msg']).css('width', 'auto')
          .attr('role', (data['code'] === 1 ? 'status' : 'alert'))
          .attr('class', (data['code'] === 1 ? 'roadmap-info-box' : 'roadmap-alert-box'))
          .parent().css('visibility', 'visible').fadeIn();
  });
}

// ---------------------------------------------------------------------------
function toggleAutocompleteError(autocomplete, idbox, errorMessage){
  if(autocomplete.length > 0 && idbox.length > 0){
    var err = $(idbox).siblings("span.error-tooltip");
    if(err.length <= 0){
      err = $(idbox).siblings("span.error-tooltip-right");
    }
  
    // If an error element is available and the error message is not empty and the field
    // is not empty
    if(err.length > 0 && (errorMessage === '' || $(autocomplete).val().trim().length <= 0)){
      err.html('').attr('role', '');
      $(autocomplete).removeClass('red-border');
    }else{
      err.html(errorMessage).attr('role', 'tooltip');
      $(autocomplete).addClass('red-border');
    }
  }
}

// ---------------------------------------------------------------------------
function toggleInputError(input, errorMessage, allowBlank = true){
  var err = $(input).siblings("span.error-tooltip");
  if(err.length <= 0){
    err = $(input).siblings("span.error-tooltip-right");
  }
  
  // If an error element is available and the error message is not empty and the field
  // is not empty (unless its a required field!)
  if(err.length > 0 && (errorMessage === '' || (allowBlank && $(input).val().trim().length <= 0))){
    err.html('').attr('role', '');
    $(input).removeClass('red-border');
  }else{
    err.html(errorMessage).attr('role', 'alert');
    $(input).addClass('red-border');
  }
}

// ---------------------------------------------------------------------------
function validatePassword(sPassword) {
  if(sPassword.trim().length >= 8 && sPassword.trim().length <= 128){
    return '';
  }else{
    return __('Passwords must have at least 8 characters');
  }
}

// ---------------------------------------------------------------------------
function validateEmail(sEmail) {
  var filter = /[^@\s]+@(?:[-a-z0-9]+\.)+[a-z]{2,}$/;
  if(filter.test(sEmail)){
    return '';
  }else{
    return __('Invalid email address');
  }
}