const onChangeQuestionFormat = (e) => {
  const source = e.target;
  const selected = source.value;
  const defaultValue = $(source).closest('form').find('[data-attribute="default_value"]');
  const questionOptions = $(source).closest('form').find('[data-attribute="question_options"]');
  switch (selected) {
    case '1':
      questionOptions.hide();
      defaultValue.show();
      defaultValue.find('[data-attribute="textfield"]').hide();
      defaultValue.find('[data-attribute="textarea"]').show();
      break;
    case '2':
      questionOptions.hide();
      defaultValue.show();
      defaultValue.find('[data-attribute="textarea"]').hide();
      defaultValue.find('[data-attribute="textfield"]').show();
      break;
    case '3':
    case '4':
    case '5':
    case '6':
      defaultValue.hide();
      questionOptions.show();
      break;
    default :
      break;
  }
};

export { onChangeQuestionFormat as default };

