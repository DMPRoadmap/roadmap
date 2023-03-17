import { Tinymce } from '../../../utils/tinymce';

$(() => {
  if ($('#template_user_guidance_research_outputs').length > 0) {
    Tinymce.init({ selector: '#template_user_guidance_research_outputs' });
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