import ariatiseForm from './ariatiseForm';

describe('ariatiseForm test suite', () => {
  loadFixtures('form.html');

  beforeEach(() => {
    ariatiseForm($("form"));
  });

  it('expect validation error message blocks', () => {
    expect($("#text2").siblings(".help-block").toExist());
  });

});