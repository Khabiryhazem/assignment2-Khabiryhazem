CROSS_COMPILE ?=
CC := $(CROSS_COMPILE)gcc

CFLAGS ?= -Wall -Wextra -Werror -O2
TARGET := writer
SRC := writer.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(TARGET) *.o

.PHONY: all clean
