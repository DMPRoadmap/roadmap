import { isObject, isUndefined } from '../../utils/isType';
import { initializeCharts, createChart, drawHorizontalBar } from '../../utils/charts';

$(() => {
  // handles the checkbox for filtered-plans
  $('#filter_plans_form').on('click, change', 'input[type="checkbox"]', (e) => {
    const form = $(e.target).closest('form');
    form.submit();
  });

  // fns to handle the separator character menu
  // for CSV download
  const changeStatFnGen = (str) => {
    const fn = (item) => {
      /* eslint no-param-reassign: ["error", { "props": false }] */
      item.href = item.href.replace(/sep=.*/, str);
    };
    return fn;
  };

  // attach listener to separator select menu
  // on change look for "stat" elements and chnage their query param
  const fieldSep = document.getElementById('csv-field-sep');
  if (fieldSep !== null) {
    fieldSep.addEventListener('click', (e) => {
      const statElems = document.getElementsByClassName('stat');
      const newSep = 'sep='.concat(encodeURIComponent(e.target.value));
      const changeStatFn = changeStatFnGen(newSep);
      Array.from(statElems).forEach(changeStatFn);
    });
  }

  initializeCharts();

  const labelToUrl = (label) => {
    const parts = label.split('-');
    return `search=${parts[0]} 20${parts[1]}&commit=Search&click_through=true`;
  };

  // Create the Users joined chart
  if (!isUndefined($('#users_joined').val())) {
    const usersData = JSON.parse($('#users_joined').val());
    if (isObject(usersData)) {
      const chart = createChart('#yearly_users', usersData, '', (event) => {
        const segment = chart.getElementAtEvent(event)[0];
        if (!isUndefined(segment)) {
          const target = $('#users_click_target').val();
          /* eslint-disable no-underscore-dangle, no-restricted-globals */
          const label = chart.data.labels[segment._index];
          $(location).attr('href', `${target}?${labelToUrl(label)}`);
          /* eslint-enable no-underscore-dangle, no-restricted-globals */
        }
      });
    }
  }

  // Create the Plans created chart
  if (!isUndefined($('#plans_created').val())) {
    const plansData = JSON.parse($('#plans_created').val());
    if (isObject(plansData)) {
      const chart = createChart('#yearly_plans', plansData, '', (event) => {
        const segment = chart.getElementAtEvent(event)[0];
        if (!isUndefined(segment)) {
          const target = $('#plans_click_target').val();
          /* eslint-disable no-underscore-dangle, no-restricted-globals */
          const label = chart.data.labels[segment._index];
          $(location).attr('href', `${target}?${labelToUrl(label)}`);
          /* eslint-enable no-underscore-dangle, no-restricted-globals */
        }
      });
    }
  }
  // TODO: Most of these event listeners would not be necessary if JQuery and
  //       all other JS libraries were available to the js.erb files. Reevaluate
  //       this JS once we move to Rails 5 and properly configure webpacker
  let drawnChartByTemplate = null;
  const monthlyPlanTemplatesChart = document.getElementById('monthly_plans_by_template');
  // Add event listeners that draw and destroy the chart
  if (isObject(monthlyPlanTemplatesChart)) {
    monthlyPlanTemplatesChart.addEventListener('renderChart', (e) => {
      drawnChartByTemplate = drawHorizontalBar($('#monthly_plans_by_template'), e.detail);
      // Assigning the chart to a window variable here so that we can fire
      // the events from the js.erb
      window.templatePlansChart = document.getElementById('monthly_plans_by_template');
    });
    monthlyPlanTemplatesChart.addEventListener('destroyChart', () => {
      if (drawnChartByTemplate) {
        drawnChartByTemplate.destroy();
      }
    });
  }

  const monthlyPlanUsingTemplatesChart = document.getElementById('monthly_plans_using_template');
  // Add event listeners that draw the chart if it exists
  if (isObject(monthlyPlanUsingTemplatesChart)) {
    monthlyPlanUsingTemplatesChart.addEventListener('renderChart', (e) => {
      drawHorizontalBar($('#monthly_plans_using_template'), e.detail);
    });
  }

  // Create the initial Plans per template chart if the chart exists
  if (isObject(monthlyPlanTemplatesChart)) {
    const templatePlansData = JSON.parse($('#plans_by_template').val());
    const drawPer = new CustomEvent('renderChart', { detail: templatePlansData });
    document.getElementById('monthly_plans_by_template').dispatchEvent(drawPer);
  }
  // Create the initial Plans using template chart if the chart exists
  if (isObject(monthlyPlanUsingTemplatesChart)) {
    const usingTemplatePlansData = JSON.parse($('#plans_using_template').val());
    const drawUsing = new CustomEvent('renderChart', { detail: usingTemplatePlansData });
    document.getElementById('monthly_plans_using_template').dispatchEvent(drawUsing);
  }
});
