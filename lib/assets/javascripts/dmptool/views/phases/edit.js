$(() => {
  // Add 'target="_blank"' to any links in the annotation/guidance sections, 
  // question text and example answer text
  $('#plan-guidance-tab .panel-body p > a, #new_answer .form-group p > a, #new_answer .panel-body p > a').each((i, el) => {
    const link = $(el);
    if (!link.attr('target')) {
      link.attr('target', '_blank');
    }
  });
});
