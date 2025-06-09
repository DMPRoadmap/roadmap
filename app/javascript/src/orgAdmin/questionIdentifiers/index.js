export default (context) => {
  $(`#${context} .delete_question_identifier`).on('click', (e) => {
    e.preventDefault();
    const source = $(e.target).closest('[data-attribute="question_identifier"]');
    source.find('.destroy-question-identifier').val(true);
    source.next().remove();
    source.remove();
  });
  
  $(`#${context} .new_question_identifier`).on('click', (ev) => {
    ev.preventDefault();
    const source = ev.target;
    const last = $(source).closest('[data-attribute="question_identifier"]').find('[data-attribute="question_identifier"]').last();
    const cloned = last.clone(true);
    const array = $(cloned).find('[id$="_value"]').prop('id').match(/_[\d]*?_+/);
   

    if (array) {
    const index = Number(array[0].replace(/_/g, ''));
    // Reset values for the new cloned inputs
      cloned.find('[id$="_value"]').val('');
      cloned.find('[id$="_name"]').val('');
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
