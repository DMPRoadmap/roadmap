$(() => {
  $('.delete_question_option').on('click', (e) => {
    e.preventDefault();
    const source = e.target;
    $(source).closest('[data-attribute="question_option"]').hide();
  });
  $('.new_question_option').on('click', (e) => {
    e.preventDefault();
    const source = e.target;
    const last = $(source).closest('[data-attribute="question_options"]').find('[data-attribute="question_option"]').last();
    const cloned = last.clone(true);
    const array = $(cloned).find('[id$="_number"]').prop('id').match(/[^\d]*(\d)+[^$]*/);
    if (array) {
      const index = Number(array[1]);
      // Reset values for the new cloned inputs
      cloned.find(`[id$="${index}_number"]`).val(index + 2);
      cloned.find(`[id$=${index}_text]`).val('');
      cloned.find(`[id$=${index}_is_default]`).prop('checked', false);
      cloned.find(`[id$="${index}__destroy"]`).val(false);
      cloned.find('input').each((i, el) => {
        // Rename id and name for the cloned inputs
        $(el).prop('id', $(el).prop('id').replace(/_\d+_/g, `_${index + 1}_`));
        $(el).prop('name', $(el).prop('name').replace(/\[\d+\]/g, `[${index + 1}]`));
      });
      last.after(cloned);
      cloned.show();
    }
  });
});

