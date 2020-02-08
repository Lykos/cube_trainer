#pragma once

#include <ruby.h>

#include "skewb_coordinate.h"
#include "utils.h"

typedef struct {
  VALUE stickers[total_skewb_stickers];
} SkewbStateData;

extern const rb_data_type_t SkewbStateData_type;

#define GetSkewbStateData(obj, data)            \
  do { \
    TypedData_Get_Struct((obj), SkewbStateData, &SkewbStateData_type, (data)); \
  } while (0)

void rotate_corner_for_skewb_state(Corner corner, direction_t direction, VALUE skewb_state);

void rotate_skewb_state(face_index_t axis_face_index, direction_t direction, VALUE skewb_state);

void init_skewb_state_class_under(VALUE module);
