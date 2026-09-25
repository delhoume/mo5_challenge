import argparse
from pathlib import Path
import sys
from collections import Counter


gline = 0
pairs = []
tris = []
spaces = []


def parse_args():
    parser = argparse.ArgumentParser(description="Convert ASCII animation frames to compact 7-bit output.")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="display histogram and per-frame trace information")
    parser.add_argument("--delays", nargs="?", const="delays.h", default=None,
                        help="write the C delay array to a header file; defaults to 'delays.h' when enabled")
    parser.add_argument("input_file", nargs="?", default="asciimation.txt",
                        help="input animation file to process")
    parser.add_argument("output_file", nargs="?", default="asciimation8.bin",
                        help="output binary file to write")
    return parser.parse_args()

def consecutive(s):
    #    Initialize result list
    res = []
    count = 1

    # Iterate through the string to count consecutive characters
    for i in range(1, len(s)):
        if s[i] == s[i - 1]:
            count += 1
        else:
            res.append(s[i - 1] * count)
            count = 1
    res.append(s[-1] * count)  # Append last group
    return res

def readframe(input, delays, origframes, frames, verbose=False):
    global gline
    global pairs
    global tris
    global spaces

    line = input.readline()
    gline = gline + 1
    if line == "":
        return False

    if line.strip() == "":
        return False

    try:
        delay = int(line.strip())
    except ValueError:
        print(f"warning: invalid delay at line {gline}: {line!r}", file=sys.stderr)
        return False

    delays.append(delay)
    for r in range(13):
        line = input.readline()
        origframes.append(line)
        gline = gline + 1
        if line == "":
            print(f"warning: truncated frame at line {gline}; stopping conversion cleanly.", file=sys.stderr)
            return False
        cs = consecutive(line)
        newline = []

        repeat = [len(c) for c in cs]
        for css in cs:
            if css and css[0] == " ":
                spaces.append(css)
            csslen = len(css)
            if csslen == 1:
                newline.append(css)
            if csslen == 2:
                pairs.append(css)
                if css == "  ":
                    newline.append(chr(4))
                elif css == "||":
                    newline.append(chr(5))
                elif css == "//":
                    newline.append(chr(6))
                elif css == "\\\\":
                    newline.append(chr(7))
                elif css == "__":
                    newline.append(chr(8))
                else:
                    newline.append(css)
            if csslen == 3:
                tris.append(css)
                if css == "   ":
                    newline.append(chr(9))
                else:
                    newline.append(css)
            if csslen > 3:
                if css[0] == " ":
                    if csslen >= 4 and csslen <= 12:
                        newline.append(chr(11 + csslen - 4))
                    else:
                        newline.append(chr(3) + chr(csslen) + css[0])
                else:
                    newline.append(chr(3) + chr(csslen) + css[0])
        newline = "".join(newline)
        if verbose:
            print(f"--{gline}")
            print(f"orig {len(line)} : {line[:-1]}")
            print(f"consecutive {cs}")
            print(f"repeat {repeat}")
            print(f"newline {len(newline)}: {[(c if ord(c) > 20 else ord(c)) for c in newline]}")
        frames.append(newline)
    return True


# Global stream state variables
g_buffer = bytearray()
g_bit_offset = 0

def write_7_bits_global(ascii_val: int):
    """
    Packs a 7-bit ASCII value into the global byte buffer.
    """
    global g_bit_offset, g_buffer
    
    # Ensure value fits in 7 bits
    ascii_val &= 0x7F 
    
    if g_bit_offset == 0:
        # Condition 1: Starting clean at a fresh byte boundary
        # Shift left by 1 to leave room for the next bits at the bottom
        g_buffer.append(ascii_val << 1)
    else:
        # Condition 2: Writing across boundaries or into an existing byte
        # Calculate how many bits spill over into the next byte
        spill_bits = (g_bit_offset + 7) - 8
        
        if spill_bits <= 0:
            # Fits entirely inside the current active byte
            shift_amount = 1 - g_bit_offset
            if shift_amount >= 0:
                g_buffer[-1] |= (ascii_val << shift_amount)
            else:
                g_buffer[-1] |= (ascii_val >> abs(shift_amount))
        else:
            # Straddles across the current byte and a new trailing byte
            g_buffer[-1] |= (ascii_val >> (spill_bits - 1))
            g_buffer.append((ascii_val << (9 - g_bit_offset)) & 0xFF)
            
    # Update global tracking variables
    g_bit_offset += 7
    if g_bit_offset >= 8:
        g_bit_offset -= 8   
    return bytes(g_buffer)

def process(input_file, output_file="asciimation8.bin", verbose=False, delays_output=None):
    delays = []
    frames = []
    origframes = []
    valid_frames = 0
    with open(input_file, "r") as input:
        go = readframe(input, delays, origframes, frames, verbose=verbose)
        while go:
            valid_frames += 1
            go = readframe(input, delays, origframes, frames, verbose=verbose)

    if valid_frames == 0:
        print(f"warning: no valid frames parsed from {input_file!r}", file=sys.stderr)

    if delays_output is not None:
        with open(delays_output, "w") as delaysinc:
            delaysinc.write(r'int  delays[] = {')
            delaysinc.write(",".join(str(n) for n in delays))
            delaysinc.write('};')

    if frames:
        allframes = "".join(frames)
        with open(output_file, "wb") as binout8:
            binout8.write(bytes(allframes, "ascii"))
    else:
        open(output_file, "wb").close()

    allorigframes = "".join(origframes)

    if valid_frames:
        print(f"parsed {valid_frames} valid frames from {input_file}")

    if verbose:
        histogram = Counter(c for c in allorigframes if ord(c) < 128)
        print("ASCII character histogram:")
        for char, count in sorted(histogram.items(), key=lambda item: ord(item[0])):
            label = repr(char)
            print(f"{ord(char):3} {label:4} {count}")

        histopairs = Counter(pairs)
        print("PAIR histogram:")
        for char, count in sorted(histopairs.items(), key=lambda item: item[0]):
            print(f"{char} {count}")

        histotris = Counter(spaces)
        print("SPACES histogram:")
        for char, count in sorted(histotris.items(), key=lambda item: len(item)):
            print(f"{len(char)} {count}")

    origlen = len(allorigframes)
    compressedlen = len(allframes)
    gain = int(100 * (origlen - compressedlen) / origlen) if origlen else 0
    print(f"original size: {origlen}, compressed {compressedlen}, gain: {gain}%")


if __name__ == "__main__":
    args = parse_args()
    process(args.input_file, output_file=args.output_file, verbose=args.verbose,
            delays_output=args.delays)

