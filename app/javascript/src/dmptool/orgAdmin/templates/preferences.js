import { Tinymce } from '../../../utils/tinymce';

$(() => {
  if ($('#template_user_guidance_output_types').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_output_types' });
  }
  if ($('#template_user_guidance_repositories').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_repositories' });
  }
  if ($('#template_user_guidance_metadata_standards').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_metadata_standards' });
  }
  if ($('#template_user_guidance_licenses').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_licenses' });
  }
});