# oasis driver

SOURCE_LIB=$(shell ls lib/*)
SOURCE_TEST=$(shell ls test/*)

.PHONY: default build clean distclean test install uninstall

default: build

setup.ml: _oasis
	oasis setup

setup.bin: setup.ml
	ocamlopt -o $@ $<
	rm -f setup.o setup.cmx setup.cmi

setup.data: setup.bin
	./setup.bin -configure --enable-tests

build: setup.data _build/lib/oPasswd.cmxa opasswd_test.native

_build/lib/oPasswd.cmxa: $(SOURCE_LIB)
	./setup.bin -build

opasswd_test.native: $(SOURCE_TEST)
	./setup.bin -build

clean: setup.ml
	ocaml setup.ml -clean

distclean: setup.ml
	ocaml setup.ml -distclean
	@rm -f dummy-*
	@rm -f setup.* myocamlbuild.ml _tags lib/META
	@rm -f lib/liboPasswd_stubs.clib lib/oPasswd.mlpack

uninstall:
	ocamlfind remove oPasswd

install: _build/lib/oPasswd.cmxa
	./setup.bin -install

test: opasswd_test.native
	sudo ./opasswd_test.native
