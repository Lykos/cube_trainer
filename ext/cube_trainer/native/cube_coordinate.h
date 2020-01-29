#pragma once

#include <ruby.h>

#include "face_symbols.h"

int num_stickers(int cube_size);

typedef struct {
  int x;
  int y;
} Point;

int sticker_index(int cube_size, FACE_INDEX on_face_index, Point point);

int transform_index(FACE_INDEX index_base_face_index, int cube_size, int index);

int switch_axes(FACE_INDEX x_base_face_index, FACE_INDEX y_base_face_index);

void check_base_face_indices(int on_face_index,
                             int x_base_face_index,
                             int y_base_face_index);

Point point_on_face(int on_face_index,
                    int x_base_face_index,
                    int y_base_face_index,
                    int cube_size,
                    int untransfomred_x,
                    int untransformed_y);

int CubeCoordinate_sticker_index(VALUE obj, int cube_size);

void init_cube_coordinate_class_under(VALUE module);
