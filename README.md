# fpm-zig

A simple Makefile to create `.deb` and `.rpm` packages of the [zig compiler](https://ziglang.org/) and the [ZIG Language Server](https://github.com/zigtools/zls).

## Building a [deb|rpm|apk] package

In order to build the package for the latest version of the Zig compiler for Ubuntu or Debian based Linux distributions, run the Makefile as follows:

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

By default, the Makefile will compile the `bleeding-edge` version of the Zig compiler (e.g. 0.16.0-dev at the time of this writing). If you want to compile the stable version (e.g. `v0.15.x`), set the `BUILD_TYPE` variable to `stable`:

```bash
$> make deb BUILD_TYPE=stable
```

In order to build the ZLS package, run the following for Ubuntu/Debian based Linux distributions:

```bash
$> make zls-deb
``` 
or the following for RedHat based Linux distributions:

```bash
$> make zls-rpm
```

or the following for Alpine based Linux distributions:

```bash
$> make zls-apk
```

It will automatically checkout the latest stable version of the ZLS repository and build it, then package it.

To clean all packages and downloaded files run `make clean`.


## Prerequisites

In order to create DEB, RPM and APK packages, this project uses [nFPM](https://nfpm.goreleaser.com/); if not available locally, it uses `go install` to install it, so both `make` and `go` must already be available on the packaging machine if you don't want to install nFPM manually.
