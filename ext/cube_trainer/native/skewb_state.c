#include "skewb_state.h"

#include "face_symbols.h"
#include "skewb_coordinate.h"
#include "utils.h"

static VALUE SkewbStateClass = Qnil;

typedef struct {
  VALUE stickers[total_skewb_stickers];
} SkewbStateData;

static void SkewbStateData_mark(void* const ptr) {
  const SkewbStateData* data = ptr;
  for (size_t i = 0; i < total_skewb_stickers; ++i) {
    rb_gc_mark(data->stickers[i]);
  }
}

static size_t SkewbStateData_size(const void* const ptr) {
  return sizeof(SkewbStateData);
}

const rb_data_type_t SkewbStateData_type = {
  "SkewbTrainer::Native::SkewbStateData",
  {SkewbStateData_mark, NULL, SkewbStateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

#define GetSkewbStateData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), SkewbStateData, &SkewbStateData_type, (data)); \
  } while (0)

static VALUE SkewbState_alloc(const VALUE klass) {
  SkewbStateData* data;
  const VALUE object = TypedData_Make_Struct(klass, SkewbStateData, &SkewbStateData_type, data);
  for (size_t i = 0; i < total_skewb_stickers; ++i) {
    data->stickers[i] = Qnil;
  }
  return object;
}

static int SkewbState_replace_face(const VALUE key, const VALUE value, const VALUE self) {
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  const face_index_t on_face_index = face_index(key);
  for (size_t i = 0; i < skewb_stickers_per_face; ++i) {
    data->stickers[on_face_index * skewb_stickers_per_face + i] = value;
  }
  return ST_CONTINUE;
}

static VALUE SkewbState_initialize(const VALUE self, const VALUE stickers) {
  Check_Type(stickers, T_HASH);
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  if (RHASH_SIZE(stickers) != skewb_faces) {
    rb_raise(rb_eTypeError, "Skewbs must have %d faces. Got %ld.", skewb_faces, RHASH_SIZE(stickers));
  }
  rb_hash_foreach(stickers, SkewbState_replace_face, self);
  return self;
}

static VALUE SkewbState_hash(const VALUE self) {
  const SkewbStateData* data;
  GetSkewbStateData(self, data);

  st_index_t hash = rb_hash_start((st_index_t)SkewbState_hash);
  for (size_t i = 0; i < total_skewb_stickers; i++) {
    const VALUE sub_hash = rb_hash(data->stickers[i]);
    hash = rb_hash_uint(hash, NUM2LONG(sub_hash));
  }
  return ST2FIX(rb_hash_end(hash));
}

static VALUE SkewbState_eql(const VALUE self, const VALUE other) {
  if (self == other) {
    return Qtrue;
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    return Qfalse;
  }
  const SkewbStateData* self_data;
  GetSkewbStateData(self, self_data);
  const SkewbStateData* other_data;
  GetSkewbStateData(self, other_data);
  for (size_t i = 0; i < total_skewb_stickers; ++i) {
    if (self_data->stickers[i] != other_data->stickers[i]) {
      return Qfalse;
    }
  }
  return Qtrue;
}

static VALUE SkewbState_dup(const VALUE self) {
  const SkewbStateData* data;
  GetSkewbStateData(self, data);
  SkewbStateData* dupped_data;
  const VALUE dupped = TypedData_Make_Struct(rb_obj_class(self), SkewbStateData, &SkewbStateData_type, dupped_data);
  *dupped_data = *data;
  return dupped;
}

static VALUE SkewbState_entry(const VALUE self, const VALUE coordinate) {
  const SkewbStateData* data;
  GetSkewbStateData(self, data);
  return data->stickers[SkewbCoordinate_sticker_index(coordinate)];
}

static VALUE SkewbState_store(const VALUE self, const VALUE coordinate, const VALUE value) {
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  return data->stickers[SkewbCoordinate_sticker_index(coordinate)] = value;
}

static void apply_twisted_corner_cycle(VALUE* const stickers, const Corner corner, const bool invert) {
  size_t twisted_corner_cycle[3];
  for (size_t i = 0; i < 3; ++i) {
    Corner corner_variant;
    for (size_t j = 0; j < 3; ++j) {
      corner_variant.face_indices[j] = corner.face_indices[(i + j) % 3];
    }
    twisted_corner_cycle[i] = corner_sticker_index(corner_variant);
  }
  apply_sticker_cycle(stickers, twisted_corner_cycle, 3, invert);
}

static void apply_center_cycle(VALUE* const stickers, const Corner corner, const bool invert) {
  size_t center_cycle[3];
  for (size_t i = 0; i < 3; ++i) {
    center_cycle[i] = center_sticker_index(corner.face_indices[i]);
  }
  apply_sticker_cycle(stickers, center_cycle, 3, invert);
}

static void apply_moved_corner_cycles(VALUE* const stickers, const Corner corner, const bool invert) {
  Corner adjacent_corners[3];
  for (size_t corner_index = 0; corner_index < 3; ++corner_index) {
    adjacent_corners[corner_index].face_indices[0] = opposite_face_index(corner.face_indices[corner_index]);
    adjacent_corners[corner_index].face_indices[1] = corner.face_indices[(corner_index + 2) % 3];
    adjacent_corners[corner_index].face_indices[2] = corner.face_indices[(corner_index + 1) % 3];
  }
  // We have 3 different cycles, one for the outside stickers and one two for the remaining stickers of the
  // corners that contain the outside stickers.
  for (size_t cycle_index = 0; cycle_index < 3; ++cycle_index) {
    size_t sticker_cycle[3];
    for (size_t corner_index = 0; corner_index < 3; ++corner_index) {
      const Corner current_corner = adjacent_corners[corner_index];
      // The current corner, but twisted such that the sticker we care about in the current cycle faces up.
      Corner current_corner_for_current_cycle;
      for (size_t i = 0; i < 3; ++i) {
        current_corner_for_current_cycle.face_indices[i] = current_corner.face_indices[(cycle_index + i) % 3];
      }
      sticker_cycle[corner_index] = corner_sticker_index(current_corner_for_current_cycle);
    }
    apply_sticker_cycle(stickers, sticker_cycle, 3, invert);
  }
}

static VALUE SkewbState_twist_corner(const VALUE self, const VALUE face_symbols, const VALUE direction) {
  Check_Type(face_symbols, T_ARRAY);
  Check_Type(direction, T_FIXNUM);
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  const direction_t d = (FIX2INT(direction) % 3 + 3) % 3;
  if (d == 0) {
    return Qnil;
  }

  const Corner corner = extract_corner(face_symbols);
  const bool invert = d == 2;

  apply_twisted_corner_cycle(data->stickers, corner, invert);
  apply_center_cycle(data->stickers, corner, invert);
  apply_moved_corner_cycles(data->stickers, corner, invert);
  
  return Qnil;
}

static void apply_center_rotation(VALUE* const stickers, const face_index_t axis_face_index, const direction_t direction) {
  Sticker4Cycle center_cycle;
  for (size_t i = 0; i < 4; ++i) {
    center_cycle.indices[i] = center_sticker_index(neighbor_face_index(axis_face_index, i));
  }
  apply_sticker_4cycle(stickers, center_cycle, 4 - direction);
}

static void apply_corner_rotation(VALUE* const stickers, const face_index_t axis_face_index, const direction_t direction) {
  Corner corner;
  corner.face_indices[2] = axis_face_index;
  for (size_t cycle_index = 0; cycle_index < 2; ++cycle_index) {
    Sticker4Cycle corner_cycle;
    for (size_t corner_index = 0; corner_index < 4; ++corner_index) {
      for (size_t i = 0; i < 2; ++i) {
        corner.face_indices[(cycle_index + i) % 2] = neighbor_face_index(axis_face_index, corner_index + i);
      }
      corner_cycle.indices[corner_index] = corner_sticker_index(corner);
    }
    apply_sticker_4cycle(stickers, corner_cycle, 4 - direction);
  }
}

static VALUE SkewbState_rotate(const VALUE self, const VALUE axis_face_symbol, const VALUE direction) {
  Check_Type(axis_face_symbol, T_SYMBOL);
  Check_Type(direction, T_FIXNUM);
  SkewbStateData* data;
  GetSkewbStateData(self, data);
  const direction_t d = (FIX2INT(direction) % 4 + 4) % 4;
  if (d == 0) {
    return Qnil;
  }
  const face_index_t axis_face_index = face_index(axis_face_symbol);

  apply_center_rotation(data->stickers, axis_face_index, direction);
  apply_corner_rotation(data->stickers, axis_face_index, direction);
  apply_corner_rotation(data->stickers, opposite_face_index(axis_face_index), 4 - direction);
  
  return Qnil;
}

void init_skewb_state_class_under(const VALUE module) {
  SkewbStateClass = rb_define_class_under(module, "SkewbState", rb_cObject);
  rb_define_alloc_func(SkewbStateClass, SkewbState_alloc);
  rb_define_method(SkewbStateClass, "initialize", SkewbState_initialize, 1);
  rb_define_method(SkewbStateClass, "hash", SkewbState_hash, 0);
  rb_define_method(SkewbStateClass, "eql?", SkewbState_eql, 1);
  rb_define_alias(SkewbStateClass, "==", "eql?");
  rb_define_method(SkewbStateClass, "dup", SkewbState_dup, 0);
  rb_define_method(SkewbStateClass, "[]", SkewbState_entry, 1);
  rb_define_method(SkewbStateClass, "[]=", SkewbState_store, 2);
  rb_define_method(SkewbStateClass, "twist_corner", SkewbState_twist_corner, 2);
  rb_define_method(SkewbStateClass, "rotate", SkewbState_rotate, 2);
}
