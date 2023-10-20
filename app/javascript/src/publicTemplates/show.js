// $(() => {
//   $('body').on('click', '#copy-link', (e) => {
//     const link = $(e.currentTarget).siblings('.direct-link');
//     link.click();

//     $('#link-modal').on('show.bs.modal', (e) => {
//       const modal = $(e.currentTarget);
//       modal.click();
//       $('#link').val(link.attr('href'));
//     });
//   });

//   $('body').on('click', '#copy-link-btn', () => {
//     $('#link').select();
//     // eslint-disable-next-line
//     document.execCommand('copy');
//   });
// });

$(() => {
  let linkValue = '';

  $('body').on('click', '#copy-link', (e) => {
    const link = $(e.currentTarget).siblings('.direct-link');
    link.click();
    linkValue = link.attr('href');
  });

  $('#link-modal').on('show.bs.modal', () => {
    $('#link').val(linkValue);
  });

  $('body').on('click', '#copy-link-btn', () => {
    $('#link').select();
    // eslint-disable-next-line
    document.execCommand('copy');
  });
});
