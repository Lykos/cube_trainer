#pragma once

#include <ruby.h>
#include <stdint.h>

#define MIN(a, b) ((a) > (b) ? (b) : (a))
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define FALSE 0;
#define TRUE 1;

typedef char bool;
typedef char direction_t;

typedef struct {
  size_t indices[4];
} Sticker4Cycle;

void apply_sticker_cycle(VALUE* stickers, const size_t* indices, size_t size, bool invert);

void apply_sticker_4cycle(VALUE* stickers, Sticker4Cycle cycle, direction_t direction);

int color_eq(VALUE left, VALUE right);

int log2_64_floor(uint64_t value);

uint64_t iexp(uint64_t base, uint32_t exp);
