#include "cube_state.h"

#include <stdio.h>

#include "face_symbols.h"
#include "cube_coordinate.h"
#include "utils.h"

ID stickers_id;
ID x_base_face_symbol_id;
ID y_base_face_symbol_id;
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
  free(ptr);
}

size_t CubeStateData_size(const void* const ptr) {
  const CubeStateData* const data = ptr;
  return sizeof(CubeStateData) + num_stickers_for_cube_size(data->cube_size) * sizeof(VALUE);
}

const rb_data_type_t CubeStateData_type = {
  "CubeTrainer::Native::CubeStateData",
  {CubeStateData_mark, CubeStateData_free, CubeStateData_size, NULL},
  NULL, NULL, 0
};

VALUE CubeState_alloc(const VALUE klass) {
  CubeStateData* data;
  VALUE object = TypedData_Make_Struct(klass, CubeStateData, &CubeStateData_type, data);
  data->cube_size = 0;
  data->stickers = NULL;
  return object;
}

#define GetCubeStateData(obj, data) TypedData_Get_Struct((obj), CubeStateData, &CubeStateData_type, (data));
#define GetInitializedCubeStateData(obj, data) \
  TypedData_Get_Struct((obj), CubeStateData, &CubeStateData_type, (data)); \
  if (data->stickers == NULL) { \
    rb_raise(rb_eArgError, "Cube isn't initialized."); \
  }

int extract_index_base_face_index(const VALUE face_hash, const VALUE key) {
  const VALUE index_base_face_symbol = rb_hash_aref(face_hash, key);
  if (index_base_face_symbol == Qnil) {
    rb_raise(rb_eTypeError, "Cube faces must have keys called :{x,y}_base_face_symbol that describes which face an x or y value of 0 is close to.");
  }
  Check_Type(index_base_face_symbol, T_SYMBOL);
  return face_index(index_base_face_symbol);
}

int replace_face(const VALUE key, const VALUE value, const VALUE self) {
  const CubeStateData* data;
  GetCubeStateData(self, data);
  if (data->stickers == NULL) {
    rb_raise(rb_eArgError, "Cube isn't initialized.");
  }
  const int n = data->cube_size;
  Check_Type(value, T_HASH);
  if (RHASH_SIZE(value) != 3) {
    rb_raise(rb_eTypeError, "Cube faces must have 3 entries, got %ld.", RHASH_SIZE(value));
  }
  const int on_face_index = face_index(key);
  // Caching these keys isn't easy because the garbage collector will get them.
  const VALUE stickers = rb_hash_aref(value, ID2SYM(stickers_id));
  if (stickers == Qnil) {
    rb_raise(rb_eTypeError, "Cube faces must have a key called :stickers that contains the stickers on that face.");
  }
  const int x_base_face_index = extract_index_base_face_index(value, ID2SYM(x_base_face_symbol_id));
  const int y_base_face_index = extract_index_base_face_index(value, ID2SYM(y_base_face_symbol_id));
  Check_Type(stickers, T_ARRAY);
  if (RARRAY_LEN(stickers) != n) {
      rb_raise(rb_eArgError, "All faces of a %dx%d cube must have %d rows. Got %ld rows.", n, n, n, RARRAY_LEN(stickers));
  }
  for (int y = 0; y < n; ++y) {
    const VALUE row = rb_ary_entry(stickers, y);
    Check_Type(row, T_ARRAY);
    if (RARRAY_LEN(row) != n) {
      rb_raise(rb_eArgError, "All rows of a %dx%d cube must have %d cells. Got %ld cells.", n, n, n, RARRAY_LEN(row));
      for (int x = 0; x < n; ++x) {
        const VALUE cell = rb_ary_entry(row, x);
        data->stickers[sticker_index(n, on_face_index, x, y)] = cell;
      }
    }
  }
}

