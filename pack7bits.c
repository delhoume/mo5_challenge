#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int decode(unsigned char *input, unsigned char *output, unsigned int numtodecode) {
  unsigned int acc = 0;
  unsigned int bits = 0;
  unsigned char *savedout = output;

  while (numtodecode--) {
    acc |= ((unsigned int)(*input++)) << bits;
    bits += 8;

    while (bits >= 7) {
      *output++ = (unsigned char)(acc & 0x7fu);
      acc >>= 7;
      bits -= 7;
    }
  }
  return (int)(output - savedout);
}

unsigned int encode(unsigned char *input, unsigned char *output, unsigned int input_size) {
  unsigned int acc = 0;
  unsigned int bits = 0;
  unsigned char *savedout = output;

  for (unsigned int i = 0; i < input_size; ++i) {
    acc |= ((unsigned int)input[i]) << bits;
    bits += 7;

    while (bits >= 8) {
      *output++ = (unsigned char)(acc & 0xffu);
      acc >>= 8;
      bits -= 8;
    }
  }

  if (bits > 0) {
    *output++ = (unsigned char)acc;
  }

  return (unsigned int)(output - savedout);
}

static int read_file(const char *path, unsigned char **data, unsigned int *size) {
  FILE *f = fopen(path, "rb");
  if (!f) {
    fprintf(stderr, "error in reading %s\n", path);
    return 0;
  }
  if (fseek(f, 0, SEEK_END) != 0) {
    fclose(f);
    return 0;
  }
  long file_size = ftell(f);
  if (file_size < 0) {
    fclose(f);
    return 0;
  }
  rewind(f);
  *size = (unsigned int)file_size;
  *data = (unsigned char *)malloc(*size + 1);
  if (!*data) {
    fclose(f);
    return 0;
  }
  size_t read_count = fread(*data, 1, *size, f);
  fclose(f);
  if (read_count != (size_t)*size) {
    free(*data);
    *data = NULL;
    *size = 0;
    return 0;
  }
  (*data)[*size] = 0;
  return 1;
}

static int write_file(const char *path, const unsigned char *data, unsigned int size) {
  FILE *f = fopen(path, "wb");
  if (!f) {
    fprintf(stderr, "error in writing %s\n", path);
    return 0;
  }

  size_t written = fwrite(data, 1, size, f);
  fclose(f);
  return written == size;
}

static void print_summary(const char *mode, unsigned int input_size,
                          unsigned int output_size) {
  if (strcmp(mode, "encode") == 0) {
    double ratio = input_size == 0 ? 0.0 : ((double)output_size / (double)input_size) * 100.0;
    double saved = input_size == 0 ? 0.0 : 100.0 - ratio;
    printf("input size: %u bytes\n", input_size);
    printf("output size: %u bytes\n", output_size);
    printf("compression level: %.2f%% of original (%.2f%% saved)\n", ratio, saved);
    return;
  }

  printf("input size: %u bytes\n", input_size);
  printf("decoded size: %u bytes\n", output_size);
}

int main(int argc, char *argv[]) {
  if (argc != 4) {
    fprintf(stderr, "usage:\n  %s encode input.bin output.7b\n  %s decode input.7b output.bin\n",
            argv[0], argv[0]);
    return 1;
  }

  const char *mode = argv[1];
  const char *input_path = argv[2];
  const char *output_path = argv[3];

  unsigned char *input = NULL;
  unsigned int input_size = 0;

  if (!read_file(input_path, &input, &input_size)) {
    return 1;
  }

  if (strcmp(mode, "encode") == 0) {
    unsigned char *packed = (unsigned char *)malloc(input_size * 2 + 1);
    if (!packed) {
      free(input);
      return 1;
    }

    unsigned int packed_size = encode(input, packed, input_size);
    int ok = write_file(output_path, packed, packed_size);
    free(packed);
    free(input);

    if (ok) {
      print_summary(mode, input_size, packed_size);
      return 0;
    }
    return 1;
  }

  if (strcmp(mode, "decode") == 0) {
    unsigned char *decoded = (unsigned char *)malloc(input_size * 8 + 1);
    if (!decoded) {
      free(input);
      return 1;
    }

    unsigned int decoded_size = decode(input, decoded, input_size);
    int ok = write_file(output_path, decoded, decoded_size);
    free(decoded);
    free(input);

    if (ok) {
      print_summary(mode, input_size, decoded_size);
      return 0;
    }
    return 1;
  }

  fprintf(stderr, "unknown mode: %s\nexpected encode or decode\n", mode);
  free(input);
  return 1;
}