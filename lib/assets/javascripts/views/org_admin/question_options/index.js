export default (context) => {
  $(`#${context} .delete_question_option`).on('click', (e) => {
    e.preventDefault();
    const source = $(e.target).closest('[data-attribute="question_option"]');
    source.find('.destroy-question-option').val(true);
    source.hide();
    // $(source).closest('[data-attribute="question_option"]').remove();
  });
  $(`#${context} .new_question_option`).on('click', (e) => {
    e.preventDefault();
    const source = e.target;
    const last = $(source).closest('[data-attribute="question_options"]').find('[data-attribute="question_option"]').last();
    const cloned = last.clone(true);
    const array = $(cloned).find('[id$="_number"]').prop('id').match(/_[\d]_+/);
    if (array) {
      const index = Number(array[0].replace(/_/g, ''));
      // Reset values for the new cloned inputs
      cloned.find('[id$="_number"]').val(index + 2);
      cloned.find('[id$="_text"]').val('');
      cloned.find('[id$="_is_default"]').prop('checked', false);
      cloned.find('[id$="__destroy"]').val(false);
      cloned.find('input').each((i, el) => {
        const target = $(el);
        const id = target.prop('id').replace(/_[\d]+_/g, `_${index + 1}_`);
        const name = target.prop('name').replace(/\[[\d]+\]/g, `[${index + 1}]`);
        target.prop('id', id);
        target.prop('name', name);
      });
      last.after(cloned);
      cloned.show();
    }
  });
};

