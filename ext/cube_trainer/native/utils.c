#include "utils.h"

static void swap(VALUE* const stickers, size_t i, size_t j) {
  VALUE buffer;
  buffer = stickers[i];
  stickers[i] = stickers[j];
  stickers[j] = buffer;
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
  if (direction == 2) {
    swap(stickers, cycle.indices[0], cycle.indices[2]);
    swap(stickers, cycle.indices[1], cycle.indices[3]);
  } else {
    apply_sticker_cycle(stickers, cycle.indices, 4, direction == 3);
  }
}

