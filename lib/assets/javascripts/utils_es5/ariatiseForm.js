/*
    dmproadmap.utils.ariatiseForm augmentates a HTML form by:
    - Associating help text with form controls
    - Adding validation state to each form group
    - Adding specific attributes for user with assistive technologies.

    For example the following form :
    <form>
        <div class="form-group">
            <label class="control-label" for="name">Name</label>
            <input type="text" class="form-control" id="name" aria-required="true">
        </div>
        <div class="form-group">
            <label class="control-label" for="email">Email</label>
            <input type="email" class="form-control" id="email" aria-required="true">
        </div>
        <div class="form-group">
            <label class="control-label" for="name">Subject</label>
            <input type="text" class="form-control" id="subject" aria-required="false">
        </div>
        <button name="button" type="submit" class="btn btn-default">Submit</button>
    </form>
    will be augmentated as follows:
    <form>
        <div class="form-group">
            <label class="control-label" for="name">Name</label>
            <input type="text" class="form-control" id="name" aria-required="true" aria-describedby="help0">
            <span id="help0" class="help-block" style="display:none;">Please fill out this field with a valid text.</span>
        </div>
        <div class="form-group">
            <label class="control-label" for="email">Email</label>
            <input type="email" class="form-control" id="email" aria-required="true" aria-describedby="help1">
            <span id="help1" class="help-block" style="display:none;">Please fill out this field with a valid email.</span>
        </div>
        <div class="form-group">
            <label class="control-label" for="name">Subject</label>
            <input type="text" class="form-control" id="subject" aria-required="false">
        </div>
        <button name="button" type="submit" class="btn btn-default">Submit</button>
    </form>
    and any time the buttton is clicked the validation according to each type (e.g. text, email) will be triggered. An invalid result for a form-control will:
    1. Add has-error class to its form-group parent and aria-invalid="true" to the form-control
    2. Show its help-block following sibling
    3. Prevent form to be submitted
*/
(function(ctx){
    // Collect all elements that are either required or have data-validation defined
    var validatableFields=(function(selector){
        return $(selector).find('.form-control').filter('[data-validation],[aria-required="true"]');
    });
    var blockHelp=(function (id,type){
      return '<span id="'+id+'" class="help-block" style="display:none;"></span>';
    });
    var ariaDescribedBy=(function(value){
        return { 'aria-describedby': value };
    });
    var ariaInvalid=(function(value){
        return { 'aria-invalid': value };
    });
/*
    var defaultValidationError=(function(type){
      if(dmproadmap.utils.validate[type] && dmproadmap.utils.validate[type].message){
        return dmproadmap.utils.validate[type].message;
      }
      return '';
    });
*/
    var validationStates={
            hasWarning: 'has-warning',
            hasError: 'has-error',
            hasSuccess: 'has-success'
    };
    var getValidationTypeForElement=(function(el){
      var validation = $(el).attr('data-validation');
      // if the specified validation type is defined
      if(validation && dmproadmap.utils.validate[validation]){
        return $(el).attr('data-validation');

      }else if($(el).attr('aria-required') === 'true'){
        return 'required';
      }
      return false;
    });
    var isValid=(function(type, value){
        // TODO add more validation for each new type coming along by:
        // 1. defining a function at dmproadmap.utils.validate
        // 2. adding the case in the switch below
        switch(type){
            case 'required':
                return dmproadmap.utils.validate.required(value);
            case 'email':
                return dmproadmap.utils.validate.email(value);
            case 'password':
                return dmproadmap.utils.validate.password(value);
            default:
                return false;
        }
    });
    var valid=(function(el){
        $(el).parent().removeClass(validationStates.hasError);
        $(el).attr(ariaInvalid(false));
        $(el).next().hide();
    });
    var invalid=(function(el,msg){
        $(el).parent().addClass(validationStates.hasError);
        $(el).attr(ariaInvalid(true));
        $(el).next().text(msg).show();
    });

    ctx.displayValidationError=ctx.displayValidationError || (function(el,msg){
      // Updates the validation error message for the element. If no msg is provided it will revert to the default message
      if($(el)){
        invalid(el,msg);
      }
    });
    ctx.init=ctx.init || (function(options){
        if($ && options && options.selector){
            validatableFields(options.selector).each(function(i,el){
                $(el).attr(ariaDescribedBy('help'+i));
                $(el).after(blockHelp('help'+i, getValidationTypeForElement(el)));
            });

            $(options.selector+' [type="submit"]').click(function(e){
                validatableFields(options.selector).each(function(i,el){
                  // If the element has a data-validation defined and the value is not blank
                  if($(el).attr('data-validation') && $(el).val().trim().length > 0){
                    if(isValid($(el).attr('data-validation'), $(el).val())){
                      valid(el);
                    }else{
                      e.preventDefault();
                      invalid(el);
                    }
                  // If the element is a required field make sure its not blank
                  }else if($(el).attr('aria-required') === "true"){
                    if(isValid('required', $(el).val())){
                      valid(el);
                    }else{
                      e.preventDefault();
                      invalid(el);
                    }
                  }
                });
            });
        }
    });
})(define('dmproadmap.utils.ariatiseForm'));