#pragma once

#include <ruby.h>

#define MIN(a, b) ((a) > (b) ? (b) : (a))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

typedef char bool;
typedef char direction_t;

typedef struct {
  size_t indices[4];
} Sticker4Cycle;

void apply_sticker_cycle(VALUE* stickers, const size_t* indices, size_t size, bool invert);

void apply_sticker_4cycle(VALUE* stickers, Sticker4Cycle cycle, direction_t direction);
