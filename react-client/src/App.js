import React from 'react';

import {
  createBrowserRouter,
  RouterProvider,
} from 'react-router-dom';

import TextInput from './components/text-input/textInput';

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


        <p>
          This is the main content
        </p>

        <TextInput
          label="Project Name"
          type="text"
          name="project_name"
          id="project_name"
          placeholder="Enter the name of your project"
          help="This is the name of your project"
          error="Please complete this field"
        />

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
