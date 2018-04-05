if ! git ls-remote roadmap; then
  echo "No remote found for DMPRoadmap/roadmap ... adding one now"
  git remote add roadmap https://github.com/DMPRoadmap/roadmap.git
fi
git fetch origin master
echo "Fetching latest roadmap branch"
git fetch origin roadmap_master
git checkout roadmap_master
echo "Pulling down latest changes from DMPRoadmap:master"
git pull roadmap master
echo "Pushing updated branch"
git push origin roadmap_master
git checkout master
echo "Switching to the master branch"
