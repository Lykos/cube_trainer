#include "cube_state.h"

#include <stdio.h>

#include "cube_coordinate.h"
#include "utils.h"

static ID stickers_id = 0;
static ID x_base_face_symbol_id = 0;
static ID y_base_face_symbol_id = 0;
static VALUE CubeStateClass = Qnil;

static void CubeStateData_mark(void* const ptr) {
  const CubeStateData* data = ptr;
  const size_t n = data->cube_size;
  for (size_t i = 0; i < num_stickers(n); ++i) {
    rb_gc_mark(data->stickers[i]);
  }
}

static void CubeStateData_free(void* const ptr) {
  const CubeStateData* const data = ptr;
  free(data->stickers);
  free(ptr);
}

static size_t CubeStateData_size(const void* const ptr) {
  const CubeStateData* const data = ptr;
  return sizeof(CubeStateData) + num_stickers(data->cube_size) * sizeof(VALUE);
}

const rb_data_type_t CubeStateData_type = {
  "CubeTrainer::Native::CubeStateData",
  {CubeStateData_mark, CubeStateData_free, CubeStateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY  
};

static VALUE* malloc_stickers(const size_t n) {
  VALUE* const stickers = malloc(num_stickers(n) * sizeof(VALUE));
  if (stickers == NULL) {
    rb_raise(rb_eNoMemError, "Allocating cube state failed.");
  }
  return stickers;
}

static VALUE CubeState_alloc(const VALUE klass) {
  CubeStateData* data;
  const VALUE object = TypedData_Make_Struct(klass, CubeStateData, &CubeStateData_type, data);
  data->cube_size = 0;
  data->stickers = NULL;
  return object;
}

static size_t extract_index_base_face_index(const VALUE face_hash, const VALUE key) {
  const VALUE index_base_face_symbol = rb_hash_aref(face_hash, key);
  if (index_base_face_symbol == Qnil) {
    rb_raise(rb_eTypeError, "Cube faces must have keys called :{x,y}_base_face_symbol that describes which face an x or y value of 0 is close to.");
  }
  Check_Type(index_base_face_symbol, T_SYMBOL);
  return face_index(index_base_face_symbol);
}

static int CubeState_replace_face(const VALUE key, const VALUE value, const VALUE self) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  const size_t n = data->cube_size;
  Check_Type(value, T_HASH);
  if (RHASH_SIZE(value) != 3) {
    rb_raise(rb_eTypeError, "Cube faces must have 3 entries, got %ld.", RHASH_SIZE(value));
  }
  const face_index_t on_face_index = face_index(key);
  // Caching these keys isn't easy because the garbage collector will get them.
  const VALUE stickers = rb_hash_aref(value, ID2SYM(stickers_id));
  if (stickers == Qnil) {
    rb_raise(rb_eTypeError, "Cube faces must have a key called :stickers that contains the stickers on that face.");
  }
  const face_index_t x_base_face_index = extract_index_base_face_index(value, ID2SYM(x_base_face_symbol_id));
  const face_index_t y_base_face_index = extract_index_base_face_index(value, ID2SYM(y_base_face_symbol_id));
  Check_Type(stickers, T_ARRAY);
  if (RARRAY_LEN(stickers) != n) {
      rb_raise(rb_eArgError, "All faces of a %ldx%ld cube must have %ld rows. Got %ld rows.", n, n, n, RARRAY_LEN(stickers));
  }
  for (size_t y = 0; y < n; ++y) {
    const VALUE row = rb_ary_entry(stickers, y);
    Check_Type(row, T_ARRAY);
    if (RARRAY_LEN(row) != n) {
      rb_raise(rb_eArgError, "All rows of a %ldx%ld cube must have %ld cells. Got %ld cells.", n, n, n, RARRAY_LEN(row));
    }
    for (size_t x = 0; x < n; ++x) {
      const VALUE cell = rb_ary_entry(row, x);
      Point point = {x, y};
      data->stickers[sticker_index(n, on_face_index, point)] = cell;
    }
  }
  return ST_CONTINUE;
}

