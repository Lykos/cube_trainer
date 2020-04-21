#pragma once

#include <ruby.h>

#include "face_symbols.h"

typedef struct {
  size_t cube_size;
  VALUE* stickers;
} CubeStateData;

extern const rb_data_type_t CubeStateData_type;

#define GetCubeStateData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), CubeStateData, &CubeStateData_type, (data)); \
  } while (0)

#define GetInitializedCubeStateData(obj, data)  \
  do { \
    GetCubeStateData((obj), (data)); \
    if (data->stickers == NULL) { \
      rb_raise(rb_eArgError, "Cube state isn't initialized."); \
    } \
  } while(0)

void rotate_slice_for_cube(face_index_t turned_face_index, size_t slice_index, direction_t direction, const CubeStateData* data);

void rotate_face_for_cube(face_index_t turned_face_index, direction_t direction, const CubeStateData* data);

void init_cube_state_class_under(VALUE module);
