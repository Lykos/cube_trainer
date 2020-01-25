#pragma once

#include <ruby.h>

#include "face_symbols.h"

int num_stickers_for_cube_size(int cube_size);

int sticker_index(int cube_size, FACE_INDEX face_index, int x, int y);

int transform_index(FACE_INDEX index_base_face_index, int cube_size, int index);

int switch_axes(FACE_INDEX x_base_face_index, FACE_INDEX y_base_face_index);

int CubeCoordinate_sticker_index(VALUE obj, int cube_size);

void init_cube_coordinate_class_under(VALUE NativeModule);
