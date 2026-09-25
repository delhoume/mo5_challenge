CC := clang
TARGET := mo5wars_sdl
LDLIBS := -L/opt/homebrew/lib -lSDL2


#MO5=-DMO5
CFLAGS := -I/opt/homebrew/include -O2 $(MO5)


.PHONY: all run clean

all: $(TARGET)

$(TARGET): mo5wars_sdl.c  asciimation7.bin
	$(CC) $(CFLAGS) -I. -o $@ $< $(LDLIBS)

asciimation7.bin: pack7bits
	python convert.py --delays delays.h asciimation.txt asciimation8.bin
	./pack7bits encode asciimation8.bin asciimation7.bin

pack7bits: pack7bits.c
	$(CC) -O2 -o pack7bits pack7bits.c


testpack7: pack7bits
	python convert.py -v asciimation.txt asciimation8_test.bin
	./pack7bits encode asciimation8_test.bin asciimation7_test.bin
	./pack7bits decode asciimation7_test.bin asciimation8_decoded_test.bin
	cmp -l asciimation8.bin  asciimation8_decoded_test.bin


run: $(TARGET)
	mkdir -p frames
	./$(TARGET)

clean:
	mkdir -p frames
	rm -f $(TARGET) pack7bits delays.h *.bin *.o frames/*.png