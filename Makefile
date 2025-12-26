# If you want to download the bleeding edge build, use:
# VERSION=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][0]["version"]' | tr -d '"')
VERSION=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][1]["version"]' | tr -d '"')
URL=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][1]["x86_64-linux"]["tarball"]' | tr -d '"')
SHASUM=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][1]["x86_64-linux"]["shasum"]' | tr -d '"')


zig-x86_64-linux-$(VERSION).tar.xz:
	@curl -sO $(URL)
	@echo "Package downloaded"

.phony: latest
latest:
	@echo "Latest zig version is $(VERSION)"

.phony: verify
verify: zig-x86_64-linux-$(VERSION).tar.xz
	@if [ "$(shell shasum -a 256 zig-x86_64-linux-$(VERSION).tar.xz | cut -d" " -f1)" != "$(SHASUM)" ]; then echo "SHASUM does not match"; exit 1; else echo "SHASUM verified"; fi

.phony: setup-tools
setup-tools:
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

.phony: deb
deb: zig-x86_64-linux-$(VERSION).tar.xz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@tar xvf zig-x86_64-linux-$(VERSION).tar.xz 2>&1 > /dev/null
	@mv zig-x86_64-linux-$(VERSION)/ zig/
	@echo -n "Create zig $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager deb --target .
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@echo "Debian package created"

.phony: rpm
rpm: zig-x86_64-linux-$(VERSION).tar.xz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@tar xvf zig-x86_64-linux-$(VERSION).tar.xz 2>&1 > /dev/null
	@mv zig-x86_64-linux-$(VERSION)/ zig/
	@echo -n "Create zig $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager rpm --target .
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@echo "RPM package created"

# TODO: run a cleanup task removing go/ only once:
# see https://gist.github.com/APTy/9a9eb218f68bc0b4beb133b89c9def14

.phony: apk
apk: zig-x86_64-linux-$(VERSION).tar.xz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@tar xvf zig-x86_64-linux-$(VERSION).tar.xz 2>&1 > /dev/null
	@mv zig-x86_64-linux-$(VERSION)/ zig/
	@echo -n "Create zig $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager apk --target .
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@echo "APK package created"

.phony: clean
clean:
	@rm -rf *.deb *.rpm *.apk *.tar.xz* zig-x86_64-linux-*.tar.xz/ zig/ 
