#include <GLUT/glut.h>

//#import <Cocoa/Cocoa.h>
#include "matrixlib.h"
//#include "box.h"

#import "box.h"
#include <vector>

struct Wavefront
{

/*float minx, maxx;
float miny, maxy;
float minz, maxz;*/

Box box;

private:

  struct Face
  {
    int v[3];       	   
    int n[3];
    int mat;  // material index
  };
  
  struct Material
  {
    char name[80];
    float r, g, b;       
  };

  vector<Vector> points;
  vector<Vector> normals;
  vector<Face> faces;
  vector<Material> materials;
    
public:
    void loadfile(char *filename, char *mtlfilename, float scale);
    void draw(void);
    Wavefront(char *filename, char *mtlfilename, float scale);


};
