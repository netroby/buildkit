BINARIES=bin/buildd bin/buildctl
BINARIES_EXTRA=bin/buildd-standalone bin/buildd-containerd bin/buildctl-darwin bin/buildd.exe bin/buildctl.exe
DESTDIR=/usr/local

binaries: $(BINARIES)
binaries-all: $(BINARIES) $(BINARIES_EXTRA)

bin/buildctl-darwin: FORCE
	mkdir -p bin
	docker build --build-arg GOOS=darwin -t buildkit:buildctl-darwin --target buildctl -f ./hack/dockerfiles/test.Dockerfile --force-rm .
	( containerID=$$(docker create buildkit:buildctl-darwin noop); \
		docker cp $$containerID:/usr/bin/buildctl $@; \
		docker rm $$containerID )
	chmod +x $@

bin/%.exe: FORCE
	mkdir -p bin
	docker build -t buildkit:$*.exe --target $*.exe -f ./hack/dockerfiles/test.Dockerfile --force-rm .
	( containerID=$$(docker create buildkit:$*.exe noop); \
		docker cp $$containerID:/$*.exe $@; \
		docker rm $$containerID )
	chmod +x $@

bin/%: FORCE
	mkdir -p bin
	docker build -t buildkit:$* --target $* -f ./hack/dockerfiles/test.Dockerfile --force-rm .
	( containerID=$$(docker create buildkit:$* noop); \
		docker cp $$containerID:/usr/bin/$* $@; \
		docker rm $$containerID )
	chmod +x $@

install: FORCE
	mkdir -p $(DESTDIR)/bin
	install $(BINARIES) $(DESTDIR)/bin

clean: FORCE
	rm -rf ./bin

test:
	./hack/test

lint:
	./hack/lint

validate-vendor:
	./hack/validate-vendor

validate-all: test lint validate-vendor

vendor:
	./hack/update-vendor

.PHONY: vendor test binaries binaries-all install clean lint validate-all validate-vendor
FORCE:
