#include <ruby.h>

#include "cube_average.h"
#include "cube_coordinate.h"
#include "cube_state.h"
#include "face_symbols.h"
#include "skewb_coordinate.h"
#include "skewb_state.h"

VALUE CubeTrainerModule = Qnil;
VALUE NativeModule = Qnil;

void Init_native() {
  CubeTrainerModule = rb_define_module("CubeTrainer");
  NativeModule = rb_define_module_under(CubeTrainerModule, "Native");
  init_cube_average_class_under(NativeModule);
  init_cube_coordinate_class_under(NativeModule);
  init_cube_state_class_under(NativeModule);
  init_face_symbols();
  init_skewb_coordinate_class_under(NativeModule);
  init_skewb_state_class_under(NativeModule);
}
