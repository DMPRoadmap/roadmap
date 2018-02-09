import moment from 'moment/moment';
import Chart from 'chart.js';

$(() => {
  const usageFormSelector = '.usage_index';
  const apiToken = $(usageFormSelector).find('input[name="api_token"]').val();
  // Builds an object whose keys are the topic fro the select options and value its the value
  // associated to the attribute data-url of each option
  const topicToURL = $(`${usageFormSelector} select[name="topic"]`).find('option').map((i, el) => {
    const topic = $(el);
    return { [topic.val()]: $(el).attr('data-url') };
  }).get() // An array of objects { topic: URL }
    .reduce((acc, value) => Object.assign(acc, value), {}); // Flatten to a single object
  // Events
  $(usageFormSelector).on('submit', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const topic = target.find('select[name="topic"]').val();
    const orgId = target.find('select[name="org_id"]').val() || target.find('input[name="org_id"]').val();
    $('[data-topic]').hide(); // Hides any data-topic view
    const ajaxSettings = ({ totals = false } = {}) => ({
      headers: { Authorization: `Token token="${apiToken}"` },
      url: topicToURL[topic],
      data: totals ? { topic, org_id: orgId } : target.serialize(),
    });
    $.when($.ajax(ajaxSettings()), $.ajax(ajaxSettings({ totals: true }))).then((r1, r2) => {
      const view = $(`[data-topic="${topic}"]`);
      if (topic === 'users') {
        view.find('[data-range]').html(r1[0].users_joined);
        view.find('[data-totals]').html(r2[0].users_joined);
        view.show();
      }
    }); // TODO request error handling
  });
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
  const initialise = () => {
    $.ajax({
      headers: { Authorization: `Token token="${apiToken}"` },
      url: topicToURL.users,
      data: { range_dates: rangeDatesUpToLastYearFromNow() },
    }).then((data) => {
      new Chart($('#yearly_users'), { // eslint-disable-line no-new
        type: 'bar',
        data: {
          labels: Object.keys(data),
          datasets: [{
            data: Object.keys(data).map(k => data[k]),
            backgroundColor: '#4F5253', // TODO parameterised according to roadmap main colour instance
          }],
        },
        options: {
          legend: {
            display: false,
          },
          tooltips: {
            callbacks: {
              label: tooltipItem => `${tooltipItem.yLabel} users`,
            },
          },
        },
      });
    }, (jqXHR) => {
      console.log('error: %o', jqXHR);
    });
  };
  initialise();
});
