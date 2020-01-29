#include "cube_coordinate.h"

#include <stdio.h>

static VALUE CubeCoordinateClass = Qnil;

typedef struct {
  size_t cube_size;
  face_index_t on_face_index;
  Point point;
} CubeCoordinateData;

static size_t CubeCoordinateData_size(const void* const ptr) {
  return sizeof(CubeCoordinateData);
}

const rb_data_type_t CubeCoordinateData_type = {
  "CubeTrainer::Native::CubeCoordinateData",
  {NULL, NULL, CubeCoordinateData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

#define GetCubeCoordinateData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), CubeCoordinateData, &CubeCoordinateData_type, (data)); \
  } while (0)

size_t num_stickers(const size_t cube_size) {
  return cube_faces * cube_size * cube_size;
}

size_t sticker_index(const size_t cube_size, const face_index_t on_face_index, const Point point) {
  return on_face_index * cube_size * cube_size + point.y * cube_size + point.x;
}

size_t CubeCoordinate_sticker_index(const VALUE self, const size_t cube_size) {
  CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);
  if (data->cube_size != cube_size) {
    rb_raise(rb_eArgError, "Cannot use coordinate for cube size %ld on a %ldx%ld cube.", data->cube_size, cube_size, cube_size);
  }
  return sticker_index(cube_size, data->on_face_index, data->point);
}

static VALUE CubeCoordinate_alloc(const VALUE klass) {
  CubeCoordinateData* data;
  const VALUE object = TypedData_Make_Struct(klass, CubeCoordinateData, &CubeCoordinateData_type, data);
  data->cube_size = 0;
  data->on_face_index = 0;
  data->point.x = 0;
  data->point.y = 0;
  return object;
}

static size_t inverted_index(const size_t cube_size, const size_t index) {
  return cube_size - 1 - index;
}

size_t transform_index(const face_index_t index_base_face_index, const size_t cube_size, const size_t index) {
  if (index_base_face_index == axis_index(index_base_face_index)) {
    return index;
  } else {
    return inverted_index(cube_size, index);
  }
}

bool switch_axes(const face_index_t x_base_face_index, const face_index_t y_base_face_index) {
  return axis_index(x_base_face_index) > axis_index(y_base_face_index);
}

void check_base_face_indices(const face_index_t on_face_index,
                             const face_index_t x_base_face_index,
                             const face_index_t y_base_face_index) {
  if (axis_index(x_base_face_index) == axis_index(on_face_index)) {
    rb_raise(rb_eArgError, "Invalid value for x_base_face_symbol.");
  }
  if (axis_index(y_base_face_index) == axis_index(on_face_index)) {
    rb_raise(rb_eArgError, "Invalid value for y_base_face_symbol.");
  }
  if (axis_index(x_base_face_index) == axis_index(y_base_face_index)) {
    rb_raise(rb_eArgError, "Incompatible values for x_base_face_symbol and y_base_face_symbol.");
  }
}

Point point_on_face(const face_index_t face_index,
                    const face_index_t x_base_face_index,
                    const face_index_t y_base_face_index,
                    const size_t cube_size,
                    const size_t untransformed_x,
                    const size_t untransformed_y) {
  const size_t transformed_x = transform_index(x_base_face_index, cube_size, untransformed_x);
  const size_t transformed_y = transform_index(y_base_face_index, cube_size, untransformed_y);
  Point point;
  if (switch_axes(x_base_face_index, y_base_face_index)) {
    point.x = transformed_y;
    point.y = transformed_x;
  } else {
    point.x = transformed_x;
    point.y = transformed_y;
  }
  return point;
}

static void check_cube_index(const size_t cube_size, const size_t index) {
  if (index < 0 || index >= cube_size) {
    rb_raise(rb_eArgError, "Invalid value %ld for x with cube size %ld.", index, cube_size);
  }
}

