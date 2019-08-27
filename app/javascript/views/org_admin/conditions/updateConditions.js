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
    console.log('add logic clicked');
    addLogicButton.attr('data-loaded', 'true');
    addLogicButton.css({ cursor: 'auto', 'background-color': '#CCC', border: 'none' });
    if (isObject(content)) {
      content.html(data);
    }
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
    }
  });

  // remove condition
  parent.on('click', '.delete-condition', (e) => {
    e.preventDefault();
    const source = $(e.target).closest('.condition-partial');
    source.empty();
  });
};
