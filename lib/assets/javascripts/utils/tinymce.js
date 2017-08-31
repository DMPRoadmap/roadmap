// Import TinyMCE
import tinymce from 'tinymce/tinymce';
// Import TinyMCE theme
import 'tinymce/themes/modern/theme';
// Plugins
import 'tinymce/plugins/table';
import 'tinymce/plugins/autoresize';
import 'tinymce/plugins/link';
import 'tinymce/plugins/paste';
import 'tinymce/plugins/advlist';
// Other dependencies
import { isObject, isString } from './isType';

// Configuration extracted from https://www.tinymce.com/docs/advanced/usage-with-module-loaders/
require.context(
  'file-loader?name=./javascripts/[path][name].[ext]&context=node_modules/tinymce!tinymce/skins',
  true,
  /.*/,
);

export const defaultOptions = {
  selector: '.tinymce',
  statusbar: false,
  menubar: false,
  toolbar: 'bold italic | bullist numlist | link | table',
  plugins: 'table autoresize link paste advlist',
  advlist_bullet_styles: 'circle,disc,square', // Only disc bullets display on htmltoword
  target_list: false,
  autoresize_min_height: 130,
  autoresize_bottom_margin: 10,
  extended_valid_elements: 'iframe[tooltip] , a[href|target=_blank]',
  paste_auto_cleanup_on_paste: true,
  paste_remove_styles: true,
  paste_retain_style_properties: 'none',
  paste_convert_middot_lists: true,
  paste_remove_styles_if_webkit: true,
  paste_remove_spans: true,
  paste_strip_class_attributes: 'all',
  table_default_attributes: {
    border: 1,
  },
};

export const Tinymce = {
  /*
    Initialises a tinymce editor given the object passed. If a non-valid object is passed,
    the defaultOptions object is used instead
    @param options - An object with tinyMCE properties
  */
  init(options = {}) {
    if (isObject(options)) {
      tinymce.init($.extend(true, defaultOptions, options));
    } else {
      tinymce.init(defaultOptions);
    }
  },
  /*
    Finds any tinyMCE editor whose target element/textarea has the className passed
    @param className - A string representing the class name of the tinyMCE editor
    target element/textarea to look for
    @return An Array of tinymce.Editor objects
  */
  findEditorsByClassName(className) {
    if (isString(className)) {
      return tinymce.editors.reduce((acc, e) => {
        if ($(e.getElement()).hasClass(className)) {
          return acc.concat([e]);
        }
        return acc;
      }, []);
    }
    return [];
  },
  /*
    Finds a tinyMCE editor whose target element/textarea has the id passed
    @param id - A string representing the id of the tinyMCE editor target
    element/textarea to look for
    @return tinymce.Editor object, otherwise undefined
  */
  findEditorById(id) {
    if (isString(id)) {
      return tinymce.editors.find(el => el.id === id);
    }
    return undefined;
  },
  /*
    Destroy every editor instance whose target element/textarea has the className passed. This
    method executes for each editor the method defined at tinymce.Editor.destroy (e.g. https://www.tinymce.com/docs/api/tinymce/tinymce.editor/#destroy).
    @param className - A string representing the class name of the tinyMCE editor 
    target element/textarea to look for
    @return undefined
  */
  destroyEditorsByClassName(className) {
    const editors = this.findEditorsByClassName(className);
    editors.forEach(ed => ed.destroy());
  },
  /*
    Destroy an editor instance whose target element/textarea has HTML id passed. This method
    executes tinymce.Editor.destroy (e.g. https://www.tinymce.com/docs/api/tinymce/tinymce.editor/#destroy) for a successfull id found.
    @return undefined
  */
  destroyEditorsById(id) {
    const editor = this.findEditorById(id);
    if (editor) {
      editor.destroy();
    }
  },
};
