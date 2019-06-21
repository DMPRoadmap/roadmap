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
    .reduce((acc, value) => $.extend(acc, value), {});
  const rangeDatesUpToLastYearFromNow = () => {
    const getLastMonth = () => moment().subtract(1, 'month').clone();
    const rangeDates = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1].reduce((acc, v, i) => {
      const id = getLastMonth().subtract(i, 'month').format('MMM-YY');
      acc[id] = {
        start_date: getLastMonth().startOf('month').subtract(i, 'month').format('YYYY-MM-DD'),
        end_date: getLastMonth().endOf('month').subtract(i, 'month').format('YYYY-MM-DD'),
        id,
      };
      return acc;
    }, {});

    return rangeDates;
  };

  // Register a plugin for displaying a message for no data
  Chart.plugins.register({
    afterDraw: (chart) => {
      if (chart.data.datasets.length === 0) {
        const { ctx, width, height } = {
          ctx: chart.chart.ctx,
          width: chart.chart.width,
          height: chart.chart.height,
        };
        chart.clear();
        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.font = '25px bold';
        ctx.fillText('No data to display for selected time period', width / 2, height / 2);
        ctx.restore();
      }
    },
  });

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
        scales: {
          yAxes: [{
            ticks: { min: 0, suggestedMax: 50 },
          }],
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
    // Awaits until both AJAX request responds.
    // Note, the success handler is only executed if both AJAX requests return success
    $.when($.ajax(ajaxSettings()), $.ajax(ajaxSettings({ totals: true }))).then(
      (dataRangeSuccessCb, dataTotalsSuccessCb) => {
        let dataRange = null;
        let dataTotals = null;
        if (dataRangeSuccessCb[0]) { // data is the first argument of the successCb ranges
          const dataKeys = Object.keys(dataRangeSuccessCb[0]);
          // We assume the dataRange is the first key of the object responded
          dataRange = dataKeys.length > 0 ? dataRangeSuccessCb[0][dataKeys[0]] : null;
        }
        if (dataTotalsSuccessCb[0]) { // data is the first argument of the successCb for totals
          const dataKeys = Object.keys(dataTotalsSuccessCb[0]);
          // We assume the dataTotals is the first key of the object responded
          dataTotals = dataKeys.length > 0 ? dataTotalsSuccessCb[0][dataKeys[0]] : null;
        }
        const dataTopics = $('[data-topics]');
        const views = $(`[data-topic="${topic}"]`);
        dataRange !== null ? dataTopics.find('[data-range]').html(dataRange) : undefined; // eslint-disable-line no-unused-expressions
        dataTotals !== null ? dataTopics.find('[data-totals]').html(dataTotals) : undefined; // eslint-disable-line no-unused-expressions
        views.show();
        dataTopics.show();
      },
    ); // TODO request error handling
  });
  /*
    Click event associated to each Export button
  */
  $('button.stat[data-url]').on('click', (e) => {
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
  const yearlySuccesHandler = ({ data, selector } = {}) => {
    const keys = Object.keys(data); // Keys are Month-Year strings and values might be [0...N]
    if (keys.find(k => data[k] > 0)) {
      createChart({ selector, data });
    } else {
      $(selector).prev().show();
    }
  };
  // Sends an AJAX request to our two current endpoints that generate yearly data
  // (e.g. users_joined_api_v0_statistics_path, created_plans_api_v0_statistics_path )
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
        yearlySuccesHandler({ data, selector: '#yearly_users' });
      }); // TODO request error handling
      $.ajax({
        headers: { Authorization: `Token token="${apiToken}"` },
        url: topicToURL.plans,
        data: { range_dates: rangeDates },
      }).then((data) => {
        yearlySuccesHandler({ data, selector: '#yearly_plans' });
      }); // TODO request error handling
    }
  };
  initialise();
});

