all: compile link

compile:
	g++ -fPIC -O3 -c -m32 btime.cpp

link:
	g++ btime.o -O3 -m32 -lstdc++ -lrt -shared -Wl,-soname,btime.so -o btime.so

install:
	cp btime.so /usr/local/lib
