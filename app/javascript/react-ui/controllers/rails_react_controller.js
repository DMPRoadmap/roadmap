import React from 'react';
import ReactDOM from 'react-dom/client';
import ReactApp from '../ReactApp';
import './dashboards_controller.scss';

console.log(document.getElementById('react-app'));

const root = ReactDOM.createRoot(document.getElementById('react-app'));
root.render(
  <React.StrictMode>
    <ReactApp />
  </React.StrictMode>
);
