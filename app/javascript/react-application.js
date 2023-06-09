
// Support for React based UI pages
import './dmp-hub-ui/src/index';

// Since we're using Webpacker to manage JS we need to startup Rails' Unobtrusive JS
// and Turbo. ActiveStorage and ActionCable would also need to be in here
// if we decide to implement either before Rails 6
// require('@rails/ujs').start();
