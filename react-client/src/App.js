import React from "react";

import { createBrowserRouter, RouterProvider } from "react-router-dom";

import Dashboard from "./pages/dashboard/dashboard";
import PlanOverview from "./pages/plan/overview/overview";
import PlanNew from "./pages/plan/new-plan/new";
import PlanFunders from "./pages/plan/funder/funder";
import ProjectDetails from "./pages/plan/project-details/projectdetails";
import ProjectSearch from "./pages/plan/project-search/projectsearch";
import Contributors from "./pages/plan/contributors/contributors";
import ResearchOutputs from "./pages/plan/research-outputs/researchoutputs";

const router = createBrowserRouter([
  {
    path: "/dashboard",
    element: <Dashboard />,
  },

  {
    path: "/dashboard/dmp/new",
    element: <PlanNew />,
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
    path: "/dashboard/dmp/:dmpId/project-search",
    element: <ProjectSearch />,
  },
  {
    path: "/dashboard/dmp/:dmpId/project-details",
    element: <ProjectDetails />,
  },

  {
    path: "/dashboard/dmp/:dmpId/contributors",
    element: <Contributors />,
  },

  {
    path: "/dashboard/dmp/:dmpId/research-outputs",
    element: <ResearchOutputs />,
  },
]);

function App() {
  return (
    <div id="App">
      <main>
        <RouterProvider router={router} />
      </main>
    </div>
  );
}


export default App;
