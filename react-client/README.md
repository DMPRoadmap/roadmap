# DMPTool React client

This directory contains the new React based UI for the DMPTool. It runs within the context of the Rails application but has been kept as isolated from the Rails ERB templating system as much as possible. It does however rely on the Rails asset pipeline to build the React application.

## Project status
See the individual issues in this repo and/or the [Trello board](https://trello.com/b/zlLicieW/dmptool)

## Dependency management

Dependencies are defined in the package.json at the root of this project (note this ./react-client directory)!

The `package.json` in the root of the project serves 2 purposes. It manages the assets for the older Rails application pages (e.g. JQuery and Bootstrap, etc.) as well as this React application (e.g. React, WebVitals, etc.).

If you need to add or remove a JS dependency for this React application, please run `yarn [add|remove] [dependency]` from the root of the project. Use `yarn upgrade` (from the root of the project) to update dependencies.

## How Rails serves the React application

When the browser asks for `/dashboard` or a `/dmps/*` path, the Rails router looks up the path in the [config/routes.rb file](https://github.com/CDLUC3/dmptool/blob/6f9a7eca9297d9c00bddc8109fc0ec72fcae9b86/config/routes.rb#L91) to determine which controller and action should handle the request.

The corresponding controller then renders it's corresponding ERB template and a ERB layout that references the React application's JS. The ERB template contains a single `<div>` that is connected to the React application.
```
<%= content_tag(:div, "", id: "root", data: { controller: "react" }) %>
```

The JS and SASS for the React application are made available through the Rails application's `app/javascript/react-application.js` file which imports the `react-client/src/index.js` file.

## Running the application in development mode

To run the application in development mode run `bin/dev`. This will start the Rails application on `http://localhost:3000`.

Running in this mode sets up watchers on all of the files in this directory. That means when you make changes you do not need to restart the Rails server. You just need to wait a few seconds for the watcher to acknowledge the change and for Webpack to recompile.

When you first startup the application in this mode you should see the following in the console (ommitted a few DEPRECATION WARNING messages for old bootstrap dependencies):
```
dmptool % bin/dev
11:44:55 web.1  | started with pid 73403
11:44:55 js.1   | started with pid 73404
11:44:55 css.1  | started with pid 73405
11:44:55 css.1  | yarn run v1.22.19
11:44:55 css.1  | $ sass ./app/assets/stylesheets/application.scss:./app/assets/builds/application.css --no-source-map --load-path=node_modules --watch
11:44:56 js.1   | yarn run v1.22.19
11:44:56 js.1   | $ webpack --config ./config/webpack/webpack.config.js --watch
11:44:58 css.1  |
11:44:58 css.1  | WARNING: 55 repetitive deprecation warnings omitted.
11:44:58 css.1  | Run in verbose mode to see all warnings.
11:44:58 css.1  |
11:44:58 css.1  | [2023-06-12 11:44] Compiled app/assets/stylesheets/application.scss to app/assets/builds/application.css.
11:44:58 css.1  | Sass is watching for changes. Press Ctrl-C to stop.
11:44:58 css.1  |
11:44:58 js.1   | Running via Spring preloader in process 73414
11:44:59 web.1  | => Booting Puma
11:44:59 web.1  | => Rails 6.1.7.3 application starting in development
11:44:59 web.1  | => Run `bin/rails server --help` for more startup options
11:45:01 web.1  | Copying Bootstrap glyphicons to the public directory ...
11:45:01 web.1  | Copying TinyMCE skins to the public directory ...
11:45:01 web.1  | Setting up RackAttack Middleware: true
11:45:01 web.1  | [73406] Puma starting in cluster mode...
11:45:01 web.1  | [73406] * Puma version: 6.3.0 (ruby 3.0.4-p208) ("Mugi No Toki Itaru")
11:45:01 web.1  | [73406] *  Min threads: 5
11:45:01 web.1  | [73406] *  Max threads: 5
11:45:01 web.1  | [73406] *  Environment: development
11:45:01 web.1  | [73406] *   Master PID: 73406
11:45:01 web.1  | [73406] *      Workers: 2
11:45:01 web.1  | [73406] *     Restarts: (✔) hot (✖) phased
11:45:01 web.1  | [73406] * Preloading application
11:45:01 web.1  | [73406] * Listening on http://127.0.0.1:3000
11:45:01 web.1  | [73406] * Listening on http://[::1]:3000
11:45:01 web.1  | [73406] Use Ctrl-C to stop
11:45:01 web.1  | [73406] - Worker 0 (PID: 73426) booted in 0.02s, phase: 0
11:45:01 web.1  | [73406] - Worker 1 (PID: 73427) booted in 0.02s, phase: 0
```

Note that webpack can take a few seconds to finish compilation. During the initial startup OR anytime you save a change to one of the files in this directory, you will see the following entry in the console:
```
11:44:58 js.1   | Running via Spring preloader in process 73414
```

You should then wait for Rails Spring preloader to compile and make the change available. When it completes you will see something like (ommitting a few WARNING messages aboout the size of the older Rails application's JS):
```
11:45:08 js.1   | asset application.js 1.75 MiB [emitted] [minimized] [big] (name: application) 1 related asset
11:45:08 js.1   | asset reactApplication.js 206 KiB [emitted] [minimized] (name: reactApplication) 1 related asset
11:45:08 js.1   | orphan modules 834 KiB [orphan] 78 modules
11:45:08 js.1   | runtime modules 3.11 KiB 10 modules
11:45:08 js.1   | modules by path ./node_modules/core-js/ 549 KiB 525 modules
11:45:08 js.1   | modules by path ./app/javascript/ 859 KiB 21 modules
11:45:08 js.1   | modules by path ./node_modules/tinymce/ 2.68 MiB 17 modules
11:45:08 js.1   | modules by path ./node_modules/jquery-ui/ui/ 209 KiB 14 modules
11:45:08 js.1   | modules by path ./node_modules/bootstrap/ 73.6 KiB 13 modules
11:45:08 js.1   | modules by path ./node_modules/style-loader/dist/runtime/*.js 5.84 KiB 6 modules
11:45:08 js.1   | modules by path ./react-client/src/ 5.84 KiB 5 modules
11:45:08 js.1   | modules by path ./node_modules/number-to-text/ 4.09 KiB 3 modules
11:45:08 js.1   | modules by path ./node_modules/react-dom/ 131 KiB 3 modules
11:45:08 js.1   | modules by path ./node_modules/react/ 6.94 KiB 2 modules
11:45:08 js.1   | modules by path ./node_modules/css-loader/dist/runtime/*.js 2.31 KiB 2 modules
11:45:08 js.1   | modules by path ./node_modules/scheduler/ 4.33 KiB 2 modules
11:45:08 js.1   | + 6 modules
11:45:08 js.1   | webpack 5.86.0 compiled with 3 warnings in 11539 ms
```

## Building the application for deployment

To build the assets run `bin/rails assets:precompile`.

The build process has 2 phases.

**1st:** It will build the older Rails assets which live in `app/assets/` and `app/javascript`. The JS code becomes `public/assets/application-[fingerprint].js` and all of the SASS stylesheets become `public/application-[fingerprint].css`. All of the images and fonts are also fingerprinted and placed in `app/assets/`.

**2nd:** The React application is then built. The transpiled and minified code becomes a file called `public/assets/react-application-[fingerprint].js`.

## Data Sources

The React application uses the DMPTool's API.

### Work in progress DMPs
Work in progress DMPs are ones that a user has started the Upload DMP workflow but has not yet finished/registered the DMP.

At minimum, a valid work in progress DMP must have a title: `{ "dmp": { "title": "Test DMP" } }`

The work in progress API endpoints consist of:
- `GET api/v3/dmps` This will return all of the current user's work in progress DMPs
- `POST api/v3/dmps` Called to create the work in progress DMP and receive back a `wip_id` that should be used for subsequent updates.
- `GET api/v3/dmps/{wip_id}` This will retrieve the specific work in progress DMP (assuming the current user owns it)
- `PUT api/v3/dmps/{wip_id}` This will update the work in progress DMP (assuming the current user owns it)
- `DELETE api/v3/dmps/{wip_id}` This will delete the work in progress DMP (assuming the current user owns it)

The `POST` and `PUT` endpoints are expecting `application/x-www-form-urlencoded`.

#### PDF uploads
You can upload a PDF file by included by sending: `dmp['narrative'] = uploadedFile`

You only need to include this once. If you include it in subsequent `PUT` calls, it will replace the old file.

To completely remove the PDF, you can send `dmp['remove_narrative'] = true`

Once the PDF has been uploaded, the work in progress will contain a new `is_metadata_for` entry in the `dmproadmap_related_identifiers`. See example work in progress DMP below.

#### Example Work in Progress
The following represents a typical response from one of the `api/v3/dmps` or `api/v3/dmps/{wip_id}` endpoints. The POST and PUT body should follow the same format!

**Note:**
- The `wip_id` is assigned after calling `POST api/v3/dmps`
- The `dmproadmap_related_identifiers` may contain an `is_metadata_for` entry that is the retrieval URL for the uploaded PDF associated with the work in progress.
- The `project: title` should be the same as the top level `dmp: title` unless a funder's award API returns a project title
- The `funding_status` should always be 'granted' if a `grant_id` was discovered. If not, it should be 'planned'.

```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "POST /api/v3/dmps",
  "time": "2023-06-14T20:22:04Z",
  "caller": "::1",
  "code": 200,
  "message": "OK",
  "total_items": 0,
  "items": [
    {
      "dmp": {
        "title": "Test DMP",
        "wip_id": {
          "type": "other",
          "identifier": "20230614-f6447505e2c2"
        },
        "dmproadmap_related_identifiers": [
          {
            "type": "url",
            "descriptor": "is_metadata_for",
            "work_type": "output_management_plan",
            "identifier": "http://localhost:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBDQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--222345119a6de4db76c295210c9b1eed50e386e6/Effects_of_Placental_Dysfunction_on_Brain_Growth_in_Congenital_Heart_Disease.pdf?disposition=attachment"
          }
        ],
        "contact": [
          {
            "name": "Doe, Jane",
            "dmproadmap_affiliation": {
              "name": "Example University",
              "affiliation_id": {
                "type": "ror",
                "identifier": "https://ror.org/03yrm5c26"
              }
            },
            "role": [
              "data_curation"
            ],
            "mbox": "jane@doe.com",
            "contact_id": {
              "type": "orcid",
              "identifier": "http://orcid.org/0000-0000-0000-0001"
            }
          }
        ],
        "contributor": [
          {
            "name": "Smith, John",
            "dmproadmap_affiliation": {
              "name": "Example University",
              "affiliation_id": {
                "type": "ror",
                "identifier": "https://ror.org/03yrm5c26"
              }
            },
            "role": [
              "investigation"
            ],
            "mbox": "john@smith.com",
            "contributor_id": {
              "type": "orcid",
              "identifier": "http://orcid.org/0000-0000-0000-0000"
            }
          }
        ],
        "project": [
          {
            "title": "Title from the funder award API OR duplicate the dmp title",
            "description": "My very long project abstract",
            "start": "2023-06-16T09:44:21+00:00",
            "end": "2026-06-01T00:00:00+00:00",
            "funding": [
              {
                "dmproadmap_project_number": "prj-XYZ987-UCB",
                "grant_id": {
                  "type": "other",
                  "identifier": "776242"
                },
                "name": "National Science Foundation",
                "funder_id": {
                  "type": "fundref",
                  "identifier": "501100002428"
                },
                "funding_status": "granted",
                "dmproadmap_opportunity_number": "Award-123"
              }
            ]
          }
        ],
        "dataset": [
          {
            "type": "image",
            "title": "Fast car images",
            "description": "Field observation",
            "distribution": [
              {
                "host": {
                  "dmproadmap_host_id": {
                    "type": "url",
                    "identifier": "https://www.re3data.org/repository/r3d100000044"
                  },
                  "description": "Repository hosted by...",
                  "title": "Super Repository",
                  "url": "https://zenodo.org"
                }
              }
            ],
            "personal_data": "yes",
            "sensitive_data": "no"
          }
        ]
      }
    }
  ]
}
```

### Typeahead support
#### Current user metadata:
The following represents a typical response from one of the `api/v3/me` endpoint.
```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "GET /api/v3/me",
  "time": "2023-06-16T16:27:59Z",
  "caller": "Brian Riley",
  "code": 200,
  "message": "OK",
  "total_items": 0,
  "items": [
    {
      "name": "Riley, Brian",
      "givenname": "Brian",
      "surname": "Riley",
      "mbox": "brian@example.com",
      "affiliation": {
        "name": "University of California, Office of the President (UCOP)",
        "affiliation_id": {
          "type": "ror",
          "identifier": "https://ror.org/00pjdza24"
        }
      },
      "user_id": {
        "type": "orcid",
        "identifier": "https://orcid.org/0000-0001-7781-6508"
      }
    }
  ]
}
```

#### Funder search:
The following represents a typical response from one of the `api/v3/funders?search={term}` endpoint.

Examples of Funder search terms (including ones that have an api_target):
  - Alfred P. Sloan Foundation           <-- No api_target
  - United States Geological Survey      <-- No api_target
  - United States Department of Energy   <-- Has the Crossref api_target
  - National Institutes of Health        <-- Has the NIH api_target
  - Arctic Sciences                      <-- Has the NSF api_target

**Note that some funders may not have a Fundref id!**

```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "GET /api/v3/funders",
  "time": "2023-06-16T16:30:26Z",
  "caller": "Brian Riley",
  "code": 200,
  "message": "OK",
  "page": 1,
  "per_page": 100,
  "total_items": 2,
  "items": [
    {
      "name": "National Institutes of Health (nih.gov)",
      "funder_id": {
        "type": "fundref",
        "identifier": "https://api.crossref.org/funders/100000002"
      },
      "funder_api": "http://localhost:3000/api/v3/awards/nih",
      "funder_api_guidance": "Please enter a project/application id (e.g. 5R01AI00000, 1234567) or a combination of title keywords, PI names, FOA opportunity id (e.g. PA-11-111) and the award year.",
      "funder_api_query_fields": [
        {
          "label": "Project/Application id",
          "query_string_key": "project"
        },
        {
          "label": "FOA opportunity id",
          "query_string_key": "opportunity"
        },
        {
          "label": "PI names",
          "query_string_key": "pi_names"
        },
        {
          "label": "Title keywords",
          "query_string_key": "title"
        },
        {
          "label": "Award year",
          "query_string_key": "years"
        }
      ]
    },
    {
      "name": "National Institutes of Natural Sciences (nins.jp)",
      "funder_id": {
        "type": "fundref",
        "identifier": "https://api.crossref.org/funders/501100006321"
      }
    }
  ]
}
```

#### Award/Grant search:
The following represents a typical response from one of the `api/v3/awards/{type}` endpoints.

Examples of Award/Grant search criteria to use:
- If api_target contains '/api/v3/awards/crossref/' (e.g. 'US Department of Energy' above):
  - keywords: Particle
  - pi_names: Smith,Jones
  - years: 2021

- If api_target contains '/api/v3/awards/nih' (e.g. 'National Institutes of Health' above):
  - A Project Id
    - project: 7R21CA256680
  - OR
    - keywords: genetic
    - pi_names: Jones
    - years: 2021

- If api_target contains '/api/v3/awards/nsf' (e.g. 'Arctic Sciences' above):
  - A Project Id
    - project: 2111631
  - OR
    - keywords: atomic
    - pi_names: Jones
    - years=2022

```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "GET /api/v3/awards/crossref/100000015",
  "time": "2023-06-16T16:20:35Z",
  "caller": "Brian Riley",
  "code": 200,
  "message": "OK",
  "page": 1,
  "per_page": 100,
  "total_items": 1,
  "items": [
    {
      "project": {
        "title": "MONet Data Management and Access Gateway",
        "description": null,
        "start": "2022-5-20",
        "end": null,
        "funding": [
          {
            "dmproadmap_project_number": "60508",
            "dmproadmap_award_amount": null,
            "grant_id": {
              "identifier": "http://dx.doi.org/10.46936/intm.proj.2022.60508/60008515",
              "type": "url"
            }
          }
        ]
      },
      "contact": {
        "name": "Eberlim de Corilo, Yuri",
        "dmproadmap_affiliation": {
          "name": "Environmental Molecular Sciences Laboratory",
          "affiliation_id": {
            "identifier": "https://ror.org/04rc0xn13",
            "type": "ror"
          }
        }
      },
      "contributor": [
        {
          "name": "Fox, Kevin",
          "dmproadmap_affiliation": {
            "name": "Environmental Molecular Sciences Laboratory",
            "affiliation_id": {
              "identifier": "https://ror.org/04rc0xn13",
              "type": "ror"
            }
          }
        },
        {
          "name": "Auberry, Kenneth",
          "dmproadmap_affiliation": {
            "name": "Environmental Molecular Sciences Laboratory",
            "affiliation_id": {
              "identifier": "https://ror.org/04rc0xn13",
              "type": "ror"
            }
          }
        },
        {
          "name": "Borkum, Mark",
          "dmproadmap_affiliation": {
            "name": "Pacific Northwest National Laboratory",
            "affiliation_id": {
              "identifier": "https://ror.org/05h992307",
              "type": "ror"
            }
          }
        },
        {
          "name": "Smith, Montana",
          "dmproadmap_affiliation": {
            "name": "Environmental Molecular Sciences Laboratory",
            "affiliation_id": {
              "identifier": "https://ror.org/04rc0xn13",
              "type": "ror"
            }
          }
        },
        {
          "name": "Arokium-Christian, Natasha",
          "dmproadmap_affiliation": {
            "name": "Environmental Molecular Sciences Laboratory",
            "affiliation_id": {
              "identifier": "https://ror.org/04rc0xn13",
              "type": "ror"
            }
          }
        }
      ]
    }
  ]
}
```

#### User affiliation search:
The following represents a typical response from one of the `api/v3/orgs?search={term}` endpoint.

Example contributor affiliation search terms:
  - University of California
  - Harvard University
  - London School of Economics

**Note that some organizations do not have a ROR id!**

```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "GET /api/v3/orgs",
  "time": "2023-06-16T16:31:41Z",
  "caller": "Brian Riley",
  "code": 200,
  "message": "OK",
  "page": 1,
  "per_page": 100,
  "total_items": 4,
  "items": [
    {
      "name": "University of California Natural Reserve System (UCNRS)"
    },
    {
      "name": "University of California, Davis (ucdavis.edu)",
      "affiliation_id": {
        "type": "ror",
        "identifier": "https://ror.org/https://ror.org/05rrcem69"
      }
    },
    {
      "name": "University of California System (universityofcalifornia.edu)",
      "affiliation_id": {
        "type": "ror",
        "identifier": "https://ror.org/https://ror.org/00pjdza24"
      }
    },
    {
      "name": "University of California, Berkeley (berkeley.edu)",
      "affiliation_id": {
        "type": "ror",
        "identifier": "https://ror.org/https://ror.org/01an7q238"
      }
    }
  ]
}
```

#### Repository search:
The following represents a typical response from one of the `api/v3/repositories?search={term}` endpoint.

Example of some repository search terms:
  - Dryad
  - Zenodo
  - California

```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "GET /api/v3/repositories",
  "time": "2023-06-16T16:33:32Z",
  "caller": "Brian Riley",
  "code": 200,
  "message": "OK",
  "page": 1,
  "per_page": 100,
  "total_items": 8,
  "items": [
    {
      "name": "California water cyberinfrastructure",
      "description": "The repository is no longer available. >>>!!!<<< 2021-01-25: no more access to California Water CyberInfrastructure >>>!!!<<<",
      "url": "http://bwc.lbl.gov/California/",
      "dmproadmap_host_id": {
        "type": "url",
        "identifier": "https://www.re3data.org/api/v1/repository/r3d100000015"
      }
    },
    {
      "name": "California vectorborne disease surveillance system",
      "description": "CalSurv is a comprehensive information on West Nile virus, plague, malaria, Lyme disease, trench fever and other vectorborne diseases in California — where they are, where they’ve been, where they may be headed and what new diseases may be emerging.The CalSurv Web site serves as a portal or a single interface to all surveillance-related Web sites in California.",
      "url": "http://www.calsurv.org/",
      "dmproadmap_host_id": {
        "type": "url",
        "identifier": "https://www.re3data.org/api/v1/repository/r3d100010196"
      }
    }
  ]
}
```

#### Contributor roles:
The following represents a typical response from one of the `api/v3/contributor_roles` endpoint.

**Note the default flag**
```
{
  "application": "DMPTool - development",
  "api_version": 2,
  "source": "GET /api/v3/contributor_roles",
  "time": "2023-06-16T16:18:53Z",
  "caller": "Brian Riley",
  "code": 200,
  "message": "OK",
  "page": 1,
  "per_page": 100,
  "total_items": 4,
  "items": [
    {
      "label": "Data Manager",
      "value": "data_curation",
      "default": false
    },
    {
      "label": "Principal Investigator",
      "value": "investigation",
      "default": false
    },
    {
      "label": "Project Administrator",
      "value": "project_administration",
      "default": false
    },
    {
      "label": "Other",
      "value": "other",
      "default": true
    }
  ]
}
```

### Finalized/registered DMPs
Finalized DMPs have been assigned a DMP ID (aka persistent identifier). Once a DMP ID has been registered it is versioned and its metadata is shared externally with other systems.

Example of a finalized DMP record
```
{
  "status": 200,
  "requested": "/dmps/doi.org%2F10.48321%2FD116CAda19",
  "requested_at": "2023-06-16T16:45:31360UTC",
  "total_items": 1,
  "items": [
    {
      "dmp": {
        "contributor": [
          {
            "name": "Smith, John",
            "dmproadmap_affiliation": {
              "name": "Example University",
              "affiliation_id": {
                "type": "ror",
                "identifier": "https://ror.org/03yrm5c26"
              }
            },
            "role": [
              "Data Steward"
            ],
            "mbox": "john@smith.com",
            "contributor_id": {
              "type": "orcid",
              "identifier": "http://orcid.org/0000-0000-0000-0000"
            }
          }
        ],
        "ethical_issues_report": "http://report.location",
        "project": [
          {
            "start": "2019-04-01",
            "description": "Project develops novel...",
            "end": "2020-03-31",
            "funding": [
              {
                "dmproadmap_funded_affiliations": [
                  {
                    "name": "Our New Project",
                    "affiliation_id": {
                      "type": "ror",
                      "identifier": "https://ror.org/00pjdza24"
                    }
                  }
                ],
                "dmproadmap_project_number": "prj-XYZ987-UCB",
                "grant_id": {
                  "type": "other",
                  "identifier": "776242"
                },
                "name": "National Science Foundation",
                "funder_id": {
                  "type": "fundref",
                  "identifier": "501100002428"
                },
                "funding_status": "granted",
                "dmproadmap_opportunity_number": "Award-123"
              }
            ],
            "title": "Our New Project"
          }
        ],
        "dmproadmap_research_facilities": [
          {
            "name": "Example Research Lab",
            "type": "field_station",
            "facility_id": {
              "type": "ror",
              "identifier": "https://ror.org/03yrm5c26"
            }
          }
        ],
        "language": "eng",
        "modified": "2020-03-14T10:53:49+00:00",
        "contact": {
          "name": "Doe, Jane",
          "dmproadmap_affiliation": {
            "name": "Example University",
            "affiliation_id": {
              "type": "ror",
              "identifier": "https://ror.org/03yrm5c26"
            }
          },
          "contact_id": {
            "type": "orcid",
            "identifier": "https://orcid.org/0000-0000-0000-0000"
          },
          "mbox": "cc@example.com"
        },
        "created": "2019-03-13T13:13:00+00:00",
        "dmproadmap_related_identifiers": [
          {
            "work_type": "article",
            "identifier": "https://doi.org/10.1371/journal.pcbi.1006750",
            "descriptor": "is_cited_by",
            "type": "handle"
          }
        ],
        "dmp_id": {
          "type": "doi",
          "identifier": "https://doi.org/10.48321/D116CAda19"
        },
        "ethical_issues_exist": "yes",
        "ethical_issues_description": "There are ethical issues, because...",
        "dataset": [
          {
            "metadata": [
              {
                "metadata_standard_id": {
                  "type": "url",
                  "identifier": "http://www.dublincore.org/specifications/dublin-core/dcmi-terms/"
                },
                "description": "Provides taxonomy for...",
                "language": "eng"
              }
            ],
            "dataset_id": {
              "type": "handle",
              "identifier": "https://hdl.handle.net/11353/10.923628"
            },
            "description": "Field observation",
            "security_and_privacy": [
              {
                "title": "Physical access control",
                "description": "Server with data must be kept in a locked room"
              }
            ],
            "language": "eng",
            "distribution": [
              {
                "license": [
                  {
                    "license_ref": "https://creativecommons.org/licenses/by/4.0/",
                    "start_date": "2019-06-30"
                  }
                ],
                "byte_size": "0.69e6",
                "access_url": "http://some.repo",
                "download_url": "http://example.com/download/abc123/download",
                "format": [
                  "image/tiff"
                ],
                "host": {
                  "certified_with": "coretrustseal",
                  "storage_type": "External Hard Drive",
                  "dmproadmap_host_id": {
                    "type": "url",
                    "identifier": "https://www.re3data.org/repository/r3d100000044"
                  },
                  "geo_location": "AT",
                  "pid_system": [
                    "doi"
                  ],
                  "backup_frequency": "weekly",
                  "backup_type": "tapes",
                  "description": "Repository hosted by...",
                  "availability": "99,5",
                  "title": "Super Repository",
                  "support_versioning": "yes",
                  "url": "https://zenodo.org"
                },
                "description": "Best quality data before resizing",
                "data_access": "open",
                "title": "Full resolution images",
                "available_until": "2030-06-30"
              }
            ],
            "technical_resource": [
              {
                "dmproadmap_technical_resource_id": {
                  "type": "url",
                  "identifier": "http://www.dublincore.org/specifications/dublin-core/dcmi-terms/"
                },
                "name": "123/45/43/AT",
                "description": "Device needed to collect field data..."
              }
            ],
            "title": "Fast car images",
            "type": "image",
            "personal_data": "unknown",
            "sensitive_data": "unknown",
            "preservation_statement": "Must be preserved to enable...",
            "issued": "2019-06-30",
            "keyword": [
              "keyword 1, keyword 2"
            ],
            "data_quality_assurance": [
              "We use file naming convention..."
            ]
          }
        ],
        "cost": [
          {
            "description": "Costs for maintaining...",
            "title": "Storage and Backup",
            "value": "0.1e4",
            "currency_code": "EUR"
          }
        ],
        "description": "This DMP is for our new project",
        "title": "DMP for our new project"
      }
    }
  ],
  "errors": [],
  "page": 1,
  "per_page": 25
}
```
