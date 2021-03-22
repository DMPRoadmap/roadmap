
export const Select2 = {
  init() {
    $('.select-field select, .linked-fragments-select select').select2({
      theme: 'bootstrap4',
    });
    $('.select-field select[data-tags=true], .linked-fragments-select select[data-tags=true]').one('select2:open', () => {
      $('input.select2-search__field').prop('placeholder', 'Select a value or enter a new one.');
    });
  },

};

export default Select2;
