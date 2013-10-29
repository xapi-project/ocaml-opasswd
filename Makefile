# oasis driver

SOURCE_LIB=$(shell ls lib/*)
SOURCE_TEST=$(shell ls test/*)

setup.ml: _oasis
	oasis setup

setup.bin: setup.ml
	ocamlopt -o $@ $<

setup.data: setup.bin
	setup.bin -configure

build: _build/lib/oPasswd.cmxa opasswd_test.native

_build/lib/oPasswd.cmxa: $(SOURCE_LIB)
	setup.bin -build

opasswd_test.native: $(SOURCE_TEST)
	setup.bin -build

clean:
	setup.bin -clean

distclean:
	setup.bin -distclean
	rm -f setup.* myocamlbuild.ml _tags

# #BUILDFLAGS=--debug+

# .PHONY: all build clean config lib-shadow opasswd-test test

# default: all

# all: build

# config: dist/setup

# dist/setup: shadow.obuild
# 	obuild configure --enable-tests

# build: lib-passwd lib-shadow opasswd-test dist/setup

# lib-passwd: dist/build/lib-passwd/passwd.cmxa

# lib-shadow: dist/build/lib-shadow/shadow.cmxa

# opasswd-test: dist/build/opasswd-test/test-opasswd-test

# dist/build/lib-passwd/passwd.cmxa: lib/* dist/setup
# 	obuild $(BUILDFLAGS) build

# dist/build/lib-shadow/shadow.cmxa: lib/* dist/setup
# 	obuild $(BUILDFLAGS) build

# dist/build/opasswd-test/test-opasswd-test: test/* dist/setup dist/build/lib-shadow/shadow.cmxa
# 	obuild $(BUILDFLAGS) build

# test: dist/build/opasswd-test/test-opasswd-test
# 	sudo $<

# clean:
# 	obuild clean
