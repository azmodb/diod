REPONAME=marraison
NAME=diod
VERSION=0.3

build: Dockerfile
	@docker build --tag=$(REPONAME)/$(NAME):$(VERSION) .

push: build
	@docker push $(REPONAME)/$(NAME):$(VERSION)

clean:
	@echo -n
