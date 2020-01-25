#include "cube_state.h"

#include <stdio.h>

const int cube_faces = 6;
VALUE CubeStateClass = Qnil;

struct CubeStateData {
  int cube_size;
  VALUE* stickers;
};

int num_stickers_for_cube_size(const int cube_size) {
  return cube_faces * cube_size * cube_size;
}

int sticker_index(const int cube_size, const int face_index, const int y, const int x) {
  return face_index * cube_size * cube_size + y * cube_size + x;
}

void CubeStateData_mark(void* const ptr) {
  const struct CubeStateData* data = ptr;
  const int n = num_stickers_for_cube_size(data->cube_size);
  for (int i = 0; i < n; ++i) {
    rb_gc_mark(data->stickers[i]);
  }
}

void CubeStateData_free(void* const ptr) {
  const struct CubeStateData* const data = ptr;
  free(data->stickers);
}

size_t CubeStateData_size(const void* const ptr) {
  const struct CubeStateData* const data = ptr;
  return sizeof(int) + num_stickers_for_cube_size(data->cube_size) * sizeof(VALUE);
}

const struct rb_data_type_struct CubeStateData_type = {
  "CubeStateData",
  {CubeStateData_mark, CubeStateData_free, CubeStateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

VALUE CubeState_alloc(const VALUE klass) {
  struct CubeStateData* data;
  VALUE object = TypedData_Make_Struct(klass, struct CubeStateData, &CubeStateData_type, data);
  data->cube_size = 0;
  data->stickers = NULL;
  return object;
}

#define GetCubeStateData(obj, data) TypedData_Get_Struct((obj), struct CubeStateData, &CubeStateData_type, (data));

VALUE CubeState_initialize(const VALUE self, const VALUE cube_size, const VALUE stickers) {
  Check_Type(cube_size, T_FIXNUM);
  Check_Type(stickers, T_ARRAY);
  const int n = NUM2INT(cube_size);
  if (RARRAY_LEN(stickers) != cube_faces) {
    rb_raise(rb_eTypeError, "Cubes must have %d faces. Got %ld.", cube_faces, RARRAY_LEN(stickers));
  }
  for (int i = 0; i < cube_faces; ++i) {
    const VALUE face = rb_ary_entry(stickers, i);
    Check_Type(face, T_ARRAY);
    if (RARRAY_LEN(face) != n) {
      rb_raise(rb_eRuntimeError, "All faces of a %dx%d cube must have %d rows. Got %ld rows.", n, n, n, RARRAY_LEN(face));
    }
    for (int y = 0; y < n; ++y) {
      const VALUE row = rb_ary_entry(face, y);
      Check_Type(row, T_ARRAY);
      if (RARRAY_LEN(face) != n) {
        rb_raise(rb_eRuntimeError, "All rows of a %dx%d cube must have %d cells. Got %ld cells.", n, n, n, RARRAY_LEN(row));
      }
    }
  }
  struct CubeStateData* data;
  GetCubeStateData(self, data);
  data->cube_size = n;
  data->stickers = malloc(num_stickers_for_cube_size(n) * sizeof(VALUE));
  if (data->stickers == NULL) {
    rb_raise(rb_eRuntimeError, "Allocating cube failed.");
  }
  for (int i = 0; i < cube_faces; ++i) {
    const VALUE face = rb_ary_entry(stickers, i);
    for (int y = 0; y < n; ++y) {
      const VALUE row = rb_ary_entry(face, y);
      for (int x = 0; x < n; ++x) {
        const VALUE cell = rb_ary_entry(row, x);
        data->stickers[sticker_index(n, i, y, x)] = cell;
      }
    }
  }
  return self;
}

VALUE CubeState_entry(const VALUE self, const VALUE coordinate) {
  TypedData_Get_Struct(self, struct CubeStateData, &CubeStateData_type, data);
  
}

VALUE CubeState_store(const VALUE self, const VALUE coordinate, const VALUE value) {
  
}

void rb_init_cube_state_class_under(VALUE NativeModule) {
  CubeStateClass = rb_define_class_under(NativeModule, "CubeState", rb_cObject);
  rb_define_alloc_func(CubeStateClass, CubeState_alloc);
  rb_define_method(CubeStateClass, "initialize", CubeState_initialize, 2);
}
