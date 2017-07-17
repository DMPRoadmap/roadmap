// ---------------------------------------------------------------------------
function asyncRequest(params, callbacks){
  if(params['url']){
    var defaults = {type: 'GET', 
                    contentType: 'application/json',
                    accepts: 'application/json'};
  
    // Make sure the incoming params are enough to make the call
    for(var key in defaults){
      if(!params[key]){
        params[key] = defaults[key];
      }
    }

    if(!callbacks){
      callbacks = {};
    }
  
    // Submit the request
    $.ajax(params).then(
      // Success
      function(data, msg, xhr){
        animateNotification(data['msg'], false);
        if(callbacks['success']){
          callbacks['success'](data);
        }
      },

      // Failure
      function(xhr, status, err){
        var json = JSON.parse(xhr.responseText);
        var msg = json['msg'] ? json['msg'] : __('Unable to process your request.');
        animateNotification(msg, true);
        if(callbacks['failure']){
          callbacks['failure'](err);
        }
      }
    );
  }
}

// ---------------------------------------------------------------------------
function toggleInputError(input, errorMessage, blankAsError){
  var err = $(input).siblings("span.error-tooltip");
  if(err.length <= 0){
    err = $(input).siblings("span.error-tooltip-right");
  }
  
  // If an error element is available and the error message is not empty and the field
  // is not empty (unless its a required field!)
  if(err.length > 0 && (errorMessage === '' || (!blankAsError && $(input).val().trim().length <= 0))){
    err.html('').attr('role', '');
    $(input).removeClass('red-border');
  }else{
    err.html(errorMessage).attr('role', 'alert');
    $(input).addClass('red-border');
  }
}

// Animate the Notification message section at the top of the page
// ---------------------------------------------------------------------------
function animateNotification(message, isAlert){
  if(message){
    $("#notification-area span:not(.aria-only)").html(message).css('width', 'auto')
        .attr('role', (isAlert ? 'alert' : 'status'))
        .parent().attr('class', (isAlert ? 'roadmap-alert-box' : 'roadmap-info-box'))
        .css('visibility', 'visible').fadeIn();
    
  }else{
    $("#notification-area span:not(.aria-only)").html('')
        .parent().css('visibility', 'hidden').fadeOut();
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