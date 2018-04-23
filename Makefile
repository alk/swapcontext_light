
EXTRA_LDFLAGS :=

swapcontext_light.so: swapcontext_light.o
	gcc -shared -Wl,-soname,$@ -o $@ $< $(EXTRA_LDFLAGS)
