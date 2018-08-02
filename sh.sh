hexo clean
rm -rf .deploy_git/
git add .
git commit -m "up"
git push origin source

#push git page

hexo generate
hexo deploy

