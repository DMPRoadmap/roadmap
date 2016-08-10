$(document).ready(function() {

  var toolbar = $('.dmp_toolbar').first(),
         form = null;

  $('#toolbar_configure').click(function(e) {
    e.preventDefault();

    if (form) {
      form.toggle();
    } else {
      $.get('/settings/projects.json')
       .done(buildSettingsForm)
       .fail(function(data) {
         // Handle failure?
       });
    }
  });

  // FIXME: it would be simpler just to return the partial from
  // Settings::ProjectsController#show, but that would perhaps
  // mean responding to a JSON request with HTML.
  function buildSettingsForm(data) {
    if (!form)
      form = $('<form method="POST" action="/settings/projects"></form>');

    var table = $('<table class="dmp_table"></table>').appendTo(form),
        thead = $('<thead><tr></tr></thead>').appendTo(table),
        tbody = $('<tbody><tr></tr></tbody>').appendTo(table),
        tfoot = $('<tfoot><tr></tr></tfoot>').appendTo(table),
         cols = data.all_columns,
     selected = [];
     
    // grab the keys from the data.selected_columns hash
    $.each(data.selected_columns, function(k,v){
      selected.push(k);
    });
     
    table.before('<input name="_method" type="hidden" value="put" />'); // PUT not POST
    table.before('<input name="authenticity_token" type="hidden" value="' + $('meta[name="csrf-token"]').attr('content') + '" />'); // Auth token
    table.after('<p>' + I18n.t("helpers.project.project_settings_text") + '</p>');

    // Default name column
    table.before('<input type="hidden" name="columns[name]" value="1" />');
    thead.append('<th><label for="columns_name">Name</label></th>');
    tbody.append('<td><input type="checkbox" id="columns_name" name="columns[name]" value="1" checked disabled /></td>')

    for (var i = 0, len = cols.length; i < len; i++) {
      var title = cols[i].replace(/^\w|_/g, function(c) { return c === '_' ? ' ' : c.toUpperCase(); }), // FIXME: add titles to response for I18n?
          label = $('<th><label for="columns_' + cols[i] + '">' + title + '</label></th>').appendTo(thead),
      container = $('<td></td>').appendTo(tbody),
          input = $('<input type="checkbox" id="columns_' + cols[i] + '" name="columns[' + cols[i] + ']" value="1" />').appendTo(container);

      if (selected.indexOf(cols[i]) > -1)
        input.attr('checked', 'checked');
    }

    thead.append('<th><label for="columns_select">' + I18n.t("helpers.select_action") + '</label></th>');
    tbody.append('<td><input type="checkbox" id="columns_select" name="columns[select]" value="1" checked disabled /></td>')

    var submit = $('<td><input type="Submit" value="Save" class="btn btn-primary" /></td>').appendTo(tfoot);
        cancel = $('<td><a href="#" class="btn btn-primary">' + I18n.t("helpers.submit.cancel") + '</a></td>').appendTo(tfoot);

    cancel.click(function(e) {
      e.preventDefault();
      form.toggle();
    });

    toolbar.before(form);
  }

  /*
     'My plans' filtering
   */
  var no_matches_message = $('<tr style="display: none;"><td colspan="20">' + I18n.t("helpers.project.filter.no_matches") + '</td></tr>').appendTo($('#dmp_table tbody')),
                    rows = $('#dmp_table tbody tr'),
                  filter = $('#filter');

  filter.keyup(function() {
    var query = $(this).val(),
          len = query.length,
    filter_re = new RegExp(query, 'i'),
      matched = false;

    if (len < 2) {
      rows.show();
      no_matches_message.hide();
      return;
    }

    no_matches_message.hide();

    rows.each(function() {
      var row = $(this);
      row.text().match(filter_re) ? (matched = true && row.show()) : row.hide();
    });

    if (!matched)
      no_matches_message.show();
  });

  $('#clear_filter').click(function(e) {
    e.preventDefault();

    filter.val('');
    rows.show();
    no_matches_message.hide();
  });

 $('#filter_form').submit(function(e) { e.preventDefault() } );

});