$(() => {
  const jQuerySelectorSelect = $('select[name=monthly_plans_by_template]');
  let drawnChart = null;
  const randomRgb = () => {
    const { round, random } = Math;
    const max = 255;
    const f = () => round(random() * max);
    return `rgb(${f()},${f()},${f()})`;
  };
  const yAxisLabel = date => moment(date).format('MMM-YY');

  const drawHorizontalBar = (canvasSelector, data, aspectRatio = 1) => {
    const chart = new Chart(canvasSelector, { // eslint-disable-line no-new
      type: 'horizontalBar',
      data,
      options: {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio,
        scales: {
          xAxes: [{
            ticks: { beginAtZero: true, stepSize: 10 },
            stacked: true,
          }],
          yAxes: [{
            stacked: true,
          }],
        },
      },
    });
    return chart;
  };

  const buildData = (data) => {
    const labels = data.map(current => yAxisLabel(current.date));
    const datasetsMap = data.reduce((acc, statCreatedPlan) => {
      statCreatedPlan.by_template.forEach((template) => {
        if (!acc[template.name]) {
          acc[template.name] = { label: template.name, data: [], backgroundColor: randomRgb() };
        }
        acc[template.name].data.push({ x: template.count, y: yAxisLabel(statCreatedPlan.date) });
      });
      return acc;
    }, {});
    // const datasets = Object.keys(datasetsMap).map(key => datasetsMap[key]);
    const compare = (a, b) => {
      const aIndex = labels.indexOf(a.y);
      const bIndex = labels.indexOf(b.y);
      if (aIndex > bIndex) return 1;
      if (aIndex < bIndex) return -1;
      return 0;
    };
    const datasets = Object.keys(datasetsMap).map((key) => {
      const datasetByKey = datasetsMap[key];
      const availableMonths = datasetByKey.data.reduce((acc, value) => {
        // month has y as key
        acc.push(value.y);
        return acc;
      }, []);
      // Find missing months in data
      const missingMonths = labels.filter(month => !availableMonths.includes(month));
      // Add data for missing months with x value set to 0
      missingMonths.forEach(month => datasetByKey.data.push({ x: 0, y: month }));
      datasetByKey.data = datasetByKey.data.sort(compare);
      return datasetByKey;
    });
    return { labels, datasets };
  };

  const fetch = (lastDayOfMonth, aspectRatio = 1) => {
    const baseUrl = $('select[name="monthly_plans_by_template"]').attr('data-url');
    $.ajax({
      url: `${baseUrl}?start_date=${lastDayOfMonth}`,
    }).then((data) => {
      const chartData = buildData(data);
      const canvasSelector = '#monthly_plans_by_template_canvas';
      if (drawnChart) {
        drawnChart.destroy();
      }
      drawnChart = drawHorizontalBar($(canvasSelector), chartData, aspectRatio);
    });
  };

  // Set Aspect Rate (width of X-axis/height of Y-axis) based on
  // choice of selectedLastDayOfMonth in Time picker string value.  Note aspect
  const getAspectRatio = (selectedLastDayOfMonth) => {
    let aspectRatio;
    try {
      const now = new Date();
      const dateOfSelectedMonth = new Date(selectedLastDayOfMonth);
      const diff = new Date(now.getTime() - dateOfSelectedMonth.getTime());
      const diffInMonths = diff.getUTCMonth();

      switch (diffInMonths) {
      case 0:
      case 1:
        aspectRatio = 5;
        break;
      case 2:
      case 3:
        aspectRatio = 3.5;
        break;
      case 4:
      case 5:
      case 6:
        aspectRatio = 2.5;
        break;
      case 7:
      case 8:
      case 9:
      case 10:
        aspectRatio = 2;
        break;
      case 11:
      case 12:
        aspectRatio = 1.5;
        break;
      default:
        aspectRatio = 0.9;
      }
    } catch (e) {
      aspectRatio = 0.9;
    }

    return aspectRatio;
  };

  const handler = () => {
    const selectedMonth = jQuerySelectorSelect.val();

    if (selectedMonth) {
      const aspectRatio = getAspectRatio(selectedMonth);
      fetch(selectedMonth, aspectRatio);
    }
  };

  jQuerySelectorSelect.on('change', (e) => {
    e.preventDefault();
    handler();
  });

  handler();
});
