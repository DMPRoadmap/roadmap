import { initAutocomplete } from '../../app/javascript/src/utils/autoComplete';

describe('autocomplete', () => {
  afterEach(() => $('body').empty());

  it('keeps the selected organisation record in the hidden field', () => {
    $('body').append(`
      <form>
        <input id="org_name" value="Example University">
        <input id="org_crosswalk" value='[{"name":"Example University","id":42}]'>
        <input id="org_sources" value='["Example University"]'>
        <input class="autocomplete-result" type="hidden">
        <div id="org_ui-front"></div>
      </form>
    `);

    initAutocomplete('#org_name');

    expect($('.autocomplete-result').val()).toBe('{"name":"Example University","id":42}');
  });
});
