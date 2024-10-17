# no clue how to use this, but i'll manage... probably...

CC := clang
CFLAGS := -cc $(CC) -d sdl_memory_no_gc -gc none 

all: project_miku

thirdparty:
	@if [ ! -f src/thirdparty/vnk/nuklear.h ]; then \
		echo "nuklear.h not found. Running make in src/thirdparty/vnk..."; \
		cd src/thirdparty/vnk && $(MAKE); \
	else \
		echo "nuklear.h found. Skipping make."; \
	fi

project_miku: thirdparty clean
	v $(CFLAGS) -o project_miku .

debug: thirdparty clean
	v $(CFLAGS) -cg -g -o project_miku .

run:
	./project_miku

clean:
	rm -f project_miku