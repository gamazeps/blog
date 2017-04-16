publish:
	stack exec site build
	cd _site
	rm -rf .git
	git init
	git add .
	git commit -m "Site"
	git remote add github git@github.com:gamazeps/gamazeps.github.io.git
	git push -f github master
	cd ..
	git checkout master
