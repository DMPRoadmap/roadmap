if ! git ls-remote roadmap; then
  echo "No remote found for DMPRoadmap/roadmap ... adding one now"
  git remote add roadmap https://github.com/DMPRoadmap/roadmap.git
fi
echo "Fetching latest roadmap branch"
git fetch origin roadmap
git checkout roadmap
echo "Pulling down latest changes from DMPRoadmap"
git pull roadmap CDL-MVP
echo "Pushing updated branch"
git push origin roadmap
