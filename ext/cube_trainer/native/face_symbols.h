#pragma once

#include <ruby.h>

typedef int FACE_INDEX;

#define cube_faces 6
#define neighbor_faces 4

#define U 0
#define F 1
#define R 2
#define L 3
#define B 4
#define D 5

FACE_INDEX face_index(VALUE face_symbol);

FACE_INDEX neighbor_face_index(FACE_INDEX face_index, int index);

VALUE face_symbol(FACE_INDEX face_index);

FACE_INDEX axis_index(FACE_INDEX face_index);

FACE_INDEX opposite_face_index(FACE_INDEX face_index);

void init_face_symbols();
