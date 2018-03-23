export const getSpinnerHTML = '<p class="spinner"><i class="fa fa-spinner fa-spin"></i></p>';

export const showSpinner = (ctx) => {
  ctx.append(getSpinnerHTML);
};

export const hideSpinner = (ctx) => {
  ctx.find('.spinner').remove();
};
