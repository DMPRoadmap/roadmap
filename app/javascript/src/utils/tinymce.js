// Import TinyMCE
import tinymce from 'tinymce/tinymce';

// TinyMCE DOM helpers
import 'tinymce/models/dom/';

// TinyMCE toolbar icons
import 'tinymce/icons/default';

// TinyMCE theme
import 'tinymce/themes/silver';

// TinyMCE Plugins
import 'tinymce/plugins/table';
import 'tinymce/plugins/lists';
import 'tinymce/plugins/autoresize';
import 'tinymce/plugins/link';
import 'tinymce/plugins/advlist';

// Other dependencies
import { isObject, isString, isUndefined } from './isType';

// // Configuration extracted from
// // https://www.tinymce.com/docs/advanced/usage-with-module-loaders/
export const defaultOptions = {
  selector: '.tinymce',
  statusbar: true,
  menubar: false,
  toolbar: 'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table',
  plugins: 'table autoresize link advlist lists',
  browser_spellcheck: true,
  advlist_bullet_styles: 'circle,disc,square', // Only disc bullets display on htmltoword
  target_list: false,
  elementpath: false,
  resize: true,
  min_height: 230,
  width: '100%',
  autoresize_bottom_margin: 10,
  branding: false,
  extended_valid_elements: 'iframe[tooltip] , a[href|target=_blank]',
  paste_as_text: true,
  paste_block_drop: true,
  paste_merge_formats: true,
  paste_tab_spaces: 4,
  smart_paste: true,
  paste_data_images: true,
  paste_remove_styles_if_webkit: true,
  paste_webkit_styles: 'none',
  table_default_attributes: {
    border: 1,
  },
  // editorManager.baseURL is not resolved properly for IE since document.currentScript
  // is not supported, see issue https://github.com/tinymce/tinymce/issues/358
  skin_url: '/tinymce/skins/oxide',
  content_css: ['/tinymce/tinymce.css'],
};

/*
 This function determines whether or not the editor is a TinyMCE editor
 */
const isTinymceEditor = (editor) => {
  if (isObject(editor)) {
    return editor.hasOwnProperty('id') && typeof editor.getContainer === 'function';
  } else {
    return false;
  }
};

/*
  This function is invoked after the Tinymce widget is initialized. It moves the
  connection with the label from the hidden field (that the Tinymce writes to
  behind the scenes) to the Tinymce iframe so that screen readers read the correct
  label when the tinymce iframe receives focus.
 */
const attachLabelToIframe = (editor) => {
  if (isTinymceEditor(editor)) {
    const iframe = editor.getContainer().querySelector('iframe');
    const lbl = document.querySelector(`label[for="${editor.id}"]`);

    // If the iframe and label could be found, then set the label's 'for' attribute to the id of the iframe
    if (isObject(iframe) && isObject(lbl)) {
      lbl.setAttribute('for', iframe.getAttribute('id'));
    }
  }
};

export const Tinymce = {
  /*
    Initialises a tinymce editor given the object passed. If a non-valid object is passed,
    the defaultOptions object is used instead
    @param options - An object with tinyMCE properties
  */
  init(options = {}) {
    // If any options were specified, merge them with the default options.
    const opts = {
      ...defaultOptions,
      ...options,
    };

    tinymce.init(opts).then((editors) => {
      if (editors.length > 0) {
        for (const editor of editors) {
          // auto-resize the editor and connect the form label to the TinyMCE iframe
          editor.execCommand('mceAutoResize');
          attachLabelToIframe(editor, editor.id);
        }
      }
    });
  },

  /*
    Finds any tinyMCE editor whose target element/textarea has the className passed
    @param className - A string representing the class name of the tinyMCE editor
    target element/textarea to look for
    @return An Array of tinymce.Editor objects
  */
  findEditorsByClassName(className) {
    if (isString(className)) {
      const elements = Array.from(document.getElementsByClassName(className));
      // Fetch the textarea elements and then return the TinyMCE editors associated with the element ids
      return elements.map((el) => {
        return Tinymce.findEditorById(el.getAttribute('id'));
      });
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
      return tinymce.get(id);
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
    if (editors.length > 0) {
      /* editors.forEach(ed => ed.destroy(false)); */
      for (const editor of editors) {
        if (isTinymceEditor(editor)) {
          editor.destroy(false);
        }
      }
    }
  },
  /*
    Destroy an editor instance whose target element/textarea has HTML id passed. This method
    executes tinymce.Editor.destroy (e.g. https://www.tinymce.com/docs/api/tinymce/tinymce.editor/#destroy) for a successfull id found.
    @return undefined
  */
  destroyEditorById(id) {
    const editor = this.findEditorById(id);
    if (isTinymceEditor(editor)) {
      editor.destroy(false);
    }
  },
};
