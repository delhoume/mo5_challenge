FRAMEHEIGHT  = 14
LINE_WIDTH = 67
FRAMES = 3410

def compress(filename):
    cline = 0
    delayvalues = []

    with open(filename, "r") as input, \
        open("delays.bin", "wb") as delays, \
        open("asciimation.pgm","wb") as pgmimage, \
        open("rawframes.bin", "wb") as frames:
        pgmimage.write(f"P5\n67 {(FRAMEHEIGHT - 1) * FRAMES}\n255\n".encode())
        while line:=  input.readline():
            noeol = line.rstrip()
            if cline % FRAMEHEIGHT == 0:
                delayvalues.append(int(noeol))
            else:
                fline = '{:<67}'.format(noeol)
                pgm_bytes = bytes(byte for byte in fline.encode())
                pgmimage.write(pgm_bytes) #same data, different header
                frames.write(pgm_bytes)
            cline = cline + 1
        delays.write(bytearray(delayvalues))

compress("asciimation.txt")
                                                     