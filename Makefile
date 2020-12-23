VERSION=2.44.1

DIR=graphviz-$(VERSION)

deps:
	brew install emscripten automake ghostscript

native_attempt:
	rm -rf $(DIR)
	curl https://gitlab.com/graphviz/graphviz/-/archive/$(VERSION)/graphviz-$(VERSION).tar.gz | tar -xz
	cd $(DIR); ./autogen.sh; ./configure; make;

# https://graphviz.org/download/source/
# https://emscripten.org/docs/compiling/Building-Projects.html
setup:
	rm -rf $(DIR)
	curl https://gitlab.com/graphviz/graphviz/-/archive/$(VERSION)/graphviz-$(VERSION).tar.gz | tar -xz
	cd $(DIR); ./autogen.sh; emconfigure ./configure; emmake make;

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
