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
  const syncGuidance = () => {
    const choices = $('#priority-guidance-orgs, #other-guidance-orgs').find('input[type="checkbox"]:checked')
      .map((i, el) => $(el).val()).get()
      .filter((v, i, a) => a.indexOf(v) === i);

    $('#priority-guidance-orgs, #other-guidance-orgs').find('input[type="checkbox"]').each((i, el) => {
      const target = $(el);
      if (choices.indexOf(target.val()) >= 0) {
        target.attr('checked');
      } else {
        target.removeAttr('checked');

        // Disable the checkbox if it is unchecked and the user has already selected the max
        if (choices.length >= MAX_NUMBER_GUIDANCE_SELECTIONS) {
          target.attr('disabled', 'disabled');
        } else {
          target.removeAttr('disabled');
        }
      }
    });
  };

  $('#other-guidance-orgs').find('input[type="checkbox"]').click(syncGuidance);
  $('#priority-guidance-orgs').find('input[type="checkbox"]').click(syncGuidance);
});

