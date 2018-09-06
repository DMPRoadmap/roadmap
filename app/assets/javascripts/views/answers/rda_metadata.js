import { isUndefined, isObject } from '../../utils/isType';

$(() => {
  // url for the api we will be querying
  let url = '';

  // key/value lookup for standards
  const descriptions = {};
  // cleaned up structure of the API results
  const minTree = {};
  // keeps track of how many waiting api-requests still need to run
  let noWaiting = 0;


  // prune the min_tree where there are no standards
  // opporates on the principal that no two subjects have the same name
  function removeUnused(name) {
    const num = Object.keys(minTree).find(x => minTree[x].name === name);
    // if not top level standard
    if (isUndefined(num)) {
      // for each top level standard
      Object.keys(minTree).forEach((knum) => {
        const child = Object.keys(minTree[knum].children).find(x =>
          minTree[knum].children[x].name === name);
        if (isObject(child)) {
          delete minTree[knum].children[child];
          $(`.rda_metadata .sub-subject select option[value="${name}"]`).remove();
        }
      });
    } else {
      delete minTree[num];
      // remove min_tree[num] from top-level dropdowns
      $(`.rda_metadata .subject select option[value="${name}"]`).remove();
    }
  }


  function getDescription(id) {
    $.ajax({
      url: url + id.slice(4),
      type: 'GET',
      crossDomain: true,
      dataType: 'json',
    }).done((results) => {
      descriptions[id] = {};
      descriptions[id].title = results.title;
      descriptions[id].description = results.description;
      noWaiting -= 1;
    });
  }


  // init descriptions lookup table based on passed ids
  function initDescriptions(ids) {
    ids.forEach((id) => {
      if (!(id in descriptions)) {
        noWaiting += 1;
        getDescription(id);
      }
    });
  }

  // takes in a subset of the min_tree which has name and standards properties
  // initializes the standards property to the result of an AJAX POST
  function getStandards(name, num, child) {
    // slice -4 from url to remove '/api/'
    noWaiting += 1;
    $.ajax({
      url: `${url.slice(0, -4)}query/schemes`,
      type: 'POST',
      crossDomain: true,
      data: `keyword=${name}`,
      dataType: 'json',
    }).done((result) => {
      if (isUndefined(child)) {
        minTree[num].standards = result.ids;
      } else {
        minTree[num].children[child].standards = result.ids;
      }
      if (result.ids.length < 1) {
        removeUnused(name);
      }
      noWaiting -= 1;
      initDescriptions(result.ids);
    });
  }

  // clean up the data initially returned from the API
  function cleanTree(apiTree) {
    // iterate over api_tree
    Object.keys(apiTree).forEach((num) => {
      minTree[num] = {};
      minTree[num].name = apiTree[num].name;
      minTree[num].children = [];
      if (apiTree[num].children !== undefined) {
        Object.keys(apiTree[num].children).forEach((child) => {
          minTree[num].children[child] = {};
          minTree[num].children[child].name = apiTree[num].children[child].name;
          minTree[num].children[child].standards = [];
          getStandards(minTree[num].children[child].name, num, child);
        });
      }
      // init a standards on top level
      minTree[num].standards = [];
      getStandards(minTree[num].name, num, undefined);
    });
  }


  // create object for typeahead
  function initTypeahead() {
    const data = [];
    const simpdat = [];
    Object.keys(descriptions).forEach((id) => {
      data.push({ value: descriptions[id].title, id });
      simpdat.push(descriptions[id].title);
    });
    const typ = $('.standards-typeahead');
    typ.typeahead({ source: simpdat });
  }

  function initStandards() {
    // for each metadata question, init selected standards according to html
    $('.rda_metadata').each(function () { // eslint-disable-line func-names
      // list of selected standards
      const selectedStandards = $(this).find('.selected_standards .list');
      // form listing of standards
      const formStandards = $(this).next('form').find('#standards');
      // need to pull in the value from frm_stds
      const standardsArray = JSON.parse(formStandards.val());
      // init the data value
      formStandards.data('standard', standardsArray);
      Object.keys(standardsArray).forEach((key) => {
        // add the standard to list
        if (key === standardsArray[key]) {
          selectedStandards.append(`<li class="${key}">${key}<button class="remove-standard"><i class="fa fa-times-circle"></i></button></li`);
        } else {
          selectedStandards.append(`<li class="${key}">${descriptions[key].title}<button class="remove-standard"><i class="fa fa-times-circle"></i></button></li>`);
        }
      });
    });
  }

  function waitAndUpdate() {
    if (noWaiting > 0) {
      // if we are waiting on api responces, call this function in 1 seccond
      setTimeout(waitAndUpdate, 1000);
    } else {
      // update all the dropdowns/ standards explore box (calling on subject
      // will suffice since it will necisarily update sub-subject)
      $('.rda_metadata .subject select').change();
      initStandards();
      initTypeahead();
    }
  }

  // given a subject name, returns the portion of the min_tree applicable
  function getSubject(subjectText) {
    const num = Object.keys(minTree).find(x => minTree[x].name === subjectText);
    return minTree[num];
  }

  // given a subsubject name and an array of children, data, return the
  // applicable child
  function getSubSubject(subsubjectText, data) {
    const child = Object.keys(data).find(x => data[x].name === subsubjectText);
    return data[child];
  }

  function updateSaveStatus(group) {
    // update save/autosave status
    group.next('form').find('fieldset input').change();
  }

  // change sub-subjects and standards based on selected subject
  $('.rda_metadata').on('change', '.subject select', (e) => {
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const subSubject = group.find('.sub-subject select');
    const subjectText = target.find(':selected').text();
    // find subject in min_tree
    const subject = getSubject(subjectText);
    // check to see if this object has no children(and thus it's own standards)
    if (subject.children.length === 0) {
      // hide sub-subject since there's no data for it
      subSubject.closest('div').hide();
      // update the standards display selector
      $('.rda_metadata .sub-subject select').change();
    } else {
      // show the sub-subject incase it was previously hidden
      subSubject.closest('div').show();
      // update the sub-subject display selector
      subSubject.find('option').remove();
      subject.children.forEach((child) => {
        $('<option />', { value: child.name, text: child.name }).appendTo(subSubject);
      });
      // once we have updated the sub-standards, ensure the standards displayed
      // get updated as well
      $('.rda_metadata .sub-subject select').change();
    }
  });

  // change standards based on selected sub-subject
  $('.rda_metadata').on('change', '.sub-subject select', (e) => {
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const subject = group.find('.subject select');
    const subSubject = group.find('.sub-subject select');
    const subjectText = subject.find(':selected').text();
    const subjectData = getSubject(subjectText);
    const standards = group.find('.browse-standards-border');
    let standardsData;
    if (subjectData.children.length === 0) {
      // update based on subject's standards
      standardsData = subjectData.standards;
    } else {
      // update based on sub-subject's standards
      const subsubjectText = subSubject.find(':selected').text();
      standardsData = getSubSubject(subsubjectText, subjectData.children).standards;
    }
    // clear list of standards
    standards.empty();
    // update list of standards
    Object.keys(standardsData).forEach((num) => {
      const standard = descriptions[standardsData[num]];
      standards.append(`<div style="background-color:#EAEAEA;border-radius:3px"><strong>${standard.title}</strong><div style="float:right"><button class="btn btn-primary select_standard" data-standard="${standardsData[num]}">Add Standard</button></br></div><p>${standard.description}</p></div>`);
    });
  });

  // when 'Add Standard' button next to the search is clicked, we need to add
  // this to the user's selected list of standards.
  // update the data and val of hidden standards field in form
  $('.rda_metadata').on('click', '.select_standard_typeahead', (e) => {
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const selected = group.find('ul.typeahead li.active');
    const selectedStandards = group.find('.selected_standards .list');
    // the title of the standard
    const standardTitle = selected.data('value');
    // need to find the standard
    let standard;
    Object.keys(descriptions).forEach((standardId) => {
      if (descriptions[standardId].title === standardTitle) {
        standard = standardId;
      }
    });
    selectedStandards.append(`<li class="${standard}">${descriptions[standard].title}<button class="remove-standard"><i class="fa fa-times-circle"></i></button></li>`);
    const formStandards = group.next('form').find('#standards');
    // get the data for selected standards from the data attribute 'standard'
    // of the hidden field #standards within the answer form
    let frmStdsDat = formStandards.data('standard');
    // need to init data object for first time
    if (typeof frmStdsDat === 'undefined') {
      frmStdsDat = {};
    }
    // init the key to standard id and value to standard.
    // NOTE: is there any point in storing the title or description here?
    // storing the title could make export easier as we wolnt need to query api
    // but queries to the api would be 1 per-standard if we dont store these
    frmStdsDat[standard] = descriptions[standard].title;
    // update data value
    formStandards.data('standard', frmStdsDat);
    // update input value
    formStandards.val(JSON.stringify(frmStdsDat));
    updateSaveStatus(group);
  });

  // when a 'Add standard' button is clicked, we need to add this to the user's
  // selected list of standards
  // update the data and val of hidden standards field in form
  $('.rda_metadata').on('click', '.select_standard', (e) => {
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const selectedStandards = group.find('.selected_standards .list');
    // the identifier for the standard which was selected
    const standard = target.data('standard');
    // append the standard to the displayed list of selected standards
    selectedStandards.append(`<li class="${standard}">${descriptions[standard].title}<button class="remove-standard"><i class="fa fa-times-circle"></i></button></li>`);
    const formStandards = group.next('form').find('#standards');
    // get the data for selected standards from the data attribute 'standard'
    // of the hidden field #standards within the answer form
    let frmStdsDat = formStandards.data('standard');
    // need to init data object for first time
    if (isUndefined(frmStdsDat)) {
      frmStdsDat = {};
    }
    // init the key to standard id and value to standard.
    frmStdsDat[standard] = descriptions[standard].title;
    // update data value
    formStandards.data('standard', frmStdsDat);
    // update input value
    formStandards.val(JSON.stringify(frmStdsDat));
    updateSaveStatus(group);
  });

  // when a 'Remove Standard' button is clicked, we need to remove this from the
  // user's selected list of standards.  Additionally, we need to remove the
  // standard from the data/val fields of standards in hidden form
  $('.rda_metadata').on('click', '.remove-standard', (e) => {
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const listedStandard = target.closest('li');
    const standardId = listedStandard.attr('class');
    // remove the standard from the list
    listedStandard.remove();
    // update the data for the form
    const formStandards = group.next('form').find('#standards');
    const frmStdsDat = formStandards.data('standard');
    delete frmStdsDat[standardId];
    // update data value
    formStandards.data('standard', frmStdsDat);
    // update input value
    formStandards.val(JSON.stringify(frmStdsDat));
    updateSaveStatus(group);
  });

  // show the add custom standard div when standard not listed clicked
  $('.rda_metadata').on('click', '.custom-standard', (e) => {
    e.preventDefault();
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const addStandardDiv = $(group.find('.add-custom-standard'));
    addStandardDiv.show();
  });

  // when this button is clicked, we add the typed standard to the list of
  // selected standards
  $('.rda_metadata').on('click', '.submit_custom_standard', (e) => {
    e.preventDefault();
    const target = $(e.currentTarget);
    const group = target.closest('.rda_metadata');
    const selectedStandards = group.find('.selected_standards .list');
    const standardName = group.find('.custom-standard-name').val();
    selectedStandards.append(`<li class="${standardName}">${standardName}<button class="remove-standard"><i class="fa fa-times-circle"></i></button></li>`);
    const formStandards = group.next('form').find('#standards');
    // get the data for selected standards from the data attribute 'standard'
    // of the hidden field #standards within the answer form
    let frmStdsDat = formStandards.data('standard');
    // need to init data object for first time
    if (typeof frmStdsDat === 'undefined') {
      frmStdsDat = {};
    }
    // init the key to standard id and value to standard.
    frmStdsDat[standardName] = standardName;
    // update data value
    formStandards.data('standard', frmStdsDat);
    // update input value
    formStandards.val(JSON.stringify(frmStdsDat));
    updateSaveStatus(group);
  });


  function initMetadataQuestions() {
    // find all elements with rda_metadata div
    $('.rda_metadata').each((idx, el) => {
      // $(this) is the element
      const sub = $(el).find('.subject select');
      // var sub_subject = $(this).find(".sub-subject select");
      Object.keys(minTree).forEach((num) => {
        $('<option />', { value: minTree[num].name, text: minTree[num].name }).appendTo(sub);
      });
    });
    waitAndUpdate();// $(".rda_metadata .subject select").change();
  }


  // callback from url+subject-index
  // define api_tree and call to initMetadataQuestions
  function subjectCallback(data) {
    // remove unused standards/substandards
    cleanTree(data);
    // initialize the dropdowns/selected standards for the page
    initMetadataQuestions();
  }

  // callback from get request to rda_api_address
  // define url and make a call to url+subject-index
  function urlCallback(data) {
    // init url
    url = data.url;
    // get api_tree structure from api
    $.ajax({
      url: `${url}subject-index`,
      type: 'GET',
      crossDomain: true,
      dataType: 'json',
    }).done((result) => {
      subjectCallback(result);
    });
  }

  // get the url we will be using for the api
  // only do this if page has an rda_metadata div
  if ($('.rda_metadata').length) {
    $.getJSON('/question_formats/rda_api_address', urlCallback);
  }
  // when the autosave or save action occurs, this clears out both the list of
  // selected standards, and the selectors for new standards, as it re-renders
  // the partial.  This "autosave" event is triggered by that JS in order to
  // allow us to know when the save has happened and re-init the question
  $('.rda_metadata').on('autosave', (e) => {
    e.preventDefault();
    // re-initialize the metadata question
    initMetadataQuestions();
  });
});
