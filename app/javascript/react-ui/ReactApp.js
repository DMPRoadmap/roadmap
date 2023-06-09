import React from 'react';
import {
  createBrowserRouter,
  RouterProvider,
} from 'react-router-dom';
import Dashboard from './pages/dashboard';
// import PlanSetup from './pages/plan/setup';
// import PlanOverview from './pages/plan/overview';
// import PlanFunders from './pages/plan/funder';

const router = createBrowserRouter([
  {
    path: "/dashboard",
    element: <Dashboard />
  },
  /*
  {
    path: "/plan/add",
    element: <PlanSetup />
  },

  {
    // TODO::FIXME:: We need to have a plan ID here
    path: "/plan/funders",
    element: <PlanFunders />
  },

  {
    // TODO::FIXME:: We need to have a plan ID here
    path: "/plan/overview",
    element: <PlanOverview />
  },
  */
]);

function ReactApp() {
  return (
    <div id="ReactApp">
      <main>
        <RouterProvider router={router} />
      </main>
    </div>
  );
}

export default ReactApp;