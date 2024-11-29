VERSION=$(shell curl -sI https://github.com/pdfcpu/pdfcpu/releases/latest | grep -i Location | cut -d" " -f2 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
DOWNLOAD_URL=https://github.com/pdfcpu/pdfcpu/releases/download/v$(VERSION)/pdfcpu_$(VERSION)_Linux_x86_64.tar.xz

pdfcpu_$(VERSION)_Linux_x86_64.tar.xz:
	@wget $(DOWNLOAD_URL)

.phony: latest
latest:
	@echo "Latest pdfcpu version is $(VERSION)"

.phony: setup-tools
setup-tools:
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

.phony: deb
deb: pdfcpu_$(VERSION)_Linux_x86_64.tar.xz
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
	@tar xvf pdfcpu_$(VERSION)_Linux_x86_64.tar.xz 2>&1 > /dev/null
	@mv pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
	@echo -n "Create pdfcpu $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager deb --target .
	@rm -rf pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/

.phony: rpm
rpm: pdfcpu_$(VERSION)_Linux_x86_64.tar.xz
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
	@tar xvf pdfcpu_$(VERSION)_Linux_x86_64.tar.xz 2>&1 > /dev/null
	@mv pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
	@echo -n "Create pdfcpu $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager rpm --target .
	@rm -rf pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/

# TODO: run a cleanup task removing go/ only once:
# see https://gist.github.com/APTy/9a9eb218f68bc0b4beb133b89c9def14

.phony: apk
apk: pdfcpu_$(VERSION)_Linux_x86_64.tar.xz
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
	@tar xvf pdfcpu_$(VERSION)_Linux_x86_64.tar.xz 2>&1 > /dev/null
	@mv pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
	@echo -n "Create pdfcpu $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager apk --target .
	@rm -rf pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/

.phony: clean
clean:
	@rm -rf *.deb *.rpm *.apk *.tar.xz pdfcpu_$(VERSION)_Linux_x86_64/ pdfcpu/
