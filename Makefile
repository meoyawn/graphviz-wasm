VERSION=2.44.1

DIR=graphviz-$(VERSION)

deps:
	brew install emscripten automake ghostscript

# https://graphviz.org/download/source/
# https://emscripten.org/docs/compiling/Building-Projects.html
setup:
	rm -rf $(DIR)
	curl https://www2.graphviz.org/Packages/stable/portable_source/graphviz-$(VERSION).tar.gz | tar -xz

	# MACOS:
	# https://github.com/emscripten-core/emscripten/issues/10896
	sed -i -e '/-headerpad_max_install_names/d' $(DIR)/configure.ac
	cd $(DIR); autoreconf -f -i;

	# use C code as part of a build **big brain**
	cd $(DIR)/lib/gvpr; cc mkdefs.c -o mkdefs

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
		--disable-ltdl \
		--disable-tcl \
		--enable-static \
		--disable-shared \
		--prefix=prefix \
		--libdir=prefix/lib \
		CFLAGS="-Oz -w";
	cd $(DIR); emmake make lib plugin;

build:
	emcc -O3 -s WASM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS='["cwrap"]' \
		-I $(DIR) \
		-I $(DIR)/lib/common \
		-I $(DIR)/lib/gvc \
		-I $(DIR)/lib/pathplan \
		-I $(DIR)/lib/cgraph \
		-I $(DIR)/lib/cdt \
		-I $(DIR)/lib/sfio \
		-I $(DIR)/lib/ast \
		main.c \
		$(DIR)/lib/**/*.c
