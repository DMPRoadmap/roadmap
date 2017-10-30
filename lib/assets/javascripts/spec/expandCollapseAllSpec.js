import expandCollapseAll from '../utils/expandCollapseAll';

describe('expandCollapseAll test suite', () => {
  beforeAll(() => fixture.setBase('javascripts/spec/fixtures'));

  beforeEach(() => {
    this.form = fixture.load('accordion.html');
    expandCollapseAll({ selector: '#accordion' });
  });

  afterEach(() => {
    fixture.cleanup();
  });

  it('should be able to expand all sections when all are either expanded or collapsed', () => {
    // Collapse all of the sections
    //    - click on 'collapse all' should have no effect
    //    - click on 'expand all' should expand all sections
    $('#accordion div.panel-collapse').collapse('hide');
    expect($('.in').length === 0);
    $('a[data-toggle-direction="hide"]').click();
    expect($('.in').length === 0);
    $('a[data-toggle-direction="show"]').click();
    expect($('.in').length === 3);

    // Expand all of the sections
    //    - click on 'expand all' should have no effect
    //    - click on 'collapse all' should collapse all sections
    $('#accordion div.panel-collapse').collapse('show');
    expect($('.in').length === 3);
    $('a[data-toggle-direction="show"]').click();
    expect($('.in').length === 3);
    $('a[data-toggle-direction="hide"]').click();
    expect($('.in').length === 0);
  });

  it('should be able to expand all sections when some are open and some collapsed', () => {
    // Expand 2 of the 3 sections - click 'collapse all' - verify that all are collapsed
    $('#collapseA, #collapseC').collapse('show');
    $('a[data-toggle-direction="hide"]').click();
    expect($('.in').length === 0);

    // Expand 2 of the 3 sections - click 'expand all' - verify that all are expanded
    $('#collapseA, #collapseC').collapse('show');
    $('a[data-toggle-direction="show"]').click();
    expect($('.in').length === 3);
  });
});
