import debounce from '../utils/debounce';

describe('debounce test suite', () => {
  let functionToDebounce;

  beforeEach(() => {
    functionToDebounce = jasmine.createSpy('My function to debounce');
    jasmine.clock().install();
  });

  afterEach(() => {
    jasmine.clock().uninstall();
  });

  it('functionToDebounce gets called after the time specified', () => {
    const debounced = debounce(functionToDebounce, 1000);

    debounced('foo', 'bar');

    expect(functionToDebounce).not.toHaveBeenCalled();

    jasmine.clock().tick(1001);

    expect(functionToDebounce).toHaveBeenCalled();
    expect(functionToDebounce.calls.first().args[0]).toBe('foo');
    expect(functionToDebounce.calls.first().args[1]).toBe('bar');
  });

  it('functionToDebounce gets cancelled before time elapses', () => {
    const debounced = debounce(functionToDebounce, 1000);

    debounced('foo', 'bar');

    jasmine.clock().tick(999);
    debounced.cancel();
    jasmine.clock().tick(2);

    expect(functionToDebounce).not.toHaveBeenCalled();
  });

  it('functionToDebounce gets called once after the time specified', () => {
    const debounced = debounce(functionToDebounce, 1000);

    debounced('foo', 'bar');
    jasmine.clock().tick(999);
    debounced('foo', 'bar');
    jasmine.clock().tick(999);
    debounced('foo', 'bar');
    jasmine.clock().tick(1001);

    expect(functionToDebounce.calls.count()).toBe(1);
  });

  it('functionToDebounce gets called once after the time specified with args of last invocation', () => {
    const debounced = debounce(functionToDebounce, 1000);

    debounced('foo', 'bar');
    jasmine.clock().tick(999);
    debounced('foo2', 'bar2');
    jasmine.clock().tick(999);
    debounced('foo3', 'bar3');
    jasmine.clock().tick(1001);

    expect(functionToDebounce.calls.count()).toBe(1);
    expect(functionToDebounce.calls.first().args[0]).toBe('foo3');
    expect(functionToDebounce.calls.first().args[1]).toBe('bar3');
  });
});
