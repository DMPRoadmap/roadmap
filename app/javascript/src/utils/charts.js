import Chart from 'chart.js/auto';

// Set Aspect Rate (width of X-axis/height of Y-axis) based on
// choice of selectedLastDayOfMonth in Time picker string value.  Note aspect
export const getAspectRatio = (diffInMonths) => {
  let ratio;
  try {
    switch (diffInMonths) {
    case 0:
    case 1:
      ratio = 5;
      break;
    case 2:
    case 3:
      ratio = 3.5;
      break;
    case 4:
    case 5:
    case 6:
      ratio = 2.5;
      break;
    case 7:
    case 8:
    case 9:
    case 10:
      ratio = 2;
      break;
    case 11:
    case 12:
      ratio = 1.5;
      break;
    default:
      ratio = 0.9;
    }
  } catch (e) {
    ratio = 0.9;
  }
  return ratio;
};

// Register a plugin for displaying a message for no data
export const initializeCharts = () => {
  Chart.register({
    id: 'no_data_label',
    afterDraw: (chart) => {
      if (chart.data.datasets.length === 0) {
        const { ctx, width, height } = {
          ctx: chart.ctx,
          width: chart.width,
          height: chart.height,
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
};

export const createChart = (selector, data, appendTolabel = '', onClickHandler = null) => {
  const chart = new Chart($(selector), { // eslint-disable-line no-new
    type: 'bar',
    data: {
      labels: Object.keys(data),
      datasets: [{
        data: Object.keys(data).map((k) => data[k]),
        backgroundColor: '#4F5253',
        // TODO parameterised according to roadmap main colour instance
      }],
    },
    options: {
      plugins: {
        legend: {
          display: false,
        },
      },
      tooltips: {
        callbacks: {
          label: (tooltipItem) => `${tooltipItem.yLabel} ${appendTolabel}`,
        },
      },
      scales: {
        y: {
          ticks: { min: 0, suggestedMax: 50 },
        },
      },
      onClick: onClickHandler,
    },
  });
  return chart;
};

export const drawHorizontalBar = (canvasSelector, data) => {
  const aspectRatio = getAspectRatio(data.labels.length);
  const chart = new Chart(canvasSelector, { // eslint-disable-line no-new
    type: 'bar',
    data,
    options: {
      indexAxis: 'y',
      responsive: true,
      maintainAspectRatio: true,
      aspectRatio,
      scales: {
        x: {
          ticks: { beginAtZero: true, stepSize: 10 },
          stacked: true,
        },
        y: {
          stacked: true,
        },
      },
    },
  });
  return chart;
};
