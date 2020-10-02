// This is an example of an ActionCable channel. All channel files should live
// in this directory. Delete this after uncommenting the `require('channels');`
// line in packs/application.js

import consumer from './consumer';

consumer.subscriptions.create('ChatChannel', {
  // Do some exciting stuff!
});