static VALUE CubeCoordinate_initialize(const VALUE self,
                                       const VALUE cube_size,
                                       const VALUE face_symbol,
                                       const VALUE x_base_face_symbol,
                                       const VALUE y_base_face_symbol,
                                       const VALUE x_num,
                                       const VALUE y_num) {
  Check_Type(cube_size, T_FIXNUM);
  Check_Type(face_symbol, T_SYMBOL);
  Check_Type(x_base_face_symbol, T_SYMBOL);
  Check_Type(y_base_face_symbol, T_SYMBOL);
  Check_Type(x_num, T_FIXNUM);
  Check_Type(y_num, T_FIXNUM);
  const size_t n = FIX2INT(cube_size);
  const face_index_t on_face_index = face_index(face_symbol);
  const face_index_t x_base_face_index = face_index(x_base_face_symbol);
  const face_index_t y_base_face_index = face_index(y_base_face_symbol);
  check_base_face_indices(on_face_index, x_base_face_index, y_base_face_index);
  const size_t untransformed_x = FIX2INT(x_num);
  check_cube_index(n, untransformed_x);
  const size_t untransformed_y = FIX2INT(y_num);
  check_cube_index(n, untransformed_y);
  const Point point = point_on_face(on_face_index, x_base_face_index, y_base_face_index, n, untransformed_x, untransformed_y);
  CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);
  data->cube_size = n;
  data->on_face_index = on_face_index;
  data->point = point;
  return self;
}

static VALUE CubeCoordinate_hash(const VALUE self) {
  const CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);

  st_index_t hash = rb_hash_start((st_index_t)CubeCoordinate_hash);
  hash = rb_hash_uint(hash, data->cube_size);
  hash = rb_hash_uint(hash, data->on_face_index);
  hash = rb_hash_uint(hash, data->point.x);
  hash = rb_hash_uint(hash, data->point.y);
  return ST2FIX(rb_hash_end(hash));
}

static VALUE CubeCoordinate_eql(const VALUE self, const VALUE other) {
  if (self == other) {
    return Qtrue;
  }
  if (rb_obj_class(self) != rb_obj_class(other)) {
    return Qfalse;
  }
  const CubeCoordinateData* self_data;
  GetCubeCoordinateData(self, self_data);
  const CubeCoordinateData* other_data;
  GetCubeCoordinateData(other, other_data);
  if (self_data->cube_size == other_data->cube_size &&
      self_data->on_face_index == other_data->on_face_index &&
      self_data->point.x == other_data->point.x &&
      self_data->point.y == other_data->point.y) {
    return Qtrue;
  } else {
    return Qfalse;
  }
}

static VALUE CubeCoordinate_cube_size(const VALUE self) {
  const CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);
  return INT2NUM(data->cube_size);
}

static VALUE CubeCoordinate_face(const VALUE self) {
  const CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);
  return face_symbol(data->on_face_index);    
}

static VALUE CubeCoordinate_coordinate(const VALUE self, const VALUE index_base_face_symbol) {
  const CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);
  const face_index_t index_base_face_index = face_index(index_base_face_symbol);
  // Make use of the fact that 0 + 1 + 2 = 3
  const face_index_t third_face_index = 3 - axis_index(data->on_face_index) - axis_index(index_base_face_index);
  const size_t index = switch_axes(index_base_face_index, third_face_index) ? data->point.y : data->point.x;
  return INT2NUM(transform_index(index_base_face_index, data->cube_size, index));
}

void init_cube_coordinate_class_under(const VALUE module) {
  CubeCoordinateClass = rb_define_class_under(module, "CubeCoordinate", rb_cObject);
  rb_define_alloc_func(CubeCoordinateClass, CubeCoordinate_alloc);
  rb_define_method(CubeCoordinateClass, "initialize", CubeCoordinate_initialize, 6);
  rb_define_method(CubeCoordinateClass, "hash", CubeCoordinate_hash, 0);
  rb_define_method(CubeCoordinateClass, "eql?", CubeCoordinate_eql, 1);
  rb_define_alias(CubeCoordinateClass, "==", "eql?");
  rb_define_method(CubeCoordinateClass, "cube_size", CubeCoordinate_cube_size, 0);
  rb_define_method(CubeCoordinateClass, "face", CubeCoordinate_face, 0);
  rb_define_method(CubeCoordinateClass, "coordinate", CubeCoordinate_coordinate, 1);
}
