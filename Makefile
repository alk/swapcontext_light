
EXTRA_LDFLAGS :=

swapcontext_light.so: swapcontext_light.o
	gcc -shared -Wl,-soname,$@ -o $@ -ldl $< $(EXTRA_LDFLAGS)
