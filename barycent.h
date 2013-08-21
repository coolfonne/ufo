// compute the area of a triangle using Heron's formula
float triarea(float a, float b, float c);
// compute the distance between two 2d points
float dist(float x0, float y0, float x1, float y1);

// compute the barycentric coordinates of a 2d point inside a 2d triangle
// (x0, y0) (x1, y1) (x2, y2) are the vertices of a 2d triangle
// (vx, vy) is a point inside the 2d triangle 
// u, v, w are the barycentric coordinates of (vx, vy) in the triangle
void barycent(float x0, float y0, float x1, float y1, float x2, float y2, 
              float vx, float vy,
              float *u, float *v, float *w);