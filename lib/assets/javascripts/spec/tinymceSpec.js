import { Tinymce } from '../utils/tinymce';

beforeEach(() => {
  $('body').append('<textarea class="test" id="test1"></textarea>');
  $('body').append('<textarea class="test" id="test2"></textarea>');
  Tinymce.init({ selector: '.test' });
});

describe('findEditorsByClassName test suite', () => {
  it('expect two editors with class name test', () => expect(Tinymce.findEditorsByClassName('test').length).toBe(2));
  it('expect zero editors with class name whatever', () => expect(Tinymce.findEditorsByClassName('whatever').length).toBe(0));
});

describe('findEditorById test suite', () => {
  it('expect editor with id test1 to be defined', () => expect(Tinymce.findEditorById('test1')).toBeDefined());
  it('expect editor with id test2 to be defined', () => expect(Tinymce.findEditorById('test2')).toBeDefined());
  it('expect editor with id whatever to be undefined', () => expect(Tinymce.findEditorById('whatever')).not.toBeDefined());
});

describe('destroyEditorsByClassName test suite', () => {
  it('expect remaining two editors', () => {
    Tinymce.destroyEditorsByClassName('whatever');
    expect(Tinymce.findEditorsByClassName('test').length).toBe(2);
  });
  it('expect remaining zero editors', () => {
    Tinymce.destroyEditorsByClassName('test');
    expect(Tinymce.findEditorsByClassName('test').length).toBe(0);
  });
});

describe('destroyEditorsById test suite', () => {
  it('expect remaining two editors', () => {
    Tinymce.destroyEditorById('test3');
    expect(Tinymce.findEditorsByClassName('test').length).toBe(2);
  });
  it('expect remaining one editor', () => {
    Tinymce.destroyEditorById('test1');
    expect(Tinymce.findEditorsByClassName('test').length).toBe(1);
  });
  it('expect remaining zero editors', () => {
    Tinymce.destroyEditorById('test1');
    Tinymce.destroyEditorById('test2');
    expect(Tinymce.findEditorsByClassName('test').length).toBe(0);
  });
});

afterEach(() => {
  $('body').html('');
});

