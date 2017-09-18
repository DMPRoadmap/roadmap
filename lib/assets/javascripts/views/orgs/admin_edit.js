// Import TinyMCE
import tinymce from 'tinymce/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';
import { SHOW_ORG_BANNER_MESSAGE } from '../../constants';

// Returns text statistics for the specified editor by id
function getStats(id) {
  const body = tinymce.get(id).getBody();
  const text = tinymce.trim(body.innerText || body.textContent);
  return {
    chars: text.length,
  };
}

$(() => {
  ariatiseForm({ selector: '#edit_org_details_form' });

  // Validate banner_text area for less than 165 character
  $('#edit_org_details_form').on('submit', (e) => {
    if (getStats('org_banner_text').chars > 165) {
      $('#org_banner_text').text(SHOW_ORG_BANNER_MESSAGE);
      e.preventDefault();
    }
  });
});

