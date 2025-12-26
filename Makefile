# Set this to bleeding-edge or stable
BUILD_TYPE := bleeding-edge

ifeq ($(BUILD_TYPE), bleeding-edge)
VERSION=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][0]["version"]' | tr -d '"')
URL=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][0]["x86_64-linux"]["tarball"]' | tr -d '"')
SHASUM=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][0]["x86_64-linux"]["shasum"]' | tr -d '"')
else
VERSION=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][1]["version"]' | tr -d '"')
URL=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][1]["x86_64-linux"]["tarball"]' | tr -d '"')
SHASUM=$(shell curl -s https://ziglang.org/download/index.json | jq '[.[]][1]["x86_64-linux"]["shasum"]' | tr -d '"')
endif

zig-x86_64-linux-$(VERSION).tar.xz: ## download the latest package version
	@curl -sO $(URL)
	@echo "Package downloaded"

.phony: latest ## show the latest version available
latest:
	@echo "Latest zig version is $(VERSION)"

.phony: verify ## verify the downloaded package using its SHASUM
verify: zig-x86_64-linux-$(VERSION).tar.xz
	@if [ "$(shell shasum -a 256 zig-x86_64-linux-$(VERSION).tar.xz | cut -d" " -f1)" != "$(SHASUM)" ]; then echo "SHASUM does not match"; exit 1; else echo "SHASUM verified"; fi

.phony: setup-tools ## setup tools required for building
setup-tools:
	@go install github.com/goreleaser/nfpm/v2/cmd/nfpm@latest

.phony: deb ## build a Debian package
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
	@VERSION=$(VERSION) nfpm package -f zig.yaml --packager deb --target .
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@echo "Debian package created"

.phony: rpm ## build an RPM package
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
	@VERSION=$(VERSION) nfpm package -f zig.yaml --packager rpm --target .
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@echo "RPM package created"

.phony: apk ## build an APK package
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
	@VERSION=$(VERSION) nfpm package -f zig.yaml --packager apk --target .
	@rm -rf zig-x86_64-linux-$(VERSION).tar.xz/ zig/
	@echo "APK package created"

.phony: clean ## clean up

clean:
	@rm -rf *.deb *.rpm *.apk *.tar.xz* zig-x86_64-linux-*.tar.xz/ zig/ zls/

.phony: zls ## build the zig language server (ZLS)
zls:
	@git clone https://github.com/zigtools/zls.git
	@cd zls
ifeq ($(BUILD_TYPE), bleeding-edge)
	@cd zls/ && git switch master && zig build -Doptimize=ReleaseSafe
else
	@cd zls/ && git switch 0.15.x && zig build -Doptimize=ReleaseSafe
endif
	@ls -la

.phony: zls-deb ## build a Debian package for zls
zls-deb: zls
	@VERSION=$(shell zls/zig-out/bin/zls version) nfpm package -f zls.yaml --packager deb --target .

.phony: zls-rpm ## build an RPM package for zls
zls-rpm: zls
	@VERSION=$(shell zls/zig-out/bin/zls version) nfpm package -f zls.yaml --packager rpm --target .

.phony: zls-apk ## build an APK package for zls
zls-apk: zls
	@VERSION=$(shell zls/zig-out/bin/zls version) nfpm package -f zls.yaml --packager apk --target .

include help.mk