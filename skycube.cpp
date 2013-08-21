#include "skycube.h"

Color procmap(float x, float y, float z)
{
  //  float r1=1, g1=1, b1=1;
   // float r2=0, g2=0, b2=1;
    
    float r1=1, g1=0, b1=0;
    float r2=1, g2=1, b2=0;
    
    
    //    float r1=1, g1=1, b1=0;
    //    float r2=1, g2=0, b2=0;
    
    //    float r1=.3, g1=1, b1=.3;
    //    float r2=0, g2=0, b2=1;
    
    
    float offset = 0.0;
    float blackorwhite = pnoise(x*2 + 0.5, y*2 , z*2 )*0.5+1;
    blackorwhite/=1.5;
    float newr = blackorwhite*r2 + (1.0-blackorwhite)*r1;
    float newg = blackorwhite*g2 + (1.0-blackorwhite)*g1;
    float newb = blackorwhite*b2 + (1.0-blackorwhite)*b1;
    return Color(newr, newg, newb);      
}
