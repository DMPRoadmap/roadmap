//import { fixture } from '../../node_modules/karma-fixture/lib/fixture';
import { ariatiseForm } from '../utils/ariatiseForm';

describe('ariatiseForm test suite', () => {
  beforeAll(() => fixture.setBase('./fixtures'));

  beforeEach(() => {
    this.form = fixture.load('form.html');
  });

  afterEach(() => {
    fixture.cleanup();
  });

  it('adds an error message section to required fields', () => {
console.log(this.form);
console.log(fixture.el);
console.log(fixture.el.find('input'));

    ariatiseForm(this.form.el.find('form'));
  });
});
