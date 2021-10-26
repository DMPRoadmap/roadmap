const onChangeQuestionFormat = (e) => {
  const source = e.target;
  const selected = source.value;
  const defaultValue = $(source).closest('form').find('[data-attribute="default_value"]');
  const questionOptions = $(source).closest('form').find('[data-attribute="question_options"]');
  const opComment = $(source).closest('form').find('[data-attribute="option_comment"]');
  const dataSchema = $(source).closest('form').find('[data-attribute="question_schema"]');
  switch (selected) {
  case '1':
    questionOptions.hide();
    opComment.hide();
    dataSchema.hide();
    defaultValue.show();
    defaultValue.find('[data-attribute="textfield"]').hide();
    defaultValue.find('[data-attribute="textarea"]').show();
    break;
  case '2':
    questionOptions.hide();
    opComment.hide();
    dataSchema.hide();
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
    dataSchema.hide();
    opComment.show();
    break;
  case '7':
    defaultValue.hide();
    questionOptions.hide();
    dataSchema.hide();
    opComment.show();
    break;
  case '8':
    defaultValue.hide();
    questionOptions.hide();
    dataSchema.hide();
    opComment.hide();
    break;
  case '9':
    questionOptions.hide();
    opComment.hide();
    dataSchema.show();
    defaultValue.hide();
    break;
  default:
    break;
  }
};

export { onChangeQuestionFormat as default };
