import toggleSpinner from '../../utils/spinner';
import getConstant from '../../utils/constants';

// JS for the Public Plans page
$(() => {
  const publicPlansFacetingBlock = $('.t-publicplans__plans');
  const publicPlansContentHeader = $('.t-publicplans__section-header');

  const setFacetingMessage = (form) => {
    if (form.length > 0) {
      const messageBlock = form.find('.c-clear__applied');
      const selections = form.find('.js-facet__list input[type="checkbox"]:checked');
      let msg = getConstant('NO_FACETS_SELECTED');

      if (selections.length > 1) {
        msg = getConstant('MULTIPLE_FACETS_SELECTED').replace('%<nbr>s', selections.length);
      } else if (selections.length === 1) {
        msg = getConstant('ONE_FACET_SELECTED');
      }
      messageBlock.text(msg);
    }
  };

  if (publicPlansContentHeader && publicPlansFacetingBlock) {
    const sortSelect = $('#sort-select');
    const form = $(`#${sortSelect.attr('form')}`);

    if (form) {
      const searchField = form.find('#search');

      // Only allow Alphanumeric characters, space, shift, tab, enter/return and arrow keys in the search field
      searchField.on('input', (e) => {
        const currentValue = $(e.currentTarget).val();
        const sanitizedValue = currentValue.replace(/[^a-zA-Z0-9]/g, '');
        $(e.currentTarget).val(sanitizedValue);
      });

      // Display the spinner whenever the form is submitted to let the user know its working
      form.on('submit', () => {
        toggleSpinner(true);
      });

      // User has changed the sort option
      sortSelect.on('change', () => {
        form.trigger('submit');
      });

      // User has cleared the search term
      form.on('click', '.js-search-clear', () => {
        form.find('#search').val('');
        form.trigger('submit');
      });

      // User clicked on a facet
      form.on('click', '.js-facet__list input[type="checkbox"]', () => {
        setFacetingMessage(form);
        form.trigger('submit');
      });

      // User has cleared the facets
      form.on('click', '.js-facet-clear', () => {
        form.find('.js-facet__list input[type="checkbox"]:checked').attr('checked', false);
        setFacetingMessage(form);
        form.trigger('submit');
      });

      setFacetingMessage(form);
    }
  }

  const initFacetToggle = () => {
    const facets = document.querySelectorAll('.js-facet')
    for (const facet of facets) {
      const facetButton = facet.querySelector('.js-facet__toggle-list')
      const facetList = facet.querySelector('.js-facet__list')

      facetButton.addEventListener('click', () => {
        let facetIcon = facet.querySelector('.fas')
        if (facetList.hidden === true) {
          facetList.hidden = false
          facetButton.setAttribute('aria-expanded', true)
          facetIcon.classList.add('fa-minus')
          facetIcon.classList.remove('fa-plus')
        } else {
          facetList.hidden = true
          facetButton.setAttribute('aria-expanded', false)
          facetIcon.classList.add('fa-plus')
          facetIcon.classList.remove('fa-minus')
        }
      })
    }
  }

  initFacetToggle()
});

const initFormElRequired = () => {
  // const requiredField = document.querySelector('.js-login__required-field')
  const textfields = document.querySelectorAll('.js-textfield')
  const checkboxes = document.querySelectorAll('.js-checkbox')

  const requiredFormElements = (formEls) => {
    for (const formEl of formEls) {
      const input = formEl.querySelector('input')

      if (input.classList.contains('require-me')) {
        input.setAttribute('required', '')
        //requiredField.hidden = false
        formEl.classList.add('is-required')
      }
    }
  }

  requiredFormElements(textfields)
  requiredFormElements(checkboxes)
}

const initShowPassword = () => {
  const passwordField = document.querySelector('#js-password-field input')
  const checkboxToggle = document.querySelector('#js-password-toggle input')

  if (passwordField) {
    checkboxToggle.addEventListener('change', (e) => {
      if (checkboxToggle.checked) {
        passwordField.setAttribute('type', 'text')
      } else {
        passwordField.setAttribute('type', 'password')
      }
    })
  }
}

const authPage = document.querySelector('.dmpui-authentication-page');
if (authPage !== undefined) {
  initFormElRequired();
  initShowPassword();
}
