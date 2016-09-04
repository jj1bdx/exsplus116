# Makefile of test sequence generator for xorshiftplus128.c
# Written by Kenji Rikitake
# License: CC0 / public domain

CC = clang
CFLAGS = -O0 -g -Wall

OBJECTS = $(SOURCES:.c=.o)
SOURCES = xorshift116plus.c test.c test-jump.c
TESTOBJECTS = xorshift116plus.c test.c
TESTEXEC = test
TESTJUMPOBJECTS = xorshift116plus.c test-jump.c
TESTJUMPEXEC = test-jump

all: $(OBJECTS) $(TESTEXEC) $(TESTJUMPEXEC)

$(TESTEXEC): $(TESTOBJECTS)
	$(CC) $(LDFLAGS) $(TESTOBJECTS) -o $@

$(TESTJUMPEXEC): $(TESTJUMPOBJECTS)
	$(CC) $(LDFLAGS) $(TESTJUMPOBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *~
