import ariatiseForm from '../utils/ariatiseForm';

describe('ariatiseForm test suite', () => {
  beforeAll(() => fixture.setBase('javascripts/spec/fixtures'));

  beforeEach(() => {
    this.submitButton = '[type="submit"]';
    $('body').html(fixture.load('form.html'));
    ariatiseForm({ selector: `#${$('form').attr('id')}` });
    // Override the form submission, we are just going to validate the ariatisation of the form
    $('form').submit((e) => { e.preventDefault(); });
  });

  afterEach(() => {
    fixture.cleanup();
    $('body').html('');
  });
  it('adds an error message section to fields with `aria-required="true"` or `data-validation="[type]"`', () => {
    $.each($('input'), (idx, el) => {
      const block = $(`#${$(el).attr('aria-describedby')}`);
      if ($(el).attr('aria-required') === 'true' || $(el).attr('data-validation')) {
        // The error message should be present but not visible yet
        expect(block.length).toEqual(1);
        expect($(block)).not.toBeVisible();
      } else {
        expect(block.length).toEqual(0);
      }
    });
  });
  it('invalid data causes errors to appear', () => {
    const spyEvent = spyOnEvent(this.submitButton, 'click');
    $(this.submitButton).trigger('click');
    expect('click').toHaveBeenPreventedOn(this.submitButton);
    expect(spyEvent).toHaveBeenPrevented();

    // Only the aria-required="true" errors should be visible
    $.each($('input[aria-required="true"]'), (idx, el) => {
      const block = $(`#${$(el).attr('aria-describedby')}`);
      // The error message should be present but not visible yet
      expect($(block)).toBeVisible();
    });

    // Inputs without aria-required="true" errors should not be visible
    $.each($('input').not('[aria-required="true"]').not('[type="radio"]'), (idx, el) => {
      const block = $(`#${$(el).attr('aria-describedby')}`);
      // The error message should be present but not visible yet
      expect($(block)).not.toBeVisible();
    });
  });
  it('text validation is working', () => {
    ['#text-required'].forEach((selector) => {
      const block = $(`#${$(selector).attr('aria-describedby')}`);
      $(selector).val('');
      $(this.submitButton).click();
      expect(block).toBeVisible();

      $(selector).val('testing');
      $(this.submitButton).click();
      expect(block).not.toBeVisible();
    });
  });

  it('email validation is working', () => {
    ['#email-required', '#email-not-required-with-validation'].forEach((selector) => {
      const block = $(`#${$(selector).attr('aria-describedby')}`);
      $(selector).val('abcd1234');
      $(this.submitButton).click();
      expect(block).toBeVisible();

      $(selector).val('abcd1234@test.org');
      $(this.submitButton).click();
      expect(block).not.toBeVisible();
    });
  });

  it('password validation is working', () => {
    ['#password-required', '#password-not-required-with-validation'].forEach((selector) => {
      const block = $(`#${$(selector).attr('aria-describedby')}`);
      $(selector).val('abc');
      $(this.submitButton).click();
      expect(block).toBeVisible();

      $(selector).val('abcd1234');
      $(this.submitButton).click();
      expect(block).not.toBeVisible();
    });
  });

  it('radio validation is working', () => {
    ['[name="radio-required"][aria-required="true"]'].forEach((selector) => {
      const block = $(`#${$(selector).attr('aria-describedby')}`);
      $(`[name="${$(selector).attr('name')}"][value="a"]`).removeAttr('checked');
      $(this.submitButton).click();
      expect(block).toBeVisible();

      $(`[name="${$(selector).attr('name')}"][value="a"]`).attr('checked', true);
      $(this.submitButton).click();
      expect(block).not.toBeVisible();
    });
  });
});
