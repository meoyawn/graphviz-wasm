VERSION=2.44.1

DIR=graphviz-$(VERSION)

deps:
	brew install emscripten ghostscript

# https://graphviz.org/download/source/
# https://emscripten.org/docs/compiling/Building-Projects.html
setup:
	rm -rf $(DIR)
	curl https://www2.graphviz.org/Packages/stable/portable_source/graphviz-$(VERSION).tar.gz | tar -xz

	# MACOS:
	# https://github.com/emscripten-core/emscripten/issues/10896
	# sed -i -e '351d;379d' $(DIR)/configure.ac
	# cd $(DIR); autoreconf -f -i;

	cd $(DIR); emconfigure ./configure; emmake make;

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
