import { updateSectionProgress, getQuestionDiv } from '../utils/sectionUpdate';

$(() => {
  if ($('.answering-phase').length > 0) { // check phase has (standard) questions
    // hide already removed questions on load
    const removeData = $('#progress-data').data('remove');
    removeData.forEach((id) => {
      getQuestionDiv(id).hide();
    });

    // update progress on section panel on load
    const sectionsInfo = $('#progress-data').data('sections');
    sectionsInfo.forEach((sectionInfo) => {
      const forms = $(`#collapse-${sectionInfo.id}`).find('form');
      if (forms.length > 0) { // ensure current phase
        updateSectionProgress(sectionInfo.id, sectionInfo.no_ans, sectionInfo.no_qns);
      }
    });
  }
});
