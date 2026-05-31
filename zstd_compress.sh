#/bin/bash

rm -rf frames
mkdom frames
split -n 62 -d rawframes.bin frames/frame_
ls -1 frames/frame*|  parallel --bar zstd -f -19 {} -o {}.zst
cat frames/frame*.zst > rawframes.bin.zst


# partly automated
# retrieve sizes
ls -1 frames/frame*.zst |parallel -j 1 "cat {} | wc -c"