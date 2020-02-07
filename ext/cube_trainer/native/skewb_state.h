#pragma once

#include <ruby.h>

#define GetSkewbStateData(obj, data) \
  do { \
    TypedData_Get_Struct((obj), SkewbStateData, &SkewbStateData_type, (data)); \
  } while (0)

void init_skewb_state_class_under(VALUE module);
