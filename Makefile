# oasis driver

SOURCE_LIB=$(shell ls lib/*)
SOURCE_TEST=$(shell ls test/*)

DESTDIR?=/

SETUP=setup.ml setup.bin setup.data

.PHONY: default all build clean distclean test install uninstall

default: build

all: build

setup.ml: _oasis
	oasis setup

setup.bin: setup.ml
	ocamlopt -o $@ $<
	rm -f setup.o setup.cmx setup.cmi

setup.data: setup.bin
	./setup.bin -configure --enable-tests --destdir $(DESTDIR)

build: $(SETUP) _build/lib/oPasswd.cmxa opasswd_test.native

_build/lib/oPasswd.cmxa: $(SETUP) $(SOURCE_LIB)
	./setup.bin -build

opasswd_test.native: $(SETUP) $(SOURCE_TEST)
	./setup.bin -build

clean: setup.bin
	./setup.bin -clean
	@rm -f dummy-*

distclean: setup.bin
	./setup.bin -distclean
	@rm -f lib/liboPasswd_stubs.clib lib/oPasswd.mlpack
	@rm -f setup.* myocamlbuild.ml _tags lib/META

uninstall:
	ocamlfind remove oPasswd

install: $(SETUP) _build/lib/oPasswd.cmxa
	./setup.bin -install

reinstall: uninstall install

test: opasswd_test.native
	sudo ./opasswd_test.native
