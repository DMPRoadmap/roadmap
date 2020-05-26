/* eslint-env browser */ // This allows us to reference 'window' below
import 'jquery-ui/tabs';

$(() => {
  $('[role="tablist"]').each((idx, el) => {
    const tabList = $(el).parent();
    tabList.tabs();

    // Retrieve the selected tab if it is specified in the URL
    const selectedTab = tabList.find(window.location.hash);
    // If the specified tab is one of this tablist's tabs then show it
    if (selectedTab) {
      tabList.tabs("option", "active", selectedTab);
    }
  });
});
