import React, {useEffect} from "react";

import { createBrowserRouter, RouterProvider } from "react-router-dom";

import Dashboard from "./pages/dashboard/dashboard";
import PlanOverview from "./pages/plan/overview/overview";
import DmpSetup from "./pages/plan/setup/setup";
import PlanFunders from "./pages/plan/funder/funder";
import ProjectDetails from "./pages/plan/project-details/projectdetails";
import ProjectSearch from "./pages/plan/project-search/projectsearch";
import Contributors from "./pages/plan/contributors/contributors";
import ResearchOutputs from "./pages/plan/research-outputs/researchoutputs";
import RelatedWorksPage from "./pages/plan/related-works/relatedworks";


const router = createBrowserRouter([
  {
    path: "/dashboard",
    element: <Dashboard />,
  },

  {
    path: "/dashboard/dmp/new",
    element: <DmpSetup />,
  },

  {
    path: "/dashboard/dmp/:dmpId",
    element: <PlanOverview />,
  },

  {
    path: "/dashboard/dmp/:dmpId/pdf",
    element: <DmpSetup />,
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

  {
    path: "/dashboard/dmp/:dmpId/related-works",
    element: <RelatedWorksPage />,
  },
]);

/* Last resort hack to detect Safari and warn user to use a different browser since Safari
 * is throwing the following error. Sometimes a page refresh fixes the issue but it occurs on
 * every page and really hurts usability.
 *
 */
const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);

function App() {
  
    useEffect(() => {
      window.scrollTo(0,0)
    }, [])
  
  // If it is Safari, warn the user away
  if (isSafari) {
    return (
      <div>
        <h1>Incompatible Browser</h1>
        <p>The Safari browser is not currently supported. Please use Chrome, Firefox or Edge. We apologize for the inconvenience.</p>
      </div>
    );
  } else {
    // Otherwise the React app should work without issue
    return (
      <div id="App">
        <div>
          <RouterProvider router={router} />
        </div>
      </div>
    );
  }
}


export default App;
