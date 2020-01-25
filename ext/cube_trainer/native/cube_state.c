#include "cube_state.h"

#include <stdio.h>
#include <ruby/encoding.h>

#include "face_symbols.h"
#include "cube_coordinate.h"

VALUE stickers_symbol;
VALUE x_base_face_symbol_symbol;
VALUE y_base_face_symbol_symbol;
VALUE CubeStateClass = Qnil;

typedef struct {
  int cube_size;
  VALUE* stickers;
} CubeStateData;

void CubeStateData_mark(void* const ptr) {
  const CubeStateData* data = ptr;
  const int n = num_stickers_for_cube_size(data->cube_size);
  for (int i = 0; i < n; ++i) {
    rb_gc_mark(data->stickers[i]);
  }
}

void CubeStateData_free(void* const ptr) {
  const CubeStateData* const data = ptr;
  free(data->stickers);
}

size_t CubeStateData_size(const void* const ptr) {
  const CubeStateData* const data = ptr;
  return sizeof(CubeStateData) + num_stickers_for_cube_size(data->cube_size) * sizeof(VALUE);
}

const struct rb_data_type_struct CubeStateData_type = {
  "CubeTrainer::Native::CubeStateData",
  {CubeStateData_mark, CubeStateData_free, CubeStateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

VALUE CubeState_alloc(const VALUE klass) {
  CubeStateData* data;
  VALUE object = TypedData_Make_Struct(klass, CubeStateData, &CubeStateData_type, data);
  data->cube_size = 0;
  data->stickers = NULL;
  return object;
}

#define GetCubeStateData(obj, data) TypedData_Get_Struct((obj), CubeStateData, &CubeStateData_type, (data));

int extract_index_base_face_index(const VALUE face_hash, const VALUE key) {
  const VALUE index_base_face_symbol = rb_hash_aref(face_hash, key);
  if (index_base_face_symbol == Qnil) {
    rb_raise(rb_eTypeError, "Cube faces must have keys called :{x,y}_base_face_symbol that describes which face an x or y value of 0 is close to.");
  }
  Check_Type(index_base_face_symbol, T_SYMBOL);
  return face_index(index_base_face_symbol);
}

int replace_face(VALUE key, VALUE value, VALUE self) {
  CubeStateData* data;
  GetCubeStateData(self, data);
  const int n = data->cube_size;
  Check_Type(value, T_HASH);
  if (RHASH_SIZE(value) != 3) {
    rb_raise(rb_eTypeError, "Cube faces must have 3 entries, got %ld.", RHASH_SIZE(value));
  }
  const int on_face_index = face_index(key);
  const int x_base_face_index = extract_index_base_face_index(value, x_base_face_symbol_symbol);
  const int y_base_face_index = extract_index_base_face_index(value, y_base_face_symbol_symbol);
  const VALUE stickers = rb_hash_aref(value, stickers_symbol);
  if (stickers == Qnil) {
    rb_raise(rb_eTypeError, "Cube faces must have keys called :stickers that contains the stickers on that face.");
  }
  Check_Type(stickers, T_ARRAY);
  if (RARRAY_LEN(stickers) != n) {
      rb_raise(rb_eRuntimeError, "All faces of a %dx%d cube must have %d rows. Got %ld rows.", n, n, n, RARRAY_LEN(stickers));    
  }
  for (int y = 0; y < n; ++y) {
    const VALUE row = rb_ary_entry(stickers, y);
    Check_Type(row, T_ARRAY);
    if (RARRAY_LEN(row) != n) {
      rb_raise(rb_eRuntimeError, "All rows of a %dx%d cube must have %d cells. Got %ld cells.", n, n, n, RARRAY_LEN(row));
      for (int x = 0; x < n; ++x) {
        const VALUE cell = rb_ary_entry(row, x);
        data->stickers[sticker_index(n, on_face_index, x, y)] = cell;
      }
    }
  }
}

VALUE CubeState_initialize(const VALUE self, const VALUE cube_size, const VALUE stickers) {
  Check_Type(cube_size, T_FIXNUM);
  Check_Type(stickers, T_HASH);
  const int n = NUM2INT(cube_size);
  CubeStateData* data;
  GetCubeStateData(self, data);
  data->cube_size = n;
  data->stickers = malloc(num_stickers_for_cube_size(n) * sizeof(VALUE));
  if (data->stickers == NULL) {
    rb_raise(rb_eRuntimeError, "Allocating cube failed.");
  }
  if (RHASH_SIZE(stickers) != cube_faces) {
    rb_raise(rb_eTypeError, "Cubes must have %d faces. Got %ld.", cube_faces, RHASH_SIZE(stickers));
  }
  rb_hash_foreach(stickers, replace_face, self);
  return self;
}

VALUE CubeState_entry(const VALUE self, const VALUE coordinate) {
  CubeStateData* data;
  GetCubeStateData(self, data);
  return data->stickers[CubeCoordinate_sticker_index(coordinate)];
}

VALUE CubeState_store(const VALUE self, const VALUE coordinate, const VALUE value) {
  CubeStateData* data;
  GetCubeStateData(self, data);
  return data->stickers[CubeCoordinate_sticker_index(coordinate)] = value;
}

void rb_init_cube_state_class_under(VALUE NativeModule) {
  const rb_encoding* ascii = rb_enc_find("ASCII");
  stickers_symbol = rb_check_symbol_cstr("stickers", 8, ascii);
  x_base_face_symbol_symbol = rb_check_symbol_cstr("x_base_face_symbol", 18, ascii);
  y_base_face_symbol_symbol = rb_check_symbol_cstr("y_base_face_symbol", 18, ascii);
  CubeStateClass = rb_define_class_under(NativeModule, "CubeState", rb_cObject);
  rb_define_alloc_func(CubeStateClass, CubeState_alloc);
  rb_define_method(CubeStateClass, "initialize", CubeState_initialize, 2);
  rb_define_method(CubeStateClass, "[]", CubeState_entry, 1);
  rb_define_method(CubeStateClass, "[]=", CubeState_store, 2);
}
