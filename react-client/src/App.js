import React from 'react';

import {
  createBrowserRouter,
  RouterProvider,
} from 'react-router-dom';



import Dashboard from './pages/dashboard';
import PlanNew from './pages/plan/new';
import PlanOverview from './pages/plan/overview';
import PlanFunders from './pages/plan/funder';

import './App.css';


const router = createBrowserRouter([
  {
    path: "/dashboard",
    element: <Dashboard />
  },

  {
    path: "/dmps/new",
    element: <PlanNew />
  },

  {
    // TODO::FIXME:: We need to have a plan ID here
    path: "/dmps/funders",
    element: <PlanFunders />
  },

  {
    // TODO::FIXME:: We need to have a plan ID here
    path: "/dmps/overview",
    element: <PlanOverview />
  },
]);


function App() {
  return (
    <div id="App">
      {/*
      <header className="todo">
        <h1>DMPTool v5</h1>
      </header>
      */}
      <main>



        <RouterProvider router={router} />
      </main>
      {/*
      <footer className="todo">
        <p>
          Footer content
        </p>
      </footer>
    */}

    </div >
  );
}

export default App;
