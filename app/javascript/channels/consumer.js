// By default, ActionCable channels use the App.cable consumer created in the
// app/assets/javascripts/cable.js file. To avoid polluting the global namespace
// we use webpack’s module system to provide a consumer for our channels.
import { createConsumer } from '@rails/actioncable';

export default createConsumer();
