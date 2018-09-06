import { Tinymce } from '../../utils/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';
import getConstant from '../../constants';

$(() => {
  Tinymce.init();
  $('#is_test').click((e) => {
    $('#plan_visibility').val($(e.target).is(':checked') ? 'is_test' : 'privately_visible');
  });
  ariatiseForm({ selector: '.edit_plan' });

  const showHideDataContact = (el) => {
    if ((el).is(':checked')) {
      $('div.data-contact').fadeOut();
    } else {
      $('div.data-contact').fadeIn();
    }
  };

  $('#show_data_contact').click((e) => {
    showHideDataContact($(e.currentTarget));
  });
  showHideDataContact($('#show_data_contact'));

  // Toggle the disabled flags
  const toggleCheckboxes = (selections) => {
    $('#priority-guidance-orgs, #other-guidance-orgs').find('input[type="checkbox"]').each((i, el) => {
      const checkbox = $(el);
      if (selections.length >= getConstant('MAX_NUMBER_GUIDANCE_SELECTIONS')) {
        if (checkbox.is(':checked')) {
          checkbox.removeAttr('disabled');
        } else {
          checkbox.prop('disabled', true);
        }
      } else {
        checkbox.prop('disabled', false);
      }
    });
  };

  // Keep the modal window's guidance selections in line with selections on the main page
  const syncGuidance = (ctx) => {
    const currentList = $(ctx);
    const otherList = (currentList.attr('id') === 'priority-guidance-orgs' ? $('#other-guidance-orgs') : $('#priority-guidance-orgs'));
    const selections = currentList.find('input[type="checkbox"]:checked').map((i, el) => $(el).val()).get();
    otherList.find('input[type="checkbox"]').each((i, el) => {
      const checkbox = $(el);
      // Toggle the checked flag to match the current guidance list
      if (selections.indexOf(checkbox.val()) >= 0) {
        checkbox.prop('checked', true);
      } else {
        checkbox.prop('checked', false);
      }
    });
    toggleCheckboxes(selections);
  };

  $('#other-guidance-orgs').find('input[type="checkbox"]').click((e) => {
    const checkbox = $(e.target);
    // Since this is the modal window, copy any selections over to the priority list
    if (checkbox.is(':checked')) {
      const priorityList = $('#priority-guidance-orgs');
      if (priorityList.find(`input[value="${checkbox.val()}"]`).length <= 0) {
        const li = checkbox.closest('li');
        // If its a subgroup copy the whole group otherwise just copy the line
        if (li.children('.sublist').length > 0) {
          priorityList.append(li.closest('ul').parent().clone());
        } else {
          priorityList.append(li.clone());
        }
      }
    }
    syncGuidance(checkbox.closest('ul[id]'));
  });
  $('#priority-guidance-orgs').find('input[type="checkbox"]').click((e) => {
    syncGuidance($(e.target).closest('ul[id]'));
  });

  toggleCheckboxes($('#priority-guidance-orgs input[type="checkbox"]:checked').map((i, el) => $(el).val()).get());
});

