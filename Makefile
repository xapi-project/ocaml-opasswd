# oasis driver

SOURCE_LIB=$(shell ls lib/*)
SOURCE_TEST=$(shell ls test/*)

.PHONY: default build clean distclean

default: build

setup.ml: _oasis
	oasis setup

setup.bin: setup.ml
	ocamlopt -o $@ $<
	rm -f setup.o setup.cmx setup.cmi

setup.data: setup.bin
	./setup.bin -configure

build: setup.data _build/lib/oPasswd.cmxa opasswd_test.native

_build/lib/oPasswd.cmxa: $(SOURCE_LIB)
	./setup.bin -build

opasswd_test.native: $(SOURCE_TEST)
	./setup.bin -build

clean: setup.bin
	./setup.bin -clean

distclean: setup.bin
	./setup.bin -distclean
	@rm -f setup.* myocamlbuild.ml _tags lib/META lib/liboPasswd_stubs.clib lib/oPasswd.mlpack

uninstall:
	ocamlfind remove oPasswd

install: _build/lib/oPasswd.cmxa
	./setup.bin -install
