// Import TinyMCE
import tinymce from 'tinymce/tinymce';
// Import TinyMCE theme
import 'tinymce/themes/modern/theme';
// Plugins
import 'tinymce/plugins/table';
import 'tinymce/plugins/lists';
import 'tinymce/plugins/autoresize';
import 'tinymce/plugins/link';
import 'tinymce/plugins/paste';
import 'tinymce/plugins/advlist';
// Other dependencies
import { isObject, isString } from './isType';

// Configuration extracted from https://www.tinymce.com/docs/advanced/usage-with-module-loaders/
require.context(
  'file-loader?name=./stylesheets/[path][name].[ext]&context=node_modules/tinymce!tinymce/skins',
  true,
  /.*/,
);

export const defaultOptions = {
  selector: '.tinymce',
  statusbar: false,
  menubar: false,
  toolbar: 'bold italic | bullist numlist | link | table',
  plugins: 'table autoresize link paste advlist lists',
  advlist_bullet_styles: 'circle,disc,square', // Only disc bullets display on htmltoword
  target_list: false,
  autoresize_min_height: 130,
  autoresize_bottom_margin: 10,
  branding: false,
  extended_valid_elements: 'iframe[tooltip] , a[href|target=_blank]',
  paste_auto_cleanup_on_paste: true,
  paste_remove_styles: true,
  paste_retain_style_properties: 'none',
  paste_convert_middot_lists: true,
  paste_remove_styles_if_webkit: true,
  paste_remove_spans: true,
  paste_strip_class_attributes: 'all',
  max_height: 350,
  table_default_attributes: {
    border: 1,
  },
  skin_url: '/stylesheets/skins/lightgray', // editorManager.baseURL is not resolved properly for IE since document.currentScript is not supported, see issue https://github.com/tinymce/tinymce/issues/3584
};
/*
  This function is invoked anytime a new editor is initialised (e.g. Tinymce.init())
  and shrinks a tinymce editor to the minimum height specified at autoresize_min_height
  editor's settings. Since there are cases that tinymce editor is loaded in the DOM
  but has display:none style, the iframe associated gets the height of the screen's device
  and using this function there is no need to wait until the tinymce gains focus to be autoresized.
*/
const resizeEditors = (editors) => {
  editors.forEach((editor) => {
    $(editor.iframeElement).height(editor.settings.autoresize_min_height);
  });
};

export const Tinymce = {
  /*
    Initialises a tinymce editor given the object passed. If a non-valid object is passed,
    the defaultOptions object is used instead
    @param options - An object with tinyMCE properties
  */
  init(options = {}) {
    if (isObject(options)) {
      tinymce.init($.extend(true, defaultOptions, options)).then(resizeEditors);
    } else {
      tinymce.init(defaultOptions).then(resizeEditors);
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
    editors.forEach(ed => ed.destroy(false));
  },
  /*
    Destroy an editor instance whose target element/textarea has HTML id passed. This method
    executes tinymce.Editor.destroy (e.g. https://www.tinymce.com/docs/api/tinymce/tinymce.editor/#destroy) for a successfull id found.
    @return undefined
  */
  destroyEditorById(id) {
    const editor = this.findEditorById(id);
    if (editor) {
      editor.destroy(false);
    }
  },
};
