import { isObject } from '../../utils/isType';

// Attach handlers for changing the conditions of a question
export default function updateConditions(id) {
  const parent = $(`#${id}.question_container`);
  const content = parent.find('#content');
  content.html('');
  const addLogicButton = parent.find('a.add-logic[data-remote="true"]');

  // display conditions already saved
  if (addLogicButton.length > 0) {
    if (addLogicButton.attr('data-loaded').toString() === 'true') {
      addLogicButton.trigger('click');
    }
  }

  // set up selectpicker select boxes for condition options
  const setSelectPicker = () => {
    $('.selectpicker.narrow').selectpicker({ width: 120 });
    $('.selectpicker.regular').selectpicker({ width: 150 });
  };

  // test if a webhook is selected and set up if so
  const allowWebhook = (selectObject, webhook = false) => { // webhook false => new condition
    const condition = $(selectObject).closest('.condition-partial');
    if (webhook === false) {
      if ($(selectObject).val() === 'add_webhook') { // condition type is webhook
        condition.find('.pseudo-webhook-btn').trigger('click');
      } else { // condition type is remove
        condition.find('.remove-dropdown').show();
        condition.find('.webhook-replacement').hide();
      }
    } else { // loading already saved conditions
      // populate webhook inputs
      const nameString = condition.find('select.action-type').attr('name');
      const nameStart = nameString.substring(0, nameString.length - 13);
      const fields = ['name', 'email', 'subject', 'message'];
      fields.forEach((field, idx) => {
        let inputType = 'input';
        if (idx === 3) {
          inputType = 'textarea';
        }
        condition.find(`${inputType}[name="${nameStart}[webhook-${field}]"]`).val(JSON.parse(webhook)[`${field}`]);
      });
      $(selectObject).on('change', () => {
        allowWebhook(selectObject, undefined);
      });
    }
    // allow discarding of webhook data on click of exit symbol
    const exit = condition.find('.discard');
    exit.on('click', () => {
      exit.closest('.modal').find('.form-control').each((idx, field) => {
        $(field).val('');
      });
    });
    if ($(selectObject).val() === 'add_webhook') {
      // display edit email section
      condition.find('.remove-dropdown').hide();
      condition.find('.webhook-replacement').show();
      condition.find('.webhook-replacement').on('click', (event) => {
        event.preventDefault();
        condition.find('.pseudo-webhook-btn').trigger('click');
      });
    }
  };

  // setup when to test for a webhook selected
  const webhookSelected = (selectObject, webhook = false) => {
    if (webhook) { // current list of conditions
      allowWebhook(selectObject, webhook);
    } else { // new condition is added
      $(selectObject).on('change', () => {
        allowWebhook(selectObject, undefined);
      });
    }
  };

  // webhook form
  const webhookForm = (webhooks = false, selectObject = false) => {
    if (selectObject === false) {
      $('.selectpicker.action-type').each((idx, selectObject2) => {
        webhookSelected(selectObject2, webhooks[idx]);
      });
    } else {
      webhookSelected(selectObject, undefined);
    }
  };

  // display conditions (editing) upon click of 'Add Conditions'
  parent.on('ajax:success', 'a.add-logic[data-remote="true"]', (e) => {
    addLogicButton.attr('data-loaded', 'true');
    addLogicButton.addClass('disabled');
    addLogicButton.blur();
    addLogicButton.text('Conditions');
    if (isObject(content)) {
      content.html(e.detail[0].container);
    }
    setSelectPicker();
    webhookForm(e.detail[0].webhooks, undefined);
  });

  // add condition
  parent.on('ajax:success', 'a.add-condition[data-remote="true"]', (e) => {
    const conditionList = $(e.target).closest('#condition-container').find('.condition-list');
    const addDiv = $(e.target).closest('#condition-container').find('.add-condition-div');
    if (isObject(conditionList)) {
      conditionList.attr('data-loaded', 'true');
      conditionList.append(e.detail[0].attachment_partial);
      addDiv.html(e.detail[0].add_link);
      conditionList.attr('data-loaded', 'false');
      setSelectPicker();
      const selectObject = conditionList.find('.selectpicker.action-type').last();
      webhookForm(undefined, selectObject);
    }
  });

  // remove condition
  parent.on('click', '.delete-condition', (e) => {
    e.preventDefault();
    const source = $(e.target).closest('.condition-partial');
    source.empty();
  });
}
