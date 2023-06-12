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
```

```

### PDFs
```
```

### Finalized/registered DMPs
Finalized DMPs have been assigned a DMP ID (aka persistent identifier). Once a DMP ID has been registered it is versioned and its metadata is shared externally with other systems.
```

```

### Typeahead support
#### Current user metadata:
```

```

#### Funder search:
```

```

#### Award/Grant search:
```

```

#### User affiliation search:
```

```

#### Repository search:
```

```

#### Contributor roles:
```

```
