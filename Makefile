VERSION=2.40.1

DIR=graphviz-$(VERSION)

PREFIX = $(abspath ./prefix)

deps:
	brew install emscripten automake ghostscript

# https://graphviz.org/download/source/
# https://emscripten.org/docs/compiling/Building-Projects.html
setup:
	rm -rf $(DIR)
	curl http://graphviz.gitlab.io/pub/graphviz/stable/SOURCES/graphviz.tar.gz | tar -xz

	# MACOS:
	# https://github.com/emscripten-core/emscripten/issues/10896
	sed -i -e '/-headerpad_max_install_names/d' $(DIR)/configure.ac
	cd $(DIR); autoreconf -f -i;

	cd $(DIR); emconfigure ./configure --quiet \
		--without-sfdp \
		--without-devil \
		--without-expat \
		--without-visio \
		--without-webp \
		--without-smyrna \
		--without-ortho \
		--without-digcola \
		--without-ipsepcola \
		--without-rsvg \
		--without-libgd \
		--disable-ltdl \
		--disable-tcl \
		--enable-static \
		--disable-shared \
		--prefix=$(PREFIX) \
		--libdir=$(PREFIX)/lib \
		CFLAGS="-Oz -w";

	# use C code as part of a build process **big brain**
	cd $(DIR)/lib/gvpr; cc mkdefs.c -o mkdefs

	cd $(DIR)/lib; emmake make;
	cd $(DIR)/plugin; emmake make;

	rm -rf $(PREFIX)

	cd $(DIR)/lib; emmake make install;
	cd $(DIR)/plugin; emmake make install;

build:
	emcc -Oz --closure 1 -sWASM=1 -sEXTRA_EXPORTED_RUNTIME_METHODS='["cwrap"]' -sFILESYSTEM=0 -sENVIRONMENT=web -sMODULARIZE=1 \
		-I $(PREFIX)/include/graphviz \
		-L $(PREFIX)/lib \
		-L $(PREFIX)/lib/graphviz \
		-lgvplugin_core -lgvplugin_dot_layout -lgvplugin_neato_layout -lcgraph -lgvc -lgvpr -lpathplan -lxdot -lcdt \
		main.c \
		-o graphviz.js
