#include <ruby.h>

#include "cube_state.h"

VALUE CubeTrainerModule = Qnil;
VALUE NativeModule = Qnil;

void Init_native() {
  CubeTrainerModule = rb_define_module("CubeTrainer");
  NativeModule = rb_define_module_under(CubeTrainerModule, "Native");
  rb_init_cube_state_class_under(NativeModule);
}
