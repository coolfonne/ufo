struct Box
{
  float minx, maxx;       
  float miny, maxy;       
  float minz, maxz;       
};

float min2(float a, float b);

float max2(float a, float b);

// translates a box
Box movebox(Box b, float x, float y, float z);
// translates a box
Box scalebox(Box b, float x, float y, float z);

// returns whether or not two boxes intersect
bool intersect(const Box &b1, const Box &b2);

// pre-condition: boxes must intersect
// returns the intersection of two boxes
Box isection(const Box &b1, const Box &b2);