if ! git ls-remote roadmap; then
  echo "No remote found for DMPRoadmap/roadmap ... adding one now"
  git remote add roadmap https://github.com/DMPRoadmap/roadmap.git
fi
git fetch origin development
echo "Fetching latest roadmap branch"
git fetch origin roadmap
git checkout roadmap
echo "Pulling down latest changes from DMPRoadmap/roadmap:master"
git pull roadmap master
echo "Pushing updated branch"
git push origin roadmap
git checkout development
echo "Switching to the development branch"
