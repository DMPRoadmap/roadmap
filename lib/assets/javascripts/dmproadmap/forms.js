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