static VALUE CubeState_initialize(const VALUE self, const VALUE cube_size, const VALUE stickers) {
  Check_Type(cube_size, T_FIXNUM);
  Check_Type(stickers, T_HASH);
  const size_t n = FIX2INT(cube_size);
  CubeStateData* data;
  GetCubeStateData(self, data);
  data->cube_size = n;
  data->stickers = malloc_stickers(n);
  for (size_t i = 0; i < num_stickers(n); ++i) {
    data->stickers[i] = Qnil;
  }
  if (RHASH_SIZE(stickers) != cube_faces) {
    rb_raise(rb_eTypeError, "Cubes must have %d faces. Got %ld.", cube_faces, RHASH_SIZE(stickers));
  }
  rb_hash_foreach(stickers, CubeState_replace_face, self);
  return self;
}

static VALUE CubeState_sticker_array(const VALUE self,
                                     const VALUE on_face_symbol,
                                     const VALUE x_base_face_symbol,
                                     const VALUE y_base_face_symbol) {
  Check_Type(on_face_symbol, T_SYMBOL);
  Check_Type(x_base_face_symbol, T_SYMBOL);
  Check_Type(y_base_face_symbol, T_SYMBOL);
  const face_index_t on_face_index = face_index(on_face_symbol);
  const face_index_t x_base_face_index = face_index(x_base_face_symbol);
  const face_index_t y_base_face_index = face_index(y_base_face_symbol);
  check_base_face_indices(on_face_index, x_base_face_index, y_base_face_index);
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  const size_t n = data->cube_size;
  const VALUE face = rb_ary_new2(n);
  for (size_t y = 0; y < n; ++y) {
    const VALUE row = rb_ary_new2(n);
    for (size_t x = 0; x < n; ++x) {
      const Point point = point_on_face(on_face_index, x_base_face_index, y_base_face_index, n, x, y);
      const VALUE cell = data->stickers[sticker_index(n, on_face_index, point)];
      rb_ary_store(row, x, cell);
    }
    rb_ary_store(face, y, row);
  }
  return face;
}

static VALUE CubeState_entry(const VALUE self, const VALUE coordinate) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  return data->stickers[CubeCoordinate_sticker_index(coordinate, data->cube_size)];
}

static VALUE CubeState_store(const VALUE self, const VALUE coordinate, const VALUE value) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  return data->stickers[CubeCoordinate_sticker_index(coordinate, data->cube_size)] = value;
}

static VALUE CubeState_hash(const VALUE self) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);

  st_index_t hash = rb_hash_start(data->cube_size);
  hash = rb_hash_uint(hash, (st_index_t)CubeState_hash);
  const size_t n = data->cube_size;
  for (size_t i = 0; i < num_stickers(n); i++) {
    const VALUE sub_hash = rb_hash(data->stickers[i]);
    hash = rb_hash_uint(hash, NUM2LONG(sub_hash));
  }
  return ST2FIX(rb_hash_end(hash));
}

static VALUE CubeState_eql(const VALUE self, const VALUE other) {
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
  const size_t n = self_data->cube_size;
  for (size_t i = 0; i < num_stickers(n); ++i) {
    if (!color_eq(self_data->stickers[i], other_data->stickers[i])) {
      return Qfalse;
    }
  }
  return Qtrue;
}

static VALUE CubeState_dup(const VALUE self) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  const size_t n = data->cube_size;
  CubeStateData* dupped_data;
  const VALUE dupped = TypedData_Make_Struct(rb_obj_class(self), CubeStateData, &CubeStateData_type, dupped_data);
  dupped_data->cube_size = n;
  dupped_data->stickers = malloc_stickers(n);
  memcpy(dupped_data->stickers, data->stickers, num_stickers(n) * sizeof(VALUE));
  return dupped;
}

static VALUE CubeState_cube_size(const VALUE self) {
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  return ST2FIX(data->cube_size);
}

