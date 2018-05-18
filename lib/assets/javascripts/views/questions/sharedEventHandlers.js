const onChangeQuestionFormat = (e) => {
  const source = e.target;
  const selected = source.value;
  const defaultValue = $(source).closest('form').find('[data-attribute="default_value"]');
  const questionOptions = $(source).closest('form').find('[data-attribute="question_options"]');
  const opComment = $(source).closest('form').find('[data-attribute="option_comment"]');
  switch (selected) {
    case '1':
      questionOptions.hide();
      opComment.hide();
      defaultValue.show();
      defaultValue.find('[data-attribute="textfield"]').hide();
      defaultValue.find('[data-attribute="textarea"]').show();
      break;
    case '2':
      questionOptions.hide();
      opComment.hide();
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
      opComment.show();
      break;
    case '7':
      defaultValue.hide();
      questionOptions.hide();
      opComment.show();
      break;
    default :
      break;
  }
};

export { onChangeQuestionFormat as default };
