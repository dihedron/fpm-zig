# fpm-zig

A simple Makefile to create `.deb` and `.rpm` packages of the [zig compiler](https://ziglang.org/).

## Building a [deb|rpm] package

In order to build the package for the latest verion of the zig compiler for Ubuntu or Debian based Linux distributions, run the Makefile as follows:

```bash
$> make deb
```

To build an RPM package, run as follows:

```bash
$> make rpm
```

To create an APK package (for Alpine) run:

```bash
$> make apk
```

The makefile will automatically download the `tar.xz` package from https://ziglang.org/download/ and repackages it.

To clean all packages and downloaded files run `make clean`.

## Prerequisites

In order to create DEB, RPM and APK packages, this project uses [nFPM](https://nfpm.goreleaser.com/); if not available locally, it uses `go install` to install it, so both `make` and `go` must already be available on the packaging machine if you don't want to install nFPM manually.
