RUSTC=rustc
RUSTCFLAGS=-C relocation-model=dynamic-no-pic -C no-stack-check -Z no-landing-pads -O -A dead-code
LD=ld
AS=nasm
QEMU=qemu-system-i386

all: harddrive.bin

kernel.o: src/kernel.rs
	$(RUSTC) $(RUSTCFLAGS) --target i686-unknown-linux-gnu --crate-type lib -o $@ --emit obj $<

kernel.bin: src/linker.ld kernel.o
	$(LD) -m elf_i386 -o $@ -T $^

filesystem/filesystem.asm:
	ls filesystem |  awk '{printf("file %d,\"%s\"\n", NR, $$0)}' > filesystem/filesystem.asm

harddrive.bin: src/loader.asm filesystem/filesystem.asm kernel.bin
	$(AS) -f bin -o $@ -ifilesystem/ -isrc/ $<

run: harddrive.bin
	$(QEMU) -serial mon:stdio -sdl -hda $<

clean:
	rm -f *.bin *.o filesystem/filesystem.asm