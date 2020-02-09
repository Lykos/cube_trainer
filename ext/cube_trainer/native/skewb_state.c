#include "skewb_state.h"

#include "face_symbols.h"

static VALUE SkewbStateClass = Qnil;

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
    if (!color_eq(self_data->stickers[i], other_data->stickers[i])) {
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
    const Corner corner_variant = rotated_corner(corner, i);
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
      // The current corner, but twisted such that the sticker we care about in the current cycle faces up.
      const Corner current_corner_for_current_cycle = rotated_corner(adjacent_corners[corner_index], cycle_index);
      sticker_cycle[corner_index] = corner_sticker_index(current_corner_for_current_cycle);
    }
    apply_sticker_cycle(stickers, sticker_cycle, 3, invert);
  }
}

void rotate_corner_for_skewb_state(const Corner corner, direction_t direction, SkewbStateData* const skewb_state) {
  direction = CROP_MOD(direction, 3);
  if (direction == 0) {
    return;
  }
  const bool invert = direction == 2;

  apply_twisted_corner_cycle(skewb_state->stickers, corner, invert);
  apply_center_cycle(skewb_state->stickers, corner, invert);
  apply_moved_corner_cycles(skewb_state->stickers, corner, invert);
}

static VALUE SkewbState_rotate_corner(const VALUE self, const VALUE face_symbols, const VALUE direction) {
  Check_Type(face_symbols, T_ARRAY);
  Check_Type(direction, T_FIXNUM);
  SkewbStateData* data;
  GetSkewbStateData(self, data);

  rotate_corner_for_skewb_state(extract_corner(face_symbols), FIX2INT(direction), data);
  
  return Qnil;
}

static void apply_center_rotation(VALUE* const stickers, const face_index_t axis_face_index, const direction_t direction) {
  Sticker4Cycle center_cycle;
  for (size_t i = 0; i < 4; ++i) {
    center_cycle.indices[i] = center_sticker_index(neighbor_face_index(axis_face_index, i));
  }
  apply_sticker_4cycle(stickers, center_cycle, direction);
}

static void apply_corner_rotations(VALUE* const stickers, const face_index_t axis_face_index, const direction_t direction) {
  Corner corner;
  corner.face_indices[2] = axis_face_index;
  for (size_t cycle_index = 0; cycle_index < 3; ++cycle_index) {
    Sticker4Cycle corner_cycle;
    for (size_t corner_index = 0; corner_index < 4; ++corner_index) {
      for (size_t i = 0; i < 2; ++i) {
        corner.face_indices[i] = neighbor_face_index(axis_face_index, corner_index + i);
      }
      corner_cycle.indices[corner_index] = corner_sticker_index(rotated_corner(corner, cycle_index));
    }
    apply_sticker_4cycle(stickers, corner_cycle, direction);
  }
}

void rotate_skewb_state(const face_index_t axis_face_index, direction_t direction, SkewbStateData* const skewb_state) {
  direction = CROP_MOD(direction, 4);
  if (direction == 0) {
    return;
  }
  apply_center_rotation(skewb_state->stickers, axis_face_index, direction);
  apply_corner_rotations(skewb_state->stickers, axis_face_index, direction);
  apply_corner_rotations(skewb_state->stickers, opposite_face_index(axis_face_index), invert_cube_direction(direction));
}

static VALUE SkewbState_rotate(const VALUE self, const VALUE axis_face_symbol, const VALUE direction) {
  Check_Type(axis_face_symbol, T_SYMBOL);
  Check_Type(direction, T_FIXNUM);
  SkewbStateData* data;
  GetSkewbStateData(self, data);

  rotate_skewb_state(face_index(axis_face_symbol), FIX2INT(direction), data);
  
  return Qnil;
}

static VALUE SkewbState_face_solved(const VALUE self, const VALUE face_symbol) {
  const SkewbStateData* data;
  GetSkewbStateData(self, data);
  const face_index_t solved_face_index = face_index(face_symbol);
  const size_t center_index = center_sticker_index(solved_face_index);
  const VALUE color = data->stickers[center_index];
  for (int i = 1; i < 5; ++i) {
    if (!color_eq(data->stickers[center_index + i], color)) {
      return Qfalse;
    }
  }
  return Qtrue;
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
  rb_define_method(SkewbStateClass, "rotate_corner", SkewbState_rotate_corner, 2);
  rb_define_method(SkewbStateClass, "rotate", SkewbState_rotate, 2);
  rb_define_method(SkewbStateClass, "face_solved?", SkewbState_face_solved, 1);
}
