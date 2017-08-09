$(document).ready(function(){
    /*--------------
        START Autosaving
    ----------------*/
    // debounced object holds a set of debounced functions, one for each form present in the page. Note,
    // each debounced function stored at funcs is created on demand, i.e. once the user changes any element of a form
    var debounced = (function(){
        var funcs = {};
        return {
            has: function(id){
                return funcs[id] !== undefined;
            },
            get: function(id){

                return funcs[id];
            },
            set: function(id, func){
                funcs[id] = dmproadmap.utils.debounce(func);
            }
        }
    })();
    // This function triggers a form submit, if and only if the answer has not been optimistically locked
    var autoSaving=function(){
        if($(this).closest('.question-form').find('.answer-locking').children().length === 0){
            $(this).closest('form.answer').submit();
        }
    };
    var listenersForEditor=function(editor){
        editor.on('change', function(){
            var notAnswered = $('#'+editor.id).closest('.question-form').find('.not-answered');
            notAnswered.hide();
        });
        editor.on('blur', function(){
            var id = $('#'+editor.id).closest('form.answer').attr('data-autosave');
            $('#'+editor.id).val(editor.getContent());  //Updates target element of tinyMCE.editor with its content
            if(!debounced.has(id)){
                debounced.set(id, autoSaving); 
            }
            debounced.get(id).apply($('#'+editor.id),[id]);
        });
        editor.on('focus', function(){
            var id = $('#'+editor.id).closest('form.answer').attr('data-autosave');
            if(debounced.has(id)){
                debounced.get(id).cancel(); //Cancels the execution of its debounced function either because user transitioned from question with options
                        // to the comments or because textarea lost focus and gained again before the delay being met
            }
        });
    }
    /*--------------
        END Autosaving
    ----------------*/
    // Listener for submit event triggered
    $('.question-form').on('submit', 'form.answer', function(){
        var id = $(this).attr('data-autosave');
        if(debounced.has(id)){  
            debounced.get(id).cancel(); //Cancels the execution of its debounced function, if not already, since submit() could have been trigerred through Save button
        }
        var container = $(this).closest('.question-form');
        var saving = container.find('.saving-message');
        saving.show();
    });
    // Listener for changes at any element value from question-form
    $('.question-form').on('change', 'form.answer fieldset input, form.answer fieldset select', function(){
        var notAnswered = $(this).closest('.question-form').find('.not-answered');
        notAnswered.hide();
    });
    // Listener for changes at any element value from question-form. This triggers the debounced function
    $('.question-form').on('change', 'form.answer fieldset input, form.answer fieldset select', function(){
        var id = $(this).closest('form.answer').attr('data-autosave');
        if(!debounced.has(id)){
            debounced.set(id, autoSaving); 
        }
        debounced.get(id).apply($(this),[id]);
    });
    // Init function to add listeners for every tinyMCE editor whose target element class is tinymce_answer
    (function(){
        var editors = dmproadmap.utils.tinymce.findEditorsByClassName('tinymce_answer');
        editors.forEach(listenersForEditor);
        // Initialises timeago for each element abbr with class timeago
        $('abbr.timeago').timeago();
    })();
    (function(ctx){
        // function to add listeners for a tinyMCE editor with target element id passed
        ctx.reloadEditorListeners = ctx.reloadEditorListeners || (function(id){
            var editor = dmproadmap.utils.tinymce.findEditorById(id);
            if(editor){
                listenersForEditor(editor);
                $('abbr.timeago').timeago();     
            }
        });
    })(define('dmproadmap.answers.status'));
});