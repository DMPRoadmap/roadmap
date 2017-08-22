## Bundle for development
```
    npm run bundle
```

## Bundle for production:
```
    npm run bundle -- -p
```
Remember this will generated output files with a new hash associated in order to prevent browser to use a previous cached version. You will need to stop and start the rails server.