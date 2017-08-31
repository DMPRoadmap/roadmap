import { Tinymce } from './tinymce';

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
  // TODO
});

describe('destroyEditorsById test suite', () => {
  // TODO
});