VALUE CubeState_apply_sticker_cycle(const VALUE self, const VALUE cycle) {

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
    rb_raise(rb_eArgError, "Allocating cube failed.");
  }
  for (int i = 0; i < num_stickers_for_cube_size(n); ++i) {
    data->stickers[i] = Qnil;
  }
  if (RHASH_SIZE(stickers) != cube_faces) {
    rb_raise(rb_eTypeError, "Cubes must have %d faces. Got %ld.", cube_faces, RHASH_SIZE(stickers));
  }
  rb_hash_foreach(stickers, replace_face, self);
  return self;
}

VALUE CubeState_sticker_array(const VALUE self,
                              const VALUE on_face_symbol,
                              const VALUE x_base_face_symbol,
                              const VALUE y_base_face_symbol) {
  Check_Type(face_symbol, T_SYMBOL);
  Check_Type(x_base_face_symbol, T_SYMBOL);
  Check_Type(y_base_face_symbol, T_SYMBOL);
  const FACE_INDEX on_face_index = face_index(on_face_symbol);
  const FACE_INDEX x_base_face_index = face_index(x_base_face_symbol);
  const FACE_INDEX y_base_face_index = face_index(y_base_face_symbol);
  check_base_face_indices(on_face_index, x_base_face_index, y_base_face_index);
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  const int n = data->cube_size;
  VALUE face = rb_ary_new2(n);
  for (int y = 0; y < n; ++y) {
    VALUE row = rb_ary_new2(n);
    for (int x = 0; x < n; ++x) {
      const Point point = point_on_face(on_face_index, x_base_face_index, y_base_face_index, n, x, y);
      const VALUE cell = sticker_index(n, on_face_index, x, y);
      rb_ary_store(row, x, cell);
    }
    rb_ary_store(face, y, row);
  }
  return face;
}

VALUE CubeState_entry(const VALUE self, const VALUE coordinate) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  return data->stickers[CubeCoordinate_sticker_index(coordinate, data->cube_size)];
}

VALUE CubeState_store(const VALUE self, const VALUE coordinate, const VALUE value) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  return data->stickers[CubeCoordinate_sticker_index(coordinate, data->cube_size)] = value;
}

VALUE CubeState_hash(const VALUE self) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);

  st_index_t hash = rb_hash_start(data->cube_size);
  hash = rb_hash_uint(hash, (st_index_t)CubeState_hash);
  for (int i = 0; i < data->cube_size; i++) {
    const VALUE sub_hash = rb_hash(data->stickers[i]);
    hash = rb_hash_uint(hash, NUM2LONG(sub_hash));
  }
  return ST2FIX(rb_hash_end(hash));
}

VALUE CubeState_eql(const VALUE self, const VALUE other) {
  if (self == other) {
    return Qtrue;
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    return Qfalse;
  }
  const CubeStateData* self_data;
  GetInitializedCubeStateData(self, self_data);
  const CubeStateData* other_data;
  GetInitializedCubeStateData(self, other_data);
  if (self_data->cube_size != other_data->cube_size) {
    return Qfalse;
  }
  for (int i = 0; i < self_data->cube_size; ++i) {
    if (self_data->stickers[i] != other_data->stickers[i]) {
      return Qfalse;
    }
  }
  return Qfalse;
}

void init_cube_state_class_under(VALUE NativeModule) {
  stickers_id = rb_intern("stickers");
  x_base_face_symbol_id = rb_intern("x_base_face_symbol");
  y_base_face_symbol_id = rb_intern("y_base_face_symbol");
  CubeStateClass = rb_define_class_under(NativeModule, "CubeState", rb_cObject);
  rb_define_alloc_func(CubeStateClass, CubeState_alloc);
  rb_define_method(CubeStateClass, "initialize", CubeState_initialize, 2);
  rb_define_method(CubeStateClass, "[]", CubeState_entry, 1);
  rb_define_method(CubeStateClass, "[]=", CubeState_store, 2);
  rb_define_method(CubeStateClass, "sticker_array", CubeState_sticker_array, 3);
  rb_define_method(CubeStateClass, "hash", CubeState_hash, 0);
  rb_define_method(CubeStateClass, "eql?", CubeState_eql, 1);
  rb_define_alias(CubeStateClass, "==", "eql?");
}
