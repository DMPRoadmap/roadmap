import { isObject } from '../../utils/isType';
import { initializeCharts, createChart, drawHorizontalBar } from '../../utils/charts';

$(() => {
  initializeCharts();

  // Create the Users joined chart
  const usersData = JSON.parse($('#users_joined').val());
  if (isObject(usersData)) {
    createChart('#yearly_users', usersData);
  }
  // Create the Plans created chart
  const plansData = JSON.parse($('#plans_created').val());
  if (isObject(plansData)) {
    createChart('#yearly_plans', plansData);
  }

  // TODO: Most of these event listeners would not be necessary if JQuery and
  //       all other JS libraries were available to the js.erb files. Reevaluate
  //       this JS once we move to Rails 5 and properly configure webpacker
  let drawnChart = null;
  const monthlyPlanTemplatesChart = document.getElementById('monthly_template_plans');
  // Add event listeners that draw and destroy the chart
  monthlyPlanTemplatesChart.addEventListener('renderChart', (e) => {
    drawnChart = drawHorizontalBar($('#monthly_template_plans'), e.detail);
    // Assigning the chart to a window variable here so that we can fire
    // the events from the js.erb
    window.templatePlansChart = document.getElementById('monthly_template_plans');
  });
  monthlyPlanTemplatesChart.addEventListener('destroyChart', () => {
    if (drawnChart) {
      drawnChart.destroy();
    }
  });

  // Create the initial Plans per template chart
  const templatePlansData = JSON.parse($('#plans_by_template').val());
  if (isObject(templatePlansData)) {
    const draw = new CustomEvent('renderChart', { detail: templatePlansData });
    document.getElementById('monthly_template_plans').dispatchEvent(draw);
  }
});
