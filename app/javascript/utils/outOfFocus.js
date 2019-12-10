$(() => {
  // This bit of code currently only closes dropdown
  // menus in a table when the focus is no longer in the containing cell.

  // List of focusable Elements on page
  const focusables = $('td, .dropdown, .dropdown-toggle, a[href], area[href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), button:not([disabled]), iframe, object, embed, [tabindex], [contenteditable]');

  focusables.each((i, el) => {
    const focusable = $(el); // JQuery object
    // On entrying a new focusable element we respond to event
    focusable.focusin(() => {
      $('td').children('.dropdown.open').each((j, elj) => {
        const td = $(elj).parent(); // DOM Element
        const dropdownBtn = $(elj).find('.dropdown-toggle'); // JQuery object
        // Close dropdown menu if the focus is not the table cell containing the dropdown
        if (!($.contains(td.get(0), focusable.get(0)) || focusable.is(td))) {
          dropdownBtn.dropdown('toggle');
        }
      });
    });
  });
});
