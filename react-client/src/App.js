import React from 'react';

import {
  createBrowserRouter,
  RouterProvider,
} from 'react-router-dom';



import Dashboard from './pages/dashboard/dashboard';
import PlanNew from './pages/plan/new-plan/new';
import PlanOverview from './pages/plan/overview/overview';
import PlanFunders from './pages/plan/funder/funder';

import './App.css';


const router = createBrowserRouter([
  {
    path: "/dashboard",
    element: <Dashboard />
  },

  {
    path: "/dashboard/dmp/new",
    element: <PlanNew />
  },

  {
    path: "/dashboard/dmp/:dmpId",
    element: <PlanOverview />,
  },

  {
    path: "/dashboard/dmp/:dmpId/funders",
    element: <PlanFunders />,
  },

  {
    path: "/dashboard/dmp/:dmpId/project-details",
    element: <PlanFunders />,
  },

  {
    path: "/dashboard/dmp/:dmpId/contributors",
    element: <PlanFunders />,
  },

  {
    path: "/dashboard/dmp/:dmpId/research-outputs",
    element: <PlanFunders />,
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
