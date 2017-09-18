import ariatiseForm from '../../utils/ariatiseForm';

$(() => {
  ariatiseForm({ selector: '#edit_org_details_form' });

  // Validate banner_text area for less than 165 character
  $('#edit_org_details_form').submit(() => {
    if (getStats('org_banner_text').chars > 165) {
      alert(_('Please only enter up to 165 characters, you have used') + ' ' + getStats('org_banner_text').chars + '. ' + _('If you are entering an URL try to use something like http://tinyurl.com/ to make it smaller.'));
      return false;
    }
  });
  $('#org_name').keyup((e) => {
    $('#save_org_submit').attr('aria-disabled', ($(e.currentTarget).val().trim() === '' || $('#org_abbreviation').val().trim() === ''));
  });
  $('#org_abbreviation').keyup((e) => {
    $('#save_org_submit').attr('aria-disabled', ($(e.currentTarget).val().trim() === '' || $('#org_name').val().trim() === ''));
  });
  $('#save_org_submit').attr('aria-disabled', ($('#org_name').val() && ($('#org_name').val().trim() === '' || $('#org_abbreviation').val().trim() === '')));
});
