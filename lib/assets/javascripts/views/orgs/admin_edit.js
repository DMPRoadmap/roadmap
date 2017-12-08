// TODO: we need to be able to swap in the appropriate locale here
import 'number-to-text/converters/en-us';
import { convertToText } from 'number-to-text/index';
import ariatiseForm from '../../utils/ariatiseForm';
import { Tinymce } from '../../utils/tinymce';
import { eachLinks } from '../../utils/links';
import { MAX_NUMBER_ORG_URLS } from '../../constants';

$(() => {
  ariatiseForm({ selector: '#edit_org_details_form' });

  // We only allow up to 3 URLs
  const toggleAddUrlLink = () => {
    if ($('#org-link-section').find('div.org-link').length >= MAX_NUMBER_ORG_URLS) {
      $('a#add-org-link').hide();
    } else {
      $('a#add-org-link').show();
    }
  };

  // Remove a URL
  const removeUrl = (e) => {
    $(e.target).closest('.row').remove();
    toggleAddUrlLink();
  };

  const toggleFeedback = () => {
    if ($('#org_feedback_enabled_true').is(':checked')) {
      $('#feeback-email input, #feeback-email textarea').removeAttr('disabled');
    } else {
      $('#feeback-email input, #feeback-email textarea').attr('disabled', true);
    }
  };

  // Add a URL
  $('a#add-org-link').click(() => {
    const link = $('#org-link-section').find('div.org-link').last();
    const clone = $(link).clone();
    clone.find('input').val('');
    $(clone).find('.remove-org-link').click((e) => {
      removeUrl(e);
    });
    link.after(clone);
    toggleAddUrlLink();
  });

  $('.remove-org-link').click((e) => {
    removeUrl(e);
  });

  $('#edit_org_feedback_form input[type="radio"]').click(() => {
    toggleFeedback();
  });

  // Serialize URLs to JSON for form submission
  $('#edit_org_profile_form').submit(() => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#org_links').val(JSON.stringify(links));
    });
  });

  // Initialises tinymce for any target element with class tinymce_answer
  Tinymce.init({ selector: '#org_feedback_email_msg' });

  // Convert the max number of URLs constant to text and display for user
  $('#max-nbr-urls').text(convertToText(MAX_NUMBER_ORG_URLS).toLowerCase());

  toggleAddUrlLink();
  toggleFeedback();
});
