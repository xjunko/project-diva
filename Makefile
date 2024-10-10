# no clue how to use this, but i'll manage... probably...

CC := clang
CFLAGS := -cc $(CC) -d sdl_memory_no_gc -gc none 

all: project_miku

project_miku: clean
	v $(CFLAGS) -o project_miku .

debug: clean
	v $(CFLAGS) -cg -g -o project_miku .

run:
	./project_miku

clean:
	rm -f project_miku