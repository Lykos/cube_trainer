#include "cube_coordinate.h"

#include <stdio.h>

VALUE CubeCoordinateClass = Qnil;

typedef struct {
  int cube_size;
  int on_face_index;
  int x;
  int y;
} CubeCoordinateData;

const rb_data_type_t CubeCoordinateData_type = {
  "CubeTrainer::Native::CubeCoordinateData",
  {NULL, NULL, NULL, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

#define GetCubeCoordinateData(obj, data) TypedData_Get_Struct((obj), CubeCoordinateData, &CubeCoordinateData_type, (data));

int num_stickers_for_cube_size(const int cube_size) {
  return cube_faces * cube_size * cube_size;
}

int sticker_index(const int cube_size, const FACE_INDEX on_face_index, const int x, const int y) {
  return on_face_index * cube_size * cube_size + y * cube_size + x;
}

int CubeCoordinate_sticker_index(const VALUE obj, const int cube_size) {
  CubeCoordinateData* data;
  GetCubeCoordinateData(obj, data);
  if (data->cube_size != cube_size) {
    rb_raise(rb_eArgError, "Cannot use coordinate for cube size %d on a %dx%d cube.", data->cube_size, cube_size, cube_size);
  }
  return sticker_index(cube_size, data->on_face_index, data->x, data->y);
}

size_t CubeCoordinateData_size(const void* const ptr) {
  return sizeof(CubeCoordinateData);
}

VALUE CubeCoordinate_alloc(const VALUE klass) {
  CubeCoordinateData* data;
  VALUE object = TypedData_Make_Struct(klass, CubeCoordinateData, &CubeCoordinateData_type, data);
  data->cube_size = 0;
  data->on_face_index = 0;
  data->x = 0;
  data->y = 0;
  return object;
}

int inverted_index(const int cube_size, const int index) {
  return cube_size - 1 - index;
}

int transform_index(const FACE_INDEX index_base_face_index, const int cube_size, const int index) {
  if (index_base_face_index == axis_index(index_base_face_index)) {
    return index;
  } else {
    return inverted_index(cube_size, index);
  }
}

int switch_axes(const FACE_INDEX x_base_face_index, const FACE_INDEX y_base_face_index) {
  return axis_index(x_base_face_index) < axis_index(y_base_face_index);
}

void check_base_face_indices(const int on_face_index,
                             const int x_base_face_index,
                             const int y_base_face_index) {
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

Point point_on_face(const int face_index,
                    const int x_base_face_index,
                    const int y_base_face_index,
                    const int cube_size,
                    const int untransformed_x,
                    const int untransformed_y) {
  const int transformed_x = transform_index(x_base_face_index, cube_size, untransformed_x);
  const int transformed_y = transform_index(y_base_face_index, cube_size, untransformed_y);
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

void check_cube_index(const int cube_size, const int index) {
  if (index < 0 || index >= cube_size) {
    rb_raise(rb_eArgError, "Invalid value %d for x with cube size %d.", index, cube_size);
  }
}

VALUE CubeCoordinate_initialize(const VALUE self,
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
  const int n = NUM2INT(cube_size);
  const FACE_INDEX on_face_index = face_index(face_symbol);
  const FACE_INDEX x_base_face_index = face_index(x_base_face_symbol);
  const FACE_INDEX y_base_face_index = face_index(y_base_face_symbol);
  check_base_face_indices(on_face_index, x_base_face_index, y_base_face_index);
  const int untransformed_x = NUM2INT(x_num);
  check_cube_index(n, untransformed_x);
  const int untransformed_y = NUM2INT(y_num);
  check_cube_index(n, untransformed_y);
  const Point point = point_on_face(on_face_index, x_base_face_index, y_base_face_index, n, untransformed_x, untransformed_y);
  CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);
  data->cube_size = n;
  data->on_face_index = on_face_index;
  data->x = point.x;
  data->y = point.y;
  return self;
}

VALUE CubeCoordinate_hash(const VALUE self) {
  const CubeCoordinateData* data;
  GetCubeCoordinateData(self, data);

  st_index_t hash = rb_hash_start((st_index_t)CubeCoordinate_hash);
  hash = rb_hash_uint(hash, data->cube_size);
  hash = rb_hash_uint(hash, data->on_face_index);
  hash = rb_hash_uint(hash, data->x);
  hash = rb_hash_uint(hash, data->y);
  return ST2FIX(rb_hash_end(hash));
}

VALUE CubeCoordinate_eql(const VALUE self, const VALUE other) {
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
      self_data->x == other_data->x &&
      self_data->y == other_data->y) {
    return Qtrue;
  } else {
    return Qfalse;
  }
}

void init_cube_coordinate_class_under(const VALUE NativeModule) {
  CubeCoordinateClass = rb_define_class_under(NativeModule, "CubeCoordinate", rb_cObject);
  rb_define_alloc_func(CubeCoordinateClass, CubeCoordinate_alloc);
  rb_define_method(CubeCoordinateClass, "initialize", CubeCoordinate_initialize, 6);
  rb_define_method(CubeCoordinateClass, "hash", CubeCoordinate_hash, 0);
  rb_define_method(CubeCoordinateClass, "eql?", CubeCoordinate_eql, 1);
  rb_define_alias(CubeCoordinateClass, "==", "eql?");
}
