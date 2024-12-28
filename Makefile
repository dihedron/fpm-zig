VERSION=$(shell curl -sI https://github.com/ziglang/zig/releases/latest | grep -i Location | cut -d" " -f2 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
PACKAGE_DOWNLOAD_URL=https://ziglang.org/download/$(VERSION)/zig-linux-x86_64-$(VERSION).tar.xz
SIGNATURE_DOWNLOAD_URL=https://ziglang.org/download/$(VERSION)/zig-linux-x86_64-$(VERSION).tar.xz.minisig
SIGNATURE=RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U

zig-linux-x86_64-$(VERSION).tar.xz:
	@wget $(PACKAGE_DOWNLOAD_URL)
	@wget $(SIGNATURE_DOWNLOAD_URL)

.phony: latest
latest:
	@echo "Latest zig version is $(VERSION)"

.phony: verify
verify:
	@minisign -Vm zig-linux-x86_64-$(VERSION).tar.xz -P $(SIGNATURE)

.phony: setup-tools
setup-tools:
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

.phony: deb
deb: zig-linux-x86_64-$(VERSION).tar.xz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf zig-linux-x86_64-$(VERSION).tar.xz/ zig/
	@tar xvf zig-linux-x86_64-$(VERSION).tar.xz 2>&1 > /dev/null
	@mv zig-linux-x86_64-$(VERSION)/ zig/
	@echo -n "Create zig $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager deb --target .
	@rm -rf zig-linux-x86_64-$(VERSION).tar.xz/ zig/

.phony: rpm
rpm: zig-linux-x86_64-$(VERSION).tar.xz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf zig-linux-x86_64-$(VERSION).tar.xz/ zig/
	@tar xvf zig-linux-x86_64-$(VERSION).tar.xz 2>&1 > /dev/null
	@mv zig-linux-x86_64-$(VERSION)/ zig/
	@echo -n "Create zig $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager rpm --target .
	@rm -rf zig-linux-x86_64-$(VERSION).tar.xz/ zig/


# TODO: run a cleanup task removing go/ only once:
# see https://gist.github.com/APTy/9a9eb218f68bc0b4beb133b89c9def14

.phony: apk
apk: zig-linux-x86_64-$(VERSION).tar.xz verify
ifeq ($(GITLAB_CI),)
ifeq ($(shell which nfpm),)
	@echo "Need to install nFPM first..."
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest
endif
endif
	@rm -rf zig-linux-x86_64-$(VERSION).tar.xz/ zig/
	@tar xvf zig-linux-x86_64-$(VERSION).tar.xz 2>&1 > /dev/null
	@mv zig-linux-x86_64-$(VERSION)/ zig/
	@echo -n "Create zig $(VERSION) "
	@VERSION=$(VERSION) nfpm package --packager apk --target .
	@rm -rf zig-linux-x86_64-$(VERSION).tar.xz/ zig/

.phony: clean
clean:
	@rm -rf *.deb *.rpm *.apk *.tar.xz* zig-linux-x86_64-*.tar.xz/ zig/ *.minisig
