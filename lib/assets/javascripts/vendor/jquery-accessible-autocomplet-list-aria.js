$(document).ready(function(){

   /*
    * jQuery accessible and keyboard-enhanced autocomplete list
    * Website: http://a11y.nicolas-hoffmann.net/autocomplet-list/
    * License MIT: https://github.com/nico3333fr/jquery-accessible-autocomplete-list-aria/blob/master/LICENSE
    */
   // loading combobox ------------------------------------------------------------------------------------------------------------
   // init
   var $js_combobox = $('.js-combobox'),
       $body = $('body'),
       default_text_help = 'Use tabulation (or down) key to access and browse suggestions after input. Confirm your choice with enter key, or esc key to close suggestions box.',
       default_class_for_invisible_text = 'invisible',
       suggestion_single = 'There is ',
       suggestion_plural = 'There are ',
       suggestion_word = 'suggestion',
       button_clear_title = 'clear this field',
       button_clear_text = 'X',
       case_sensitive = 'yes',
       min_length = 0, 
       limit_number_suggestions = 666,
       search_option = 'beginning', // or 'containing'
       see_more_text = 'See more results…',
       tablo_suggestions = [];

   if ( $js_combobox.length  ) { // if there are at least one :)
      
      // init
      $js_combobox.each( function(index_combo) {
          var $this = $(this),
              $this_id = $this.attr('id'),
              $label_this = $( 'label[for="' + $this_id + '"]' ),
              index_lisible = index_combo+1,
              options = $this.data()
              $combobox_prefix_class = typeof options.comboboxPrefixClass !== 'undefined' ? options.comboboxPrefixClass + '-' : '',
              $combobox_help_text = typeof options.comboboxHelpText !== 'undefined' ? options.comboboxHelpText : default_text_help,
              $list_suggestions = $( '#' + $this.attr('list') ),
              $combobox_button_title = typeof options.comboboxButtonTitle !== 'undefined' ? options.comboboxButtonTitle : button_clear_title,
              $combobox_button_text = typeof options.comboboxButtonText !== 'undefined' ? options.comboboxButtonText : button_clear_text,
              $combobox_case_sensitive = typeof options.comboboxCaseSensitive !== 'undefined' ? options.comboboxCaseSensitive : case_sensitive,
              tablo_temp_suggestions = [] ;
          
          // input
          $this.attr({
                  'data-number' : index_lisible,
                  'autocorrect' : 'off',
                  'autocapitalize' : 'off',
                  'spellcheck' : 'off',
                  'autocomplete' : 'off',
                  'aria-describedby' : $combobox_prefix_class + 'help-text' + index_lisible,
                  'aria-autocomplete' : 'list',
                  'data-lastval' : '',
                  'aria-owns' : $combobox_prefix_class + 'suggest_' + index_lisible
                });
          // stock into tables
          $list_suggestions.find('option').each( function(index_option, index_element) {
             tablo_temp_suggestions.push(index_element.value);
          });
          if ($combobox_case_sensitive === 'no'){
              // order case tablo_temp_suggestions
              tablo_suggestions[index_lisible] = tablo_temp_suggestions.sort(function(a,b) {
                                                    a = a.toLowerCase();
                                                    b = b.toLowerCase();
                                                    if ( a == b) {
                                                        return 0;
                                                    }
                                                    if ( a > b) {
                                                       return 1;
                                                       }
                                                    return -1;
                                                    });
          }
          else { tablo_suggestions[index_lisible] = tablo_temp_suggestions.sort(); }
          
          // wrap into a container
          $this.wrap('<div class="' + $combobox_prefix_class + 'container js-container" data-combobox-prefix-class="' + $combobox_prefix_class + '"></div>');
          
          var $combobox_container = $this.parent();
          
          // custom datalist/listbox linked to input
          $combobox_container.append( '<div id="'+ $combobox_prefix_class + 'suggest_' + index_lisible + '" class="js-suggest ' + $combobox_prefix_class + 'suggestions"><div role="listbox"></div></div>' );
          $list_suggestions.remove();

          // status zone
          $combobox_container.prepend( '<div id="' + $combobox_prefix_class + 'suggestion-text' + index_lisible + '" class="js-suggestion-text ' + $combobox_prefix_class + 'suggestion-text ' + default_class_for_invisible_text + '" aria-live="assertive"></div>' );
          
          // help text
          $combobox_container.prepend( '<span id="' + $combobox_prefix_class + 'help-text' + index_lisible + '" class="' + $combobox_prefix_class + 'help-text ' + default_class_for_invisible_text + '">' + $combobox_help_text + '</span>' );       
          
          // label id
          $label_this.attr('id', 'label-id-' + $this_id);
          
          // button clear
          $this.after('<button class="js-clear-button ' + $combobox_prefix_class + 'clear-button" aria-label="' + $combobox_button_title + '" title="' + $combobox_button_title + '" aria-describedby="label-id-' + $this_id + '" type="button">' + $combobox_button_text + '</button>');

      });
      
      function do_see_more_option ( ) {
          var $output_content = $('#js-codeit');
          $output_content.html('You have to code a function or a redirection to display more results ;)');
      }
      
      // listeners
      // keydown on field
      $body.on( 'keyup', '.js-combobox', function( event ) {
         var $this = $(this),
             options_combo = $this.data(),
             $container = $this.parent(),
             $form = $container.parents('form'),
             options = $container.data(),
             $combobox_prefix_class = typeof options.comboboxPrefixClass !== 'undefined' ? options.comboboxPrefixClass : '', // no "-"" because already generated
             $suggestions = $container.find('.js-suggest div'),
             $suggestion_list = $suggestions.find('.js-suggestion'),
             $suggestions_text = $container.find('.js-suggestion-text'),
             $combobox_suggestion_single = typeof options_combo.suggestionSingle !== 'undefined' ? options_combo.suggestionSingle : suggestion_single,
             $combobox_suggestion_plural = typeof options_combo.suggestionPlural !== 'undefined' ? options_combo.suggestionPlural : suggestion_plural,
             $combobox_suggestion_word = typeof options_combo.suggestionWord !== 'undefined' ? options_combo.suggestionWord : suggestion_word,
             combobox_min_length = typeof options_combo.comboboxMinLength !== 'undefined' ? Math.abs(options_combo.comboboxMinLength) : min_length,
             $combobox_case_sensitive = typeof options_combo.comboboxCaseSensitive !== 'undefined' ? options_combo.comboboxCaseSensitive : case_sensitive,
             combobox_limit_number_suggestions = typeof options_combo.comboboxLimitNumberSuggestions !== 'undefined' ? Math.abs(options_combo.comboboxLimitNumberSuggestions) : limit_number_suggestions,
             $combobox_search_option = typeof options_combo.comboboxSearchOption !== 'undefined' ? options_combo.comboboxSearchOption : search_option,
             $combobox_see_more_text = typeof options_combo.comboboxSeeMoreText !== 'undefined' ? options_combo.comboboxSeeMoreText : see_more_text,
             index_table = $this.attr('data-number'),
             value_to_search = $this.val(),
             text_number_suggestions = '';

         if ( event.keyCode === 13  ) {
            $form.submit();
         }
         else {
		
              if ( event.keyCode !== 27  ) { // No Escape
          
                 $this.attr( 'data-lastval', value_to_search );
                 // search for text suggestion in the array tablo_suggestions[index_table]
                 var size_tablo = tablo_suggestions[index_table].length,
                     i = 0,
                     counter = 0;
               
                 $suggestions.empty();
				
                 if ( value_to_search != '' && value_to_search.length >= combobox_min_length ){
                     while ( i<size_tablo ) { 
                           if ( counter < combobox_limit_number_suggestions ) {
                               if ( 
                                   (
                                     $combobox_search_option === 'containing' && 
                                     ( $combobox_case_sensitive==='yes' && (tablo_suggestions[index_table][i].indexOf(value_to_search) >= 0) )
                                     ||
                                     ( $combobox_case_sensitive==='no' && (tablo_suggestions[index_table][i].toUpperCase().indexOf(value_to_search.toUpperCase()) >= 0) )
                                   )
                                   ||
                                   (
                                     $combobox_search_option === 'beginning' && 
                                     ( $combobox_case_sensitive==='yes' && tablo_suggestions[index_table][i].substring(0,value_to_search.length) === value_to_search )
                                     ||
                                     ( $combobox_case_sensitive==='no' && tablo_suggestions[index_table][i].substring(0,value_to_search.length).toUpperCase() === value_to_search.toUpperCase() )
                                   )
                                  ) {
                                   $suggestions.append( '<div id="suggestion-' + index_table + '-' + counter + '" class="js-suggestion ' + $combobox_prefix_class + 'suggestion" tabindex="-1" role="option">' + tablo_suggestions[index_table][i] + '</div>' );
                                   counter++;
                               }
                           }
                           i++;
                     }
                     if ( counter >= combobox_limit_number_suggestions ) {
                        $suggestions.append( '<div id="suggestion-' + index_table + '-' + counter + '" class="js-suggestion js-seemore ' + $combobox_prefix_class + 'suggestion" tabindex="-1" role="option">' + $combobox_see_more_text + '</div>' );
                        counter++;
                     }
                     // update number of suggestions
                     if ( counter > 1 ){
                        text_number_suggestions = $combobox_suggestion_plural + counter + ' ' + $combobox_suggestion_word + 's.';
                     }
                     if ( counter === 1 ){
                        text_number_suggestions = $combobox_suggestion_single + counter + ' ' + $combobox_suggestion_word + '.';
                     }
                     if ( counter === 0 ){
                        text_number_suggestions = $combobox_suggestion_single + counter + ' ' + $combobox_suggestion_word + '.';
                     }
                     if ( counter >= 0 ){
                        var text_number_suggestions_default = $suggestions_text.text();
                        if (text_number_suggestions != text_number_suggestions_default) { // @Goestu trick to make it work on all AT
                           suggestions_to_add=$("<p>").text(text_number_suggestions);
                           $suggestions_text.attr('aria-live','polite');
                           $suggestions_text.empty();
                           $suggestions_text.append(suggestions_to_add);
                           }
                        }          

                     }
            
                }
             }
      
      })
      .on('click', function(event) {
          var $target = $(event.target),
              $suggestions_text = $('.js-suggestion-text:not(:empty)'), // if a suggestion text is not empty => suggestion opened somewhere
              $container = $suggestions_text.parents('.js-container'),
              $input_text = $container.find('.js-combobox'),
              $suggestions = $container.find('.js-suggest div');

         // if click outside => close opened suggestions 
         if ( !$target.is('.js-suggestion') && !$target.is('.js-combobox') && $suggestions_text.length) {
             $input_text.val( $input_text.attr('data-lastval') );
             $suggestions.empty();
             $suggestions_text.empty();
             }
      })
      // tab + down management for autocomplete (when list of suggestion)
      .on( 'keydown', '.js-combobox', function( event ) {
         var $this = $(this),
             $container = $this.parent(),
             $input_text = $container.find('.js-combobox'),
             $suggestions = $container.find('.js-suggest div'),
             $suggestion_list = $suggestions.find('.js-suggestion'),
             $suggestions_text = $container.find('.js-suggestion-text'),
             $autorise_tab_options = typeof $this.attr('data-combobox-notab-options') !== 'undefined' ? false : true,
             $first_suggestion = $suggestion_list.first();
          
         if ( ( !event.shiftKey && event.keyCode == 9 && $autorise_tab_options ) || event.keyCode == 40 ) { // tab (if authorised) or bottom
            // See if there are suggestions, and yes => focus on first one
            if ($suggestion_list.length) {
               $input_text.val($first_suggestion.html());
               $suggestion_list.first().focus();
               event.preventDefault();
               }
         }
         if ( event.keyCode == 27 || ($autorise_tab_options === false && event.keyCode == 9 ) ) { // esc or (tab/shift tab + notab option) = close
            $input_text.val( $input_text.attr('data-lastval') );
            $suggestions.empty();
            $suggestions_text.empty();
            if ( event.keyCode == 27) { // Esc prevented only, tab can go :)
               event.preventDefault();
               setTimeout(function(){ $input_text.focus(); }, 300); // timeout to avoid problem in suggestions display
               }
         }
      })
      // tab + down management in list of suggestions
      .on( 'keydown', '.js-suggestion', function( event ) {
         var $this = $(this),
             $container = $this.parents('.js-container'),
             $input_text = $container.find('.js-combobox'),
             $autorise_tab_options = typeof $input_text.attr('data-combobox-notab-options') !== 'undefined' ? false : true,
             $suggestions = $container.find('.js-suggest div'),
             $suggestions_text = $container.find('.js-suggestion-text'),
             $next_suggestion = $this.next(),
             $previous_suggestion = $this.prev();

         if ( event.keyCode == 27 || ($autorise_tab_options === false && event.keyCode == 9 ) ) { // esc or (tab/shift tab + notab option) = close
            if ( event.keyCode == 27) { // Esc prevented only, tab can go :)
               $input_text.val( $input_text.attr('data-lastval') );
               $suggestions.empty();
               $suggestions_text.empty();
               setTimeout(function(){ $input_text.focus(); }, 300); // timeout to avoid problem in suggestions display
               event.preventDefault();
               }
            if ( $autorise_tab_options === false && event.keyCode == 9 ) {
               $suggestions.empty();
               $suggestions_text.empty();
               $input_text.focus();
               }
            }
         if ( event.keyCode == 13 || event.keyCode == 32 ) { // Enter or space
            if ( $this.hasClass('js-seemore') ) {
               $input_text.val($input_text.attr('data-lastval'));
               $suggestions.empty();
               $suggestions_text.empty();
               setTimeout(function(){ $input_text.focus(); }, 300); // timeout to avoid problem in suggestions display
               // go define the function you need when we click the see_more option
               setTimeout(function(){ do_see_more_option(); }, 301); // timeout to avoid problem in suggestions display
               event.preventDefault();
            }
            else {
                  $input_text.val( $this.html() );
                  $input_text.attr('data-lastval', $this.html() );
                  $suggestions.empty();
                  $suggestions_text.empty();
                  setTimeout(function(){ $input_text.focus(); }, 300); // timeout to avoid problem in suggestions display
                  event.preventDefault();
                 }

            }
         if ( ( !event.shiftKey && event.keyCode == 9 && $autorise_tab_options ) || event.keyCode == 40 ) { // tab (if authorised) or bottom
            if ($next_suggestion.length) {
               $input_text.val($next_suggestion.html());
               $next_suggestion.focus();
               }
               else {
                    $input_text.val( $input_text.attr('data-lastval') );
                    if ( !event.shiftKey && event.keyCode == 9 ) { // tab closes the list
                        var e = jQuery.Event("keydown");
                        e.which = 27; // # Some key code value
                        e.keyCode = 27;
                        $this.trigger(e);
                        }
                        else { setTimeout(function(){ $input_text.focus(); }, 300); } // timeout to avoid problem in suggestions display
				 
                    }
            event.preventDefault();
            }

         if ( ( event.shiftKey && event.keyCode == 9  && $autorise_tab_options ) || event.keyCode == 38 ) { // top or Maj+tab (if authorised)
            if ($previous_suggestion.length) {
               $input_text.val($previous_suggestion.html());
               $previous_suggestion.focus();
               }
               else {
                     $input_text.val( $input_text.attr('data-lastval') ).focus();
                    }
            event.preventDefault();
            }
      })
      // clear button
      .on( 'click', '.js-clear-button', function( event ) {
         var $this = $(this),
             $container = $this.parent(),
             $input_text = $container.find('.js-combobox'),
             $suggestions = $container.find('.js-suggest div'),
             $suggestions_text = $container.find('.js-suggestion-text');

         $suggestions.empty();
         $suggestions_text.empty();
         $input_text.val('');
         $input_text.attr( 'data-lastval', '');
      
      })
      .on( 'click', '.js-suggestion', function( event ) {
         var $this = $(this),
             value = $this.html(),
             $container = $this.parents('.js-container'),
             $input_text = $container.find('.js-combobox'),
             $suggestions = $container.find('.js-suggest div'),
             $suggestions_text = $container.find('.js-suggestion-text');
         
         if ( $this.hasClass('js-seemore') ) {
            $suggestions.empty();
            $suggestions_text.empty();
            $input_text.focus();
            // go define the function you need when we click the see_more option
            do_see_more_option( );
            }
            else {
                 $input_text.val(value).focus();
                 $suggestions.empty();
                 $suggestions_text.empty();
                 }
      
      });
   
   
   }

});
