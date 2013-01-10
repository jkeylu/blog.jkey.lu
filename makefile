all: deploy clean

.PHONY: all

target:
	git clone git://github.com/tommy351/hexo-theme-light.git themes/light
	hexo generate
	git clone -b gh-pages git@github.com:jkeylu/blog.jkey.lu.git .deploy

deploy:
	hexo deploy
	cd .deploy/
	git push -u github gh-pages

clean:
	rm -rf .deploy/
	rm -rf public/*
	rm -rf themes/*
