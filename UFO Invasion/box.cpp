//
//  box.cpp
//  UFO Invasion
//
//  Created by administrator a on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "box.h"


float min2(float a, float b)
{
    return (a < b ? a : b);
}

float max2(float a, float b)
{
    return (a > b ? a : b);
}

// translates a box
Box movebox(Box b, float x, float y, float z)
{
    b.minx+=x;
    b.maxx+=x;
    
    b.miny+=y;
    b.maxy+=y;
    
    b.minz+=z;
    b.maxz+=z;
    
    return b;    
}


// translates a box
Box scalebox(Box b, float x, float y, float z)
{
    b.minx*=x;
    b.maxx*=x;
    
    b.miny*=y;
    b.maxy*=y;
    
    b.minz*=z;
    b.maxz*=z;
    
    return b;    
}


// returns whether or not two boxes intersect
bool intersect(const Box &b1, const Box &b2)
{
    if (b1.minx > b2.maxx) return false;
    if (b2.minx > b1.maxx) return false;
    
    if (b1.miny > b2.maxy) return false;
    if (b2.miny > b1.maxy) return false;
    
    if (b1.minz > b2.maxz) return false;
    if (b2.minz > b1.maxz) return false;
    
    return true;
}

// pre-condition: boxes must intersect
// returns the intersection of two boxes
Box isection(const Box &b1, const Box &b2)
{
    Box b3;
    b3.minx = max2(b1.minx, b2.minx);
    b3.maxx = min2(b1.maxx, b2.maxx);
    
    b3.miny = max2(b1.miny, b2.miny);
    b3.maxy = min2(b1.maxy, b2.maxy);
    
    b3.minz = max2(b1.minz, b2.minz);
    b3.maxz = min2(b1.maxz, b2.maxz);
    
    return b3;
}

