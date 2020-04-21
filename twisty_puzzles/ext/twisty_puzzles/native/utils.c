#include "utils.h"

static void swap(VALUE* const stickers, size_t i, size_t j) {
  VALUE buffer;
  buffer = stickers[i];
  stickers[i] = stickers[j];
  stickers[j] = buffer;
}

direction_t invert_cube_direction(direction_t direction) {
  return (4 - direction) % 4;
}

direction_t invert_skewb_direction(direction_t direction) {
  return (3 - direction) % 3;
}

void apply_sticker_cycle(VALUE* const stickers, const size_t* const indices, const size_t size, const bool invert) {
  const size_t direction = invert ? size - 1 : 1;
  const size_t last_index = (direction * (size - 1)) % size;
  const VALUE buffer = stickers[indices[last_index]];
  for (size_t i = size - 1; i >= 1; --i) {
    const size_t target_index = (direction * i) % size;
    const size_t source_index = (direction * (i - 1)) % size;
    stickers[indices[target_index]] = stickers[indices[source_index]];
  }
  stickers[indices[0]] = buffer;
}

void apply_sticker_4cycle(VALUE* const stickers, const Sticker4Cycle cycle, const direction_t direction) {
  const direction_t d = (direction % 4 + 4) % 4;
  if (d == 0) {
    return;
  } else if (d == 2) {
    swap(stickers, cycle.indices[0], cycle.indices[2]);
    swap(stickers, cycle.indices[1], cycle.indices[3]);
  } else {
    apply_sticker_cycle(stickers, cycle.indices, 4, d == 3);
  }
}

int color_eq(const VALUE left, const VALUE right) {
  return RTEST(rb_equal(left, right));
}

// Magic table of values that we use for computing the log2.
static const int tab64[64] = {
    63,  0, 58,  1, 59, 47, 53,  2,
    60, 39, 48, 27, 54, 33, 42,  3,
    61, 51, 37, 40, 49, 18, 28, 20,
    55, 30, 34, 11, 43, 14, 22,  4,
    62, 57, 46, 52, 38, 26, 32, 41,
    50, 36, 17, 19, 29, 10, 13, 21,
    56, 45, 25, 31, 35, 16,  9, 12,
    44, 24, 15,  8, 23,  7,  6,  5};

int log2_64_floor(uint64_t value) {
    value |= value >> 1;
    value |= value >> 2;
    value |= value >> 4;
    value |= value >> 8;
    value |= value >> 16;
    value |= value >> 32;
    return tab64[((uint64_t)((value - (value >> 1))*0x07EDD5E59A4E28C2)) >> 58];
}

uint64_t iexp(const uint64_t base, uint32_t exp) {
  uint64_t result = 1;
  for (uint32_t m = 1 << 31; m; m >>= 1) {
    result = result * result;
    if (m & exp) {
      result *= base;
    }
  }
  return result;
}
