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
    var requiredFields=(function(selector){
        return $(selector).find('.form-control').filter('[aria-required="true"]');
    });
    var blockHelp=(function (id,type){
        var msg='Please fill out this field with a valid '+type+'.';    //TODO internationalisation
        return '<span id="'+id+'" class="help-block" style="display:none;">'+msg+'</span>';
    });
    var ariaDescribedBy=(function(value){
        return { 'aria-describedby': value };
    });
    var ariaInvalid=(function(value){
        return { 'aria-invalid': value };
    });
    var validationStates={
            hasWarning: 'has-warning',
            hasError: 'has-error',
            hasSuccess: 'has-success'
    };
    var getTypeForSubmittableElement=(function(el){
        // Reference from https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Content_categories#Form-associated_content
        if($(el).is('input')){
            return $(el).attr('type');  // available types at https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_<input>_types
        }
        else if($(el).is('select')){
            return 'select';
        }
        else if($(el).is('textarea')){
            return 'textarea';
        }
        else
            return 'unknown';
    });
    var isValid=(function(type, value){
        // TODO add more validation for each new type coming along by:
        // 1. defining a function at dmproadmap.utils.validate
        // 2. adding the case in the switch below
        switch(type){
            case 'text':
            case 'textarea':
                return dmproadmap.utils.validate.text(value);
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
    var invalid=(function(el){
        $(el).parent().addClass(validationStates.hasError);
        $(el).attr(ariaInvalid(true));
        $(el).next().show();
    });
    ctx.init=ctx.init || (function(options){
        if($ && options && options.selector){
            requiredFields(options.selector).each(function(i,el){
                $(el).attr(ariaDescribedBy('help'+i));
                $(el).after(blockHelp('help'+i, getTypeForSubmittableElement(el)));
            });
            $(options.selector+' [type="submit"]').click(function(e){
                requiredFields(options.selector).each(function(i,el){
                    if(isValid(getTypeForSubmittableElement(el),$(el).val())){
                        valid(el);
                    }
                    else{
                        e.preventDefault();
                        invalid(el);
                    }
                });
            });
        }   
    });
})(define('dmproadmap.utils.ariatiseForm'));