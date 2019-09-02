import { isObject } from '../../../utils/isType';

// Attach handlers for changing the conditions of a question
export default function updateConditions(id) {
  const parent = $(`#${id}.question_container`);
  const content = parent.find('#content');
  content.html('');
  const addLogicButton = parent.find('a.add-logic[data-remote="true"]');

  // display conditions already saved
  if (addLogicButton.attr('data-loaded').toString() === 'true') {
    addLogicButton.trigger('click');
  }

  // display conditions (editing) upon click of 'Add Logic'
  parent.on('ajax:success', 'a.add-logic[data-remote="true"]', (e, data) => {
    addLogicButton.attr('data-loaded', 'true');
    addLogicButton.css({ cursor: 'auto', 'background-color': '#CCC', border: 'none' });
    if (isObject(content)) {
      content.html(data);
    }
    setSelectPicker();
//    countChecked();
  });

  // add condition
  parent.on('ajax:success', 'a.add-condition[data-remote="true"]', (e, data) => {
    const conditionList = $(e.target).closest('#condition-container').find('.condition-list');
    const addDiv = $(e.target).closest('#condition-container').find('.add-condition-div');
    if (isObject(conditionList)) {
      conditionList.attr('data-loaded', 'true');
      conditionList.append(data.attachment_partial);
      addDiv.html(data.add_link);
      conditionList.attr('data-loaded', 'false');
      setSelectPicker();
    }
  });

  const setSelectPicker = () => {
    $('.selectpicker.narrow').selectpicker({width: 120});
    $('.selectpicker.regular').selectpicker({width: 150});
    $('.selectpicker.wide').selectpicker();
  };

  // const countChecked = () => {
  //   $('#condition-container').find('.condition-partial').each((idx, partial) => {
  //     $(partial).find('.selectpicker.wide').each((condNo, selectObj) => {
  //       $(selectObj).parent().find('button.btn').focusout(() => {
  //         $(selectObj).parent().find('li.selected').each((qnNo, question) => {
  //           $(question).attr
  //         });
  //       }); 
  //     });
  //   });
  // };

  // remove condition
  parent.on('click', '.delete-condition', (e) => {
    e.preventDefault();
    const source = $(e.target).closest('.condition-partial');
    source.empty();
  });
};
