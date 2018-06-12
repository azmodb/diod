REPONAME=marraison
NAME=diod
VERSION=0.1

build: Dockerfile
	@docker build --tag=$(REPONAME)/$(NAME):$(VERSION) \
		--tag=$(REPONAME)/$(NAME):latest .

push: build
	@docker push $(REPONAME)/$(NAME):$(VERSION)
	@docker push $(REPONAME)/$(NAME):latest

clean:
	@echo -n
