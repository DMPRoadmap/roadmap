$(() => {
  // Add 'target="_blank"' to any links in the annotation/guidance sections,
  // question text and example answer text
  const addTargetBlank = (el) => {
    const link = $(el);
    if (!link.attr('target')) {
      link.attr('target', '_blank');
    }
  };

  // Write plan - guidance/annotation sections
  $('#plan-guidance-tab .panel-body p > a, #plan-guidance-tab .panel-body ul > li > a').each((i, el) => addTargetBlank(el));
  // Write plan - question text
  $('#new_answer .form-group p > a, #new_answer .form-group ul > li > a').each((i, el) => addTargetBlank(el));
  // Write plan - example answer text
  $('#new_answer .panel-body p > a, #new_answer .panel-body ul > li > a').each((i, el) => addTargetBlank(el));
});
