#!/usr/bin/env bash
set -e

# Simple deploy script: commits and pushes current folder to remote
# Usage: ./deploy.sh <branch>
BRANCH=${1:-main}
echo "Deploying to branch: $BRANCH"
git add .
git commit -m "Deploy site: updated content" || echo "No changes to commit"
git push origin $BRANCH
echo "Push complete. If you use GitHub Pages, ensure Pages is configured to serve from $BRANCH or gh-pages branch."
