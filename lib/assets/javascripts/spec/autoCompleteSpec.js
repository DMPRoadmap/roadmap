import initAutoComplete from '../utils/autoComplete';

describe('autoComplete test suite', () => {
  beforeAll(() => fixture.setBase('javascripts/spec/fixtures'));

  beforeEach(() => {
    $('body').html(fixture.load('autoComplete.html'));
    initAutoComplete();
    // Override the form submission, we are just going to validate the ariatisation of the form
    $('form').submit((e) => { e.preventDefault(); });
  });

  afterEach(() => {
    fixture.cleanup();
    $('body').html('');
  });
});
