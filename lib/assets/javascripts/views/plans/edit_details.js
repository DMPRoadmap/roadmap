import { Tinymce } from '../../utils/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';
import { MAX_NUMBER_GUIDANCE_SELECTIONS } from '../../constants';

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

  // Keep the modal window's guidance selections in line with selections on the main page
  const syncGuidance = (ctx) => {
    const currentList = $(ctx);
    const otherList = (currentList.attr('id') === 'priority-guidance-orgs' ? $('#other-guidance-orgs') : $('#priority-guidance-orgs'));
    const selections = currentList.find('input[type="checkbox"]:checked').map((i, el) => $(el).val()).get();

    otherList.find('input[type="checkbox"]').each((i, el) => {
      const checkbox = $(el);
      // Toggle the checked flag to match the current guidance list
      if (selections.indexOf(checkbox.val()) >= 0) {
        checkbox.attr('checked');
      } else {
        checkbox.removeAttr('checked');
      }

      // If we have reached the selection limit toggle the disabled flag on the other guidance list
      if (selections.length >= MAX_NUMBER_GUIDANCE_SELECTIONS && !checkbox.is(':checked')) {
        checkbox.attr('disabled', 'disabled');
      } else {
        checkbox.removeAttr('disabled');
      }
    });

    // If we have reached the selection limit toggle the disabled flag on the current guidance list
    if (selections.length >= MAX_NUMBER_GUIDANCE_SELECTIONS) {
      currentList.find('input[type="checkbox"]').each((i, el) => {
        const checkbox = $(el);
        if (el.is(':checked')) {
          checkbox.removeAttr('disabled');
        } else {
          checkbox.attr('disabled', 'disabled');
        }
      });
    }
  };

  $('#other-guidance-orgs').find('input[type="checkbox"]').click((e) => {
    syncGuidance($(e.target).closest('ul'));
  });
  $('#priority-guidance-orgs').find('input[type="checkbox"]').click((e) => {
    syncGuidance($(e.target).closest('ul'));
  });
});

