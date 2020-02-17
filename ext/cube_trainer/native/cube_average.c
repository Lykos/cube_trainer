#include "cube_average.h"

#include <stdlib.h>

#include "utils.h"

VALUE CubeAverageClass = Qnil;
const double removed_fraction_per_side = 0.05;

typedef struct {
  size_t capacity;
  size_t size;
  size_t insert_index;
  double* values;
  double average;
} CubeAverageData;

static size_t CubeAverageData_size(const void* const ptr) {
  return sizeof(CubeAverageData);
}

const rb_data_type_t CubeAverageData_type = {
  "CubeTrainer::Native::CubeAverageData",
  {NULL, NULL, CubeAverageData_size, NULL},
  NULL, NULL,
  RUBY_TYPED_FREE_IMMEDIATELY  
};

static double* malloc_values(const size_t n) {
  double* const values = malloc(n * sizeof(double));
  if (values == NULL) {
    rb_raise(rb_eNoMemError, "Allocating values failed.");
  }
  return values;
}

#define GetCubeAverageData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), CubeAverageData, &CubeAverageData_type, (data)); \
  } while (0)
#define GetInitializedCubeAverageData(obj, data) \
  do { \
    GetCubeAverageData((obj), (data)); \
    if (data->values == NULL) { \
      rb_raise(rb_eArgError, "Cube average isn't initialized."); \
    } \
  } while (0)

static VALUE CubeAverage_alloc(const VALUE klass) {
  CubeAverageData* data;
  const VALUE object = TypedData_Make_Struct(klass, CubeAverageData, &CubeAverageData_type, data);
  data->capacity = 0;
  data->size = 0;
  data->insert_index = 0;
  data->values = NULL;
  data->average = NAN;
  return object;
}

static VALUE CubeAverage_initialize(const VALUE self, const VALUE capacity, const VALUE initial_average) {
  Check_Type(capacity, T_FIXNUM);
  const size_t n = FIX2INT(capacity);
  if (n < 3) {
    rb_raise(rb_eArgError, "The number of elements for a cube average has to be at least 3. Got %ld.", n);
  }
  if (n > 1000) {
    rb_raise(rb_eArgError, "The number of elements for a cube average can be at most 1000, otherwise we need a better implementation. Got %ld.", n);
  }
  
  CubeAverageData* data;
  GetCubeAverageData(self, data);

  data->capacity = n;
  data->size = 0;
  data->values = malloc_values(n);
  data->average = NUM2DBL(initial_average);
  
  return self;
}

static VALUE CubeAverage_capacity(const VALUE self) {
  const CubeAverageData* data;
  GetInitializedCubeAverageData(self, data);
  return INT2NUM(data->capacity);
}

static VALUE CubeAverage_length(const VALUE self) {
  const CubeAverageData* data;
  GetInitializedCubeAverageData(self, data);
  return INT2NUM(data->size);
}

static int saturated(const CubeAverageData* const data) {
  return data->size == data->capacity;
}

static int comp(const void* left_ptr, const void* right_ptr) {
  const double left = *((double*)left_ptr);
  const double right = *((double*)right_ptr);
  if (left > right) { return  1; }
  if (left < right) { return -1; }
  return 0;
}

static double compute_average(const double* const values, const size_t size) {
  double sum = 0;
  for (size_t i = 0; i < size; ++i) {
    sum += values[i];
  }
  return sum / size;
}

static double compute_cube_average(const double* const values, const size_t size) {
  if (size <= 2) {
    return compute_average(values, size);
  }
  double* const tmp = malloc_values(size);
  memcpy(tmp, values, size * sizeof(double));
  qsort(tmp, size, sizeof(double), comp);
  const size_t num_removed = ceil(size * removed_fraction_per_side);
  const double result = compute_average(tmp + num_removed, size - 2 * num_removed);
  free(tmp);
  return result;
}

static VALUE CubeAverage_push(const VALUE self, const VALUE new_value) {
  CubeAverageData* data;
  GetInitializedCubeAverageData(self, data);

  data->values[data->insert_index] = NUM2DBL(new_value);
  data->size = MIN(data->size + 1, data->capacity);
  data->insert_index = (data->insert_index + 1) % data->capacity;
  data->average = compute_cube_average(data->values, data->size);
  
  return DBL2NUM(data->average);
}

static VALUE CubeAverage_saturated(const VALUE self) {
  const CubeAverageData* data;
  GetInitializedCubeAverageData(self, data);
  return saturated(data) ? Qtrue : Qfalse;
}

static VALUE CubeAverage_average(const VALUE self) {
  const CubeAverageData* data;
  GetInitializedCubeAverageData(self, data);
  return DBL2NUM(data->average);
}

void init_cube_average_class_under(const VALUE module) {
  CubeAverageClass = rb_define_class_under(module, "CubeAverage", rb_cObject);
  rb_define_alloc_func(CubeAverageClass, CubeAverage_alloc);
  rb_define_method(CubeAverageClass, "initialize", CubeAverage_initialize, 2);
  rb_define_method(CubeAverageClass, "capacity", CubeAverage_capacity, 0);
  rb_define_method(CubeAverageClass, "length", CubeAverage_length, 0);
  rb_define_method(CubeAverageClass, "push", CubeAverage_push, 1);
  rb_define_method(CubeAverageClass, "saturated?", CubeAverage_saturated, 0);
  rb_define_method(CubeAverageClass, "average", CubeAverage_average, 0);
}
