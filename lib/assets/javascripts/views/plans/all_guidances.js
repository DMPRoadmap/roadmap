$(() => {
  const success = (data) => {
    // Render the html in the modal-permissions modal
    $('#modal-full-guidances').html(data.plan.html);
  };

  const error = () => {
    // There was an ajax error so just route the user to the sign-in modal
    // and let them sign in as a Non-Partner Institution
    $('a[data-target="#modal-full-guidances"]').tab('show');
  };
  // Loading the list of guidance groups options when user clicks the 'see the full list' link
  $('.modal-guidances-window').on('click', (e) => {
    const target = $(e.target);
    $('#modal-full-guidances').html('');
    $.ajax({
      method: 'GET',
      url: target.attr('href'),
    }).done((data) => {
      success(data);
    }, error);
  });
});
