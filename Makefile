#BUILDFLAGS=--debug+

.PHONY: all build clean config lib-shadow shadow-test test

default: all

all: build

config: dist/setup

dist/setup: shadow.obuild
	obuild configure --enable-tests

build: lib-shadow shadow-test dist/setup

lib-shadow: dist/build/lib-shadow/shadow.cmxa

shadow-test: dist/build/shadow-test/test-shadow-test

dist/build/lib-shadow/shadow.cmxa: lib/* dist/setup
	obuild $(BUILDFLAGS) build

dist/build/shadow-test/test-shadow-test: test/* dist/setup dist/build/lib-shadow/shadow.cmxa
	obuild $(BUILDFLAGS) build

test: dist/build/shadow-test/test-shadow-test
	sudo $<

clean:
	obuild clean
