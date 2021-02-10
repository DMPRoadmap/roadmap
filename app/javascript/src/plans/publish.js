import getConstant from '../utils/constants';

$(() => {
  // Clear out the existing message/response when the user clicks the 'Register' a DMP ID button
  $('body').on('click', 'input.mint-dmp-id', () => {
    const mintMessage = $('.doi-minter-response');

    if (mintMessage.length > 0) {
      mintMessage.html(getConstant('ACQUIRING_DMP_ID'));
    }
  });
});
