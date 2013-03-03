.PHONY: deploy clean

target:
	git clone git://github.com/tommy351/hexo-theme-light.git themes/light
	mv themes/light/_config.yml themes/light/_config.yml.old
	cp themes.light._config.yml themes/light/_config.yml
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
