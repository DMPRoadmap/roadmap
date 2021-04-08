
export const Select2 = {
  init(questionId = null) {
    $(`${questionId} .select-field select, .linked-fragments-select select`).select2({
      theme: 'bootstrap4',
    });
  },

};

export default Select2;
