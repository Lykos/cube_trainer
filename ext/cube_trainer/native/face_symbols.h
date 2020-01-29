#pragma once

#include <ruby.h>

typedef int face_index_t;

#define cube_faces 6
#define neighbor_faces 4

#define U 0
#define F 1
#define R 2
#define L 3
#define B 4
#define D 5

face_index_t face_index(VALUE face_symbol);

face_index_t neighbor_face_index(face_index_t face_index, size_t index);

VALUE face_symbol(face_index_t face_index);

face_index_t axis_index(face_index_t face_index);

face_index_t opposite_face_index(face_index_t face_index);

void init_face_symbols();
