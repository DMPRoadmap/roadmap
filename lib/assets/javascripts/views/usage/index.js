import moment from 'moment/moment';
import Chart from 'chart.js';

$(() => {
  const usageFormSelector = '.usage_index';
  const apiToken = $(usageFormSelector).find('input[name="api_token"]').val();
  // Builds an object whose keys are the topic fro the select options and value its the value
  // associated to the attribute data-url of each option
  const topicToURL = $(`${usageFormSelector} select[name="topic"]`).find('option').map((i, el) => {
    const topic = $(el);
    return { [topic.val()]: topic.attr('data-url') };
  }).get() // An array of objects { topic: URL }
    .reduce((acc, value) => Object.assign(acc, value), {}); // Flatten to a single object
  const rangeDatesUpToLastYearFromNow = () => {
    const getLastMonth = () => moment().subtract(1, 'month').clone();
    const rangeDates = new Array(12).fill(1).reduce((acc, v, i) => {
      const id = getLastMonth().subtract(i, 'month').format('MMM-YY');
      acc[id] = {
        start_date: getLastMonth().startOf('month').subtract(i, 'month').format('YYYY-MM-DD'),
        end_date: getLastMonth().endOf('month').subtract(i, 'month').format('YYYY-MM-DD'),
        id };
      return acc;
    }, {});

    return rangeDates;
  };
  const createChart = ({ selector, data, appendTolabel = '' } = {}) => {
    new Chart($(selector), { // eslint-disable-line no-new
      type: 'bar',
      data: {
        labels: Object.keys(data),
        datasets: [{
          data: Object.keys(data).map(k => data[k]),
          backgroundColor: '#4F5253',
          // TODO parameterised according to roadmap main colour instance
        }],
      },
      options: {
        legend: {
          display: false,
        },
        tooltips: {
          callbacks: {
            label: tooltipItem => `${tooltipItem.yLabel} ${appendTolabel}`,
          },
        },
      },
    });
  };
  /*
    Submit event associated to the filter by dates form
  */
  $(usageFormSelector).on('submit', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const topic = target.find('select[name="topic"]').val();
    const orgId = target.find('select[name="org_id"]').val() || target.find('input[name="org_id"]').val();
    $('[data-topics]').hide(); // Hides data-topics container
    $('[data-topic]').hide(); // Hides any data-topic specific
    const ajaxSettings = ({ totals = false } = {}) => ({
      headers: { Authorization: `Token token="${apiToken}"` },
      url: topicToURL[topic],
      data: totals ? { topic, org_id: orgId } : target.serialize(),
    });
    $.when($.ajax(ajaxSettings()), $.ajax(ajaxSettings({ totals: true }))).then((r1, r2) => {
      let dataRange;
      let dataTotals;
      if (topic === 'users') {
        dataRange = r1[0].users_joined;
        dataTotals = r2[0].users_joined;
      } else if (topic === 'completed_plans') {
        dataRange = r1[0].completed_plans;
        dataTotals = r2[0].completed_plans;
      } else {
        dataRange = null;
        dataTotals = null;
      }
      const dataTopics = $('[data-topics]');
      const views = $(`[data-topic="${topic}"]`);
      dataRange !== null ? dataTopics.find('[data-range]').html(dataRange) : undefined; // eslint-disable-line no-unused-expressions
      dataTotals !== null ? dataTopics.find('[data-totals]').html(dataTotals) : undefined; // eslint-disable-line no-unused-expressions
      views.show();
      dataTopics.show();
    }); // TODO request error handling
  });
  /*
    Click event associated to each Export button
  */
  $('button[data-url]').on('click', (e) => {
    const rangeDates = rangeDatesUpToLastYearFromNow();
    $.ajax({
      headers: { Authorization: `Token token="${apiToken}"` },
      url: $(e.currentTarget).attr('data-url'),
      data: { range_dates: rangeDates },
    }).then((data, statusText, jqXHR) => {
      /* eslint-env browser */
      const blob = new Blob([data], { type: 'text/csv' });
      // Attemps to match the filename from the Content-Disposition header produced by the API
      const match = /filename="([^"]*)"/.exec(jqXHR.getResponseHeader('Content-Disposition'));
      const link = $('<a />', {
        href: URL.createObjectURL(blob),
        download: match ? match[1] : 'export.csv',
      });
      $('body').append(link);
      link[0].click();
      link.remove();
    });
  });
  // Sends an AJAX request to our two current endpoints that generate yearly data
  // (e.g. users_joined_api_v0_statistics_path, completed_plans_api_v0_statistics_path )
  // and draws a barChart when success response is found
  const initialise = () => {
    // Only fire AJAX requests if topicToURL object has keys, i.e. topics mapping to URLs
    if (Object.keys(topicToURL).length > 0) {
      const rangeDates = rangeDatesUpToLastYearFromNow();
      $.ajax({
        headers: { Authorization: `Token token="${apiToken}"` },
        url: topicToURL.users,
        data: { range_dates: rangeDates },
      }).then((data) => {
        createChart({ selector: '#yearly_users', data, appendTolabel: 'users' });
      }); // TODO request error handling
      $.ajax({
        headers: { Authorization: `Token token="${apiToken}"` },
        url: topicToURL.completed_plans,
        data: { range_dates: rangeDates },
      }).then((data) => {
        createChart({ selector: '#yearly_plans', data, appendTolabel: 'completed plans' });
      }); // TODO request error handling
    }
  };
  initialise();
});
