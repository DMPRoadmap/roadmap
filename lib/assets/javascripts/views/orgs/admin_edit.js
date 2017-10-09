// Import TinyMCE
import tinymce from 'tinymce/tinymce';
import { Tinymce } from '../../utils/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';
import { SHOW_ORG_BANNER_MESSAGE } from '../../constants';

$(() => {
  ariatiseForm({ selector: '#edit_org_details_form' });

  // Returns text statistics for the specified editor by id
  const getStats = (id) => {
    const body = tinymce.get(id).getBody();
    const text = tinymce.trim(body.innerText || body.textContent);
    return {
      chars: text.length,
    };
  };

  // Validate banner_text area for less than 165 character
  $('#edit_org_details_form').on('submit', (e) => {
    if (getStats('org_banner_text').chars > 165) {
      $('#org_banner_text').text(SHOW_ORG_BANNER_MESSAGE);
      e.preventDefault();
    }
  });
  /* Initialises an editor for textarea defined above with id org_banner_text */
  Tinymce.init({ selector: '#org_banner_text' });
});

