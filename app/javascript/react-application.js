/*
 * This file is used by the Rails application to serve the React based UI.

 * It is used by the Rails asset pipeline (via Webpack) to compile a single react-application-[fingerprint].js
 * file that is then referenced when Rails combines the default React ERB template and a special ERB layout for
 * our React pages:
 *     - Layout: app/views/branded/layouts/react_application.html.erb
 *     - Page: app/views/branded/dashboards/show.html.erb
 */
import React from 'react';

// Make React available
window.React = React;

// Import the React App code
import '../../react-client/src/index';
