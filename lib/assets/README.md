## Set up
We use WebPack to pre-compile all our assets. Before executing any bundling, please make sure that all the dependencies are installed first by typing:

```
npm install
```
within lib/assets

## Assets Bundling

We have set up two environments, one for development which watching for changes at any .js or .css file to pre-compile on the fly and another for production. For a development environment, i.e. if the developer is making changes, please type:

```
npm run bundle
```

and for production, please type:

```
npm run bundle -- -p
```

Note, the above commands have to run within lib/assets directory.

## Testing

We use jasmine to write unit tests together with karma for testing in real browser our functionality. Please type the following command to execute every test for JavaScript modules.

```
npm test
```