void rotate_slice_for_cube(const face_index_t turned_face_index, const size_t slice_index, direction_t direction, const CubeStateData* const data) {
  direction = CROP_MOD(direction, 4);
  if (direction == 0) {
    return;
  }
  const size_t n = data->cube_size;
  for (size_t i = 0; i < n; ++i) {
    Sticker4Cycle cycle;
    for (size_t j = 0; j < neighbor_faces; ++j) {
      const face_index_t on_face_index = neighbor_face_index(turned_face_index, j);
      const face_index_t next_face_index = neighbor_face_index(turned_face_index, j + 1);
      const Point point = point_on_face(on_face_index, turned_face_index, next_face_index, n, slice_index, i);
      cycle.indices[j] = sticker_index(n, on_face_index, point);
    }
    apply_sticker_4cycle(data->stickers, cycle, direction);
  }  
}

static VALUE CubeState_rotate_slice(const VALUE self, const VALUE turned_face_symbol, const VALUE slice_index, const VALUE direction) {
  Check_Type(turned_face_symbol, T_SYMBOL);
  Check_Type(slice_index, T_FIXNUM);
  Check_Type(direction, T_FIXNUM);
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  rotate_slice_for_cube(face_index(turned_face_symbol), FIX2INT(slice_index), FIX2INT(direction), data);
  return Qnil;
}

void rotate_face_for_cube(const face_index_t turned_face_index, direction_t direction, const CubeStateData* const data) {
  direction = CROP_MOD(direction, 4);
  if (direction == 0) {
    return;
  }
  const size_t n = data->cube_size;
  for (size_t y = 0; y < n / 2; ++y) {
    for (size_t x = 0; x < (n + 1) / 2; ++x) {
      Sticker4Cycle cycle;
      for (size_t j = 0; j < neighbor_faces; ++j) {
        const face_index_t x_face_index = neighbor_face_index(turned_face_index, j);
        const face_index_t y_face_index = neighbor_face_index(turned_face_index, j + 1);
        const Point point = point_on_face(turned_face_index, x_face_index, y_face_index, n, x, y);
        cycle.indices[j] = sticker_index(n, turned_face_index, point);
      }
      apply_sticker_4cycle(data->stickers, cycle, direction);
    }
  }
}

static VALUE CubeState_rotate_face(const VALUE self, const VALUE turned_face_symbol, const VALUE direction) {
  Check_Type(turned_face_symbol, T_SYMBOL);
  Check_Type(direction, T_FIXNUM);
  const CubeStateData* data;
  GetInitializedCubeStateData(self, data);
  rotate_face_for_cube(face_index(turned_face_symbol), FIX2INT(direction), data);
  return Qnil;
}

void init_cube_state_class_under(const VALUE module) {
  stickers_id = rb_intern("stickers");
  x_base_face_symbol_id = rb_intern("x_base_face_symbol");
  y_base_face_symbol_id = rb_intern("y_base_face_symbol");
  CubeStateClass = rb_define_class_under(module, "CubeState", rb_cObject);
  rb_define_alloc_func(CubeStateClass, CubeState_alloc);
  rb_define_method(CubeStateClass, "initialize", CubeState_initialize, 2);
  rb_define_method(CubeStateClass, "[]", CubeState_entry, 1);
  rb_define_method(CubeStateClass, "[]=", CubeState_store, 2);
  rb_define_method(CubeStateClass, "sticker_array", CubeState_sticker_array, 3);
  rb_define_method(CubeStateClass, "hash", CubeState_hash, 0);
  rb_define_method(CubeStateClass, "eql?", CubeState_eql, 1);
  rb_define_alias(CubeStateClass, "==", "eql?");
  rb_define_method(CubeStateClass, "dup", CubeState_dup, 0);
  rb_define_method(CubeStateClass, "cube_size", CubeState_cube_size, 0);
  rb_define_method(CubeStateClass, "rotate_slice", CubeState_rotate_slice, 3);
  rb_define_method(CubeStateClass, "rotate_face", CubeState_rotate_face, 2);
}
