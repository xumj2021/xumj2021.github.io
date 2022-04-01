#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Create commit message
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi

# Build the project.
echo ""
echo ""
echo "Committing changes to $(pwd)"
hugo -D

# Go To Public folder
cd public

# Add 'public' (Github Pages repo) changes to git and commit/push.
echo ""
echo ""
echo "Committing changes to $(pwd)"
git add .
# git commit -m "test"
git commit -m "$msg"
# git push origin master
git push https://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@github.com/xumj2021/xumj2021.github.io.git

# Add this repos changes to git and commit/push. First 'cd' out of public
cd ..
echo ""
echo ""
echo "Committing changes to $(pwd)"
git add .
git commit -m "$msg"
git push https://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@github.com/xumj2021/myblog.dev.repo.git
# git remote set-url origin https://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@github.com/xumj2021/myblog.dev.repo.git
# git remote set-url origin https://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@github.com/xumj2021/xumj2021.github.io.git
<<<<<<< HEAD
>>>>>>> 451657b65a0442b21a3da12a3b5b429cc8cd4a90
# git push origin master
=======
# git push https://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@github.com/xumj2021/myblog.dev.repo.git
git push origin master
>>>>>>> 451657b65a0442b21a3da12a3b5b429cc8cd4a90
