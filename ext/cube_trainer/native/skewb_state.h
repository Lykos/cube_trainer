#pragma once

#include <ruby.h>

#include "face_symbols.h"

#define skewb_faces cube_faces
#define skewb_stickers_per_face 5
#define total_skewb_stickers skewb_stickers_per_face * skewb_faces

void init_skewb_state_class_under(VALUE module);
