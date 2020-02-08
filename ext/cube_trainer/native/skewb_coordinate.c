#include "skewb_coordinate.h"

#include "utils.h"
#include "cube_coordinate.h"

static VALUE SkewbCoordinateClass = Qnil;
static ID center_part_type_id = 0;
static ID corner_part_type_id = 0;

typedef struct {
  face_index_t on_face_index;
  SkewbPartType part_type;
  size_t within_face_index;
} SkewbCoordinateData;

static size_t SkewbCoordinateData_size(const void* const ptr) {
  return sizeof(SkewbCoordinateData);
}

static const rb_data_type_t SkewbCoordinateData_type = {
  "SkewbTrainer::Native::SkewbCoordinateData",
  {NULL, NULL, SkewbCoordinateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

Corner rotated_corner(const Corner corner, const int rotation) {
  Corner result;
  for (size_t i = 0; i < 3; ++i) {
    result.face_indices[i] = corner.face_indices[(i + rotation) % 3];
  }
  return result;
}

static size_t skewb_corner_index_component(const face_index_t face_index) {
  return face_index / 3;
}

static size_t corner_within_face_index(const Corner corner) {
  size_t less_significant_index, more_significant_index;
  if (switch_axes(corner.face_indices[1], corner.face_indices[2])) {
    less_significant_index = corner.face_indices[2];
    more_significant_index = corner.face_indices[1];
  } else {
    less_significant_index = corner.face_indices[1];
    more_significant_index = corner.face_indices[2];
  }
  return 1 + skewb_corner_index_component(more_significant_index) * 2 + skewb_corner_index_component(less_significant_index);
}

size_t corner_sticker_index(const Corner corner) {
  return center_sticker_index(corner.face_indices[0]) + corner_within_face_index(corner);
}

size_t center_sticker_index(const face_index_t on_face_index) {
  return on_face_index * skewb_stickers_per_face;
}

static VALUE part_type_from_symbol(const VALUE part_type_symbol) {
  Check_Type(face_symbol, T_SYMBOL);
  if (SYM2ID(part_type_symbol) == center_part_type_id) {
    return CENTER;
  } else if (SYM2ID(part_type_symbol) == corner_part_type_id) {
    return CORNER;
  } else {
    rb_raise(rb_eArgError, "Invalid part type symbol %+"PRIsVALUE"", part_type_symbol);
  }
}

static VALUE part_type_to_symbol(const SkewbPartType part_type) {
  // Caching these keys isn't easy because the garbage collector will get them.
  switch (part_type) {
  case CENTER:
    return ID2SYM(center_part_type_id);
  case CORNER:
    return ID2SYM(corner_part_type_id);
  default:
    rb_raise(rb_eRuntimeError, "invalid skewb part type");
  }
}

Corner extract_corner(const VALUE face_symbols) {
  if (RARRAY_LEN(face_symbols) != 3) {
    rb_raise(rb_eArgError, "A corner of a skewb must have 3 faces.");
  }
  Corner corner;
  for (size_t i = 0; i < 3; ++i) {
    corner.face_indices[i] = face_index(rb_ary_entry(face_symbols, i));
  }
  for (size_t i = 0; i < 3; ++i) {
    if (axis_index(corner.face_indices[i]) == axis_index(corner.face_indices[(i + 1) % 3])) {
      rb_raise(rb_eArgError, "A corner of a skewb must have 3 faces on different axis.");
    }
  }
  return corner;
}

FaceCorners get_face_corners(const face_index_t face_index) {
  FaceCorners result;
  for (size_t i = 0; i < 4; ++i) {
    result.corners[i].face_indices[0] = face_index;
    result.corners[i].face_indices[1] = neighbor_face_index(face_index, i);
    result.corners[i].face_indices[2] = neighbor_face_index(face_index, i + 1);
  }
  return result;
}

#define GetSkewbCoordinateData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), SkewbCoordinateData, &SkewbCoordinateData_type, (data)); \
  } while (0)

size_t SkewbCoordinate_sticker_index(const VALUE self) {
  SkewbCoordinateData* data;
  GetSkewbCoordinateData(self, data);
  return center_sticker_index(data->on_face_index) + data->within_face_index;
}

static VALUE SkewbCoordinate_alloc(const VALUE klass) {
  SkewbCoordinateData* data;
  const VALUE object = TypedData_Make_Struct(klass, SkewbCoordinateData, &SkewbCoordinateData_type, data);
  data->on_face_index = 0;
  data->part_type = CENTER;
  data->within_face_index = 0;
  return object;
}

static VALUE SkewbCoordinate_for_center(const VALUE klass, const VALUE face_symbol) {
  SkewbCoordinateData* data;
  const VALUE object = TypedData_Make_Struct(klass, SkewbCoordinateData, &SkewbCoordinateData_type, data);
  data->on_face_index = face_index(face_symbol);
  data->part_type = CENTER;
  data->within_face_index = 0;
  return object;
}

static VALUE SkewbCoordinate_for_corner(const VALUE klass, const VALUE face_symbols) {
  Corner corner = extract_corner(face_symbols);
  SkewbCoordinateData* data;
  const VALUE object = TypedData_Make_Struct(klass, SkewbCoordinateData, &SkewbCoordinateData_type, data);
  data->on_face_index = face_index(rb_ary_entry(face_symbols, 0));
  data->part_type = CORNER;
  data->within_face_index = corner_within_face_index(corner);
  return object;
}

static VALUE SkewbCoordinate_hash(const VALUE self) {
  const SkewbCoordinateData* data;
  GetSkewbCoordinateData(self, data);

  st_index_t hash = rb_hash_start((st_index_t)SkewbCoordinate_hash);
  hash = rb_hash_uint(hash, data->on_face_index);
  hash = rb_hash_uint(hash, data->part_type);
  hash = rb_hash_uint(hash, data->within_face_index);
  return ST2FIX(rb_hash_end(hash));
}

static VALUE SkewbCoordinate_eql(const VALUE self, const VALUE other) {
  if (self == other) {
    return Qtrue;
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    return Qfalse;
  }
  const SkewbCoordinateData* self_data;
  GetSkewbCoordinateData(self, self_data);
  const SkewbCoordinateData* other_data;
  GetSkewbCoordinateData(other, other_data);
  if (self_data->on_face_index == other_data->on_face_index &&
      self_data->part_type == other_data->part_type &&
      self_data->within_face_index == other_data->within_face_index) {
    return Qtrue;
  } else {
    return Qfalse;
  }
}


static VALUE SkewbCoordinate_spaceship(const VALUE self, const VALUE other) {
  if (self == other) {
    return INT2NUM(0);
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    rb_raise(rb_eTypeError, "Cannot compare two incompatible types.");
  }
  const SkewbCoordinateData* self_data;
  GetSkewbCoordinateData(self, self_data);
  const SkewbCoordinateData* other_data;
  GetSkewbCoordinateData(other, other_data);
#define cmp(a, b) \
    do { \
      if ((a) != (b)) { \
        if ((a) < (b)) { \
          return INT2NUM(-1); \
        } else { \
          return INT2NUM(1); \
        } \
      } \
    } while (0)
  cmp(self_data->on_face_index, other_data->on_face_index);
  cmp(self_data->part_type, other_data->part_type);
  cmp(self_data->within_face_index, other_data->within_face_index);
#undef cmp
  return 0;
}

VALUE SkewbCoordinate_face(const VALUE self) {
  SkewbCoordinateData* data;
  GetSkewbCoordinateData(self, data);
  return face_symbol(data->on_face_index);    
}

VALUE SkewbCoordinate_part_type(const VALUE self) {
  SkewbCoordinateData* data;
  GetSkewbCoordinateData(self, data);
  return part_type_to_symbol(data->part_type);    
}

void init_skewb_coordinate_class_under(const VALUE module) {
  center_part_type_id = rb_intern("center");
  corner_part_type_id = rb_intern("corner");
  SkewbCoordinateClass = rb_define_class_under(module, "SkewbCoordinate", rb_cObject);
  rb_define_alloc_func(SkewbCoordinateClass, SkewbCoordinate_alloc);
  rb_define_method(SkewbCoordinateClass, "hash", SkewbCoordinate_hash, 0);
  rb_define_method(SkewbCoordinateClass, "eql?", SkewbCoordinate_eql, 1);
  rb_define_alias(SkewbCoordinateClass, "==", "eql?");
  rb_define_method(SkewbCoordinateClass, "<=>", SkewbCoordinate_spaceship, 1);
  rb_define_method(SkewbCoordinateClass, "face", SkewbCoordinate_face, 0);
  rb_define_method(SkewbCoordinateClass, "part_type", SkewbCoordinate_part_type, 0);
  rb_define_singleton_method(SkewbCoordinateClass, "for_center", SkewbCoordinate_for_center, 1);
  rb_define_singleton_method(SkewbCoordinateClass, "for_corner", SkewbCoordinate_for_corner, 1);
}

