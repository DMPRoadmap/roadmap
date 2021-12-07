DIRECTORY=dmptool-ui

echo $DIRECTORY

if [ -d "$DIRECTORY" ]; then
  echo "Fetching latest dmptool-ui code from GitHub ..."
  git pull origin main

  echo 'Installing dependencies ...'
  npm install

  echo 'Building assets ...'
  npm run build

  if [ -d 'dist/ui-assets/' ]; then
    echo 'Copy assets to Rails public directory ...'
    cp dist/ui-assets/*.* ../public
  else
    echo 'The build failed because no dist/ui-assets are present!'
  fi
else
  echo 'This command must be run from the project root!'
fi
