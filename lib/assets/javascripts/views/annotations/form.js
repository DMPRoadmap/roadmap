import { Tinymce } from '../../utils/tinymce';

export default (context) => {
  Tinymce.init({ selector: `#${context} .annotation` });
};
