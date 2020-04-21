#include <ruby.h>

#include "cube_algorithm.h"
#include "cube_average.h"
#include "cube_coordinate.h"
#include "cube_state.h"
#include "face_symbols.h"
#include "skewb_algorithm.h"
#include "skewb_coordinate.h"
#include "skewb_layer_fingerprint.h"
#include "skewb_state.h"

VALUE TwistyPuzzlesModule = Qnil;
VALUE NativeModule = Qnil;

void Init_native() {
  TwistyPuzzlesModule = rb_define_module("TwistyPuzzles");
  NativeModule = rb_define_module_under(TwistyPuzzlesModule, "Native");
  init_cube_algorithm_class_under(NativeModule);
  init_cube_average_class_under(NativeModule);
  init_cube_coordinate_class_under(NativeModule);
  init_cube_state_class_under(NativeModule);
  init_face_symbols();
  init_skewb_algorithm_class_under(NativeModule);
  init_skewb_coordinate_class_under(NativeModule);
  init_skewb_layer_fingerprint_method_under(NativeModule);
  init_skewb_state_class_under(NativeModule);
}
