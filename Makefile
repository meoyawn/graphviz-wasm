setup:
	# DOWNLOAD
	# CONFIGURE
	# FEATURE files

build:
	emcc -O3 -s WASM=1 -s EXTRA_EXPORTED_RUNTIME_METHODS='["cwrap"]' \
		-I graphviz \
		-I graphviz/lib/common \
		-I graphviz/lib/gvc \
		-I graphviz/lib/pathplan \
		-I graphviz/lib/cgraph \
		-I graphviz/lib/cdt \
		-I graphviz/lib/sfio \
		-I graphviz/lib/ast \
		-I hacks \
    main.c \
    graphviz/lib/**/*.c
