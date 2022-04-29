// This will automatically load any file with a name ending in _channel.js within
// the app/javascript/channels/ directory and all of its subdirectories.
const channels = require.context('.', true, /_channel\.js$/);
channels.keys().forEach(channels);
