import getConstant from '../utils/constants';
import { isUndefined, isObject } from '../utils/isType';
import { Tinymce } from '../utils/tinymce.js';
import { renderNotice, renderAlert } from '../utils/notificationHelper';
import { scrollTo } from '../utils/scrollTo';


$(() => {
  const form = $('.research_output_form');

  if (!isUndefined(form) && isObject(form)) {
    Tinymce.init({ selector: '#research_output_description' });
  }

  // Expands/Collapses the search results 'More info'/'Less info' section
  $('body').on('click', '.modal-search-result .more-info a.more-info-link', (e) => {
    e.preventDefault();
    const link = $(e.target);

    if (link.length > 0) {
      const info = $(link).siblings('div.info');

      if (info.length > 0) {
        if (info.hasClass('d-none')) {
          info.removeClass('d-none');
          link.text(`${getConstant('LESS_INFO')}`);
        } else {
          info.addClass('d-none');
          link.text(`${getConstant('MORE_INFO')}`);
        }
      }
    }
  });

  // Put the facet text into the modal search window's search box when the user
  // clicks on one
  $('body').on('click', '.modal-search-result a.facet', (e) => {
    const link = $(e.target);

    if (link.length > 0) {
      const textField = link.closest('.modal-body').find('input.autocomplete');

      if (textField.length > 0) {
        textField.val(link.text());
      }
    }
  });

  // GET request using DOI
  $('#fetch-info-button').on('click', (e) => {
    e.preventDefault();
    var doi_url = $('#research_output_doi_url').val();
    doi_url = doi_url.trim();
    
    // Method to extract DOI from full URL 
    function extractDOI(doi_url) {
      // Regular expression to match DOI in URL
      const doiRegex = /(10\.\d{4,}\/[\S]+)\b/i;
      // Extract DOI using regex
      const doiMatch = doi_url.match(doiRegex);
      
      // Check if there's a match and return the DOI
      if (doiMatch) {
          return doiMatch[1]; // Return the first capturing group
      } else {
          return null; // Return null if no DOI found
      }
  }
    // Format DOI before AJAx call
    var doi = extractDOI(doi_url);
    
    // AJAX call
    $.ajax({
      url: '/open_aire_service/search_proxy/' + doi,
      type: 'GET',
      headers: { 'Accept': 'application/*' }
    }).done((xmlString) => {

        if (xmlString == null) {
          // Display fail notice
          renderAlert('DOI entered returned an empty response. Please check if you have entered the DOI in the correct format i.e. 10.1234/ijdc.123456.', { className: 'alert-warning' });
          scrollTo('#notification-area');
        } else { // Parsing XML
          // Setting Type
          var type = $(xmlString).find('resulttype > classname').first().text();
          if (type) {
            $('#research_output_output_type').val(type);
          } else {
            //else block
          }

          // Setting Title as main title from response
          var title = $(xmlString).find('title > classid').filter(function () {
            return $(this).text() === 'main title';
          }).siblings('__content__').first().text();
          if (title) {
            $('#research_output_title').val(title);
          } else {
            // else block
          }

          // Setting Description
          var description = $(xmlString).find('description').first().text();
          if (description) {
            var description_with_html = '<p>' + description + '</p>';
            var iframe_content = $('#research_output_description_ifr').contents().find('body#tinymce');
            iframe_content.html(description_with_html);
          } else {
            // else block
          }


          // Setting Release date
          var date = $(xmlString).find('dateofacceptance:first').first().text();
          if (date) {
            $('#research_output_release_date').val(date);
          } else {
            // else block
          }

          $('#research_output_doi_url').val(doi);
          // Display success notice
          renderNotice('Successfully retrieved the research output\'s metadata.', { className: 'alert-info' });
        }
      }).fail((xhr, status, error) => {
          // Handle errors
          alert('An error occurred while processing your request. Please try again later.');
      });
  });
});