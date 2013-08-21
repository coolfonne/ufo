/**************************
 * Includes
 *
 **************************/

//#include <windows.h>
//#include <gl/gl.h>
//#include <gl/glu.h>
#include <vector>

#include "matrixlib.h"
#include "perlin.h"
#include "barycent.h"

/**************************
 * Function Declarations
 *
 **************************/

float thetime = 0.0f;

//LRESULT CALLBACK WndProc (HWND hWnd, UINT message,
//                          WPARAM wParam, LPARAM lParam);
//void EnableOpenGL (HWND hWnd, HDC *hDC, HGLRC *hRC);
//void DisableOpenGL (HWND hWnd, HDC hDC, HGLRC hRC);

struct Triangle
{
    Vector v0, v1, v2;
    Vector normal;
    
    Triangle(Vector v0, Vector v1, Vector v2)
    {
        this->v0 = v0;
        this->v1 = v1;
        this->v2 = v2;
    }
    
    void setnormal(Vector normal)
    {
        this->normal = normal;
    }
    
    void setnormal(float x, float y, float z)
    {
        setnormal(buildvector(x, y, z));
    }
    
};


struct Color
{
    unsigned char r, g, b;     
    
    Color(float red, float green, float blue)
    {
        r = int(red*255.0);
        g = int(green*255.0);
        b = int(blue*255.0);                
    }
    
};

class TextureManager
{
public:
    int width, height, numtriangles;
    unsigned char *textmem;
    
    int triwidth, triheight;
    int numxsquares, numysquares;
    
    TextureManager(int width, int height, int numtriangles)
    {
        this->width = width;
        this->height = height;
        this->numtriangles = numtriangles;
        textmem = new unsigned char[width*height*3];
        numxsquares = int(ceil(sqrt(float(numtriangles)/2.0)));
        numysquares = numxsquares;
        triwidth = width/numxsquares;
        triheight = height/numysquares;
    }
    
    ~TextureManager()
    {
        if (textmem) delete[] textmem;
    }
    
    
    int getx0(int trinum)
    {
        int squarenum = trinum / 2;
        int squarex = squarenum % numxsquares;
        
        if (trinum%2 == 0) return squarex*triwidth+1;
        else return squarex*triwidth+3;   
    }
    
    int gety0(int trinum)
    {
        int squarenum = trinum / 2;
        int squarey = squarenum / numxsquares;           
        return squarey*triheight+1;
    }
    
    
    
    int getx1(int trinum)
    {
        int squarenum = trinum / 2;
        int squarex = squarenum % numxsquares;
        
        if (trinum%2 == 0) return squarex*triwidth+triwidth-2;
        else return squarex*triwidth+triwidth-2+1;   
    }
    
    int gety1(int trinum)
    {
        int squarenum = trinum / 2;
        int squarey = squarenum / numxsquares;           
        return squarey*triheight+triheight-2;
    }
    
    
    int getx2(int trinum)
    {
        int squarenum = trinum / 2;
        int squarex = squarenum % numxsquares;
        if (trinum%2 == 0) return squarex*triwidth+1;
        else return squarex*triwidth+triwidth-2;   
    }
    
    int gety2(int trinum)
    {
        int squarenum = trinum / 2;
        int squarey = squarenum / numxsquares;           
        if (trinum%2 == 0) return squarey*triheight+triheight-2;
        else return squarey*triheight+1;   
    }
    
    void setcolor(int x, int y, Color color)
    {
        if (x < 0 || y < 0 || x >= width || y >= height) return;
        textmem[y*width*3 + x*3] = color.r;
        textmem[y*width*3 + x*3 + 1] = color.g;
        textmem[y*width*3 + x*3 + 2] = color.b;     
    }
    
    
    // takes a triangle number, barycentric coords, and a color
    void setcolor(int trinum, float a, float b, float c, struct Color color)
    {
        // make sure triangle is within range
        if (trinum >= numtriangles) return;
        
        int xtext = int(float(getx0(trinum)+0.5)*a
                        + float(getx1(trinum)+0.5)*b
                        + float(getx2(trinum)+0.5)*c);
        
        int ytext = int(float(gety0(trinum)+0.5)*a
                        + float(gety1(trinum)+0.5)*b
                        + float(gety2(trinum)+0.5)*c);
        
        setcolor(xtext, ytext, color);     
    }
    
    float getu0(int trinum)
    {
        return float(getx0(trinum)+0.5)/float(width);
    }
    
    float getv0(int trinum)
    {
        return float(gety0(trinum)+0.5)/float(height);
    }
    
    float getu1(int trinum)
    {
        return float(getx1(trinum)+0.5)/float(width);
    }
    
    float getv1(int trinum)
    {
        return float(gety1(trinum)+0.5)/float(height);
    }
    
    float getu2(int trinum)
    {
        return float(getx2(trinum)+0.5)/float(width);
    }
    
    float getv2(int trinum)
    {
        return float(gety2(trinum)+0.5)/float(height);
    }
    
//    COLORREF getpixel(int x, int y)
//    {
//        return RGB(
//                   textmem[y*width*3 + x*3],
//                   textmem[y*width*3 + x*3 + 1],
//                   textmem[y*width*3 + x*3 + 2]
//                   );         
//    }
    
};

Color procmap(float x, float y, float z)
{
    float r1=1, g1=1, b1=1;
    float r2=0, g2=0, b2=1;
    float offset = 0.0;
    float blackorwhite = pnoise(x*2 + 0.5, y*2 , z*2 )*0.5+1;
    blackorwhite/=1.5;
    float newr = blackorwhite*r2 + (1.0-blackorwhite)*r1;
    float newg = blackorwhite*g2 + (1.0-blackorwhite)*g1;
    float newb = blackorwhite*b2 + (1.0-blackorwhite)*b1;
    return Color(newr, newg, newb);      
}


//void CALLBACK cbFunct(UINT , UINT , DWORD_PTR , DWORD_PTR , DWORD_PTR ) 
//{ 
//    thetime += .00625;
//} 
//



/**************************
 * WinMain
 *
 **************************/

//int WINAPI WinMain (HINSTANCE hInstance,
//                    HINSTANCE hPrevInstance,
//                    LPSTR lpCmdLine,
//                    int iCmdShow)
//{
//    init();
//    WNDCLASS wc;
//    HWND hWnd;
//    HDC hDC;
//    HGLRC hRC;        
//    MSG msg;
//    BOOL bQuit = FALSE;
//    
//    
//    /* register window class */
//    wc.style = CS_OWNDC;
//    wc.lpfnWndProc = WndProc;
//    wc.cbClsExtra = 0;
//    wc.cbWndExtra = 0;
//    wc.hInstance = hInstance;
//    wc.hIcon = LoadIcon (NULL, IDI_APPLICATION);
//    wc.hCursor = LoadCursor (NULL, IDC_ARROW);
//    wc.hbrBackground = (HBRUSH) GetStockObject (BLACK_BRUSH);
//    wc.lpszMenuName = NULL;
//    wc.lpszClassName = "GLSample";
//    RegisterClass (&wc);
//    
//    /* create main window */
//    hWnd = CreateWindow (
//                         "GLSample", "Sky cube", 
//                         WS_CAPTION | WS_POPUPWINDOW | WS_VISIBLE,
//                         0, 0, 556, 556,
//                         NULL, NULL, hInstance, NULL);
//    
//    /* enable OpenGL for the window */
//    EnableOpenGL (hWnd, &hDC, &hRC);
//    
//    timeSetEvent(15, 0, cbFunct, NULL, TIME_PERIODIC);
//    
//    vector<Triangle> triangles;
//    
//    // front
//    Triangle t = Triangle(buildvector(0, 1, 0), buildvector(1, 0, 0), buildvector(0, 0, 0));
//    
//    t.setnormal(0, 0, -1);
//    triangles.insert(triangles.end(), t);
//    t = Triangle(buildvector(0, 1, 0), buildvector(1, 0, 0), buildvector(1, 1, 0));
//    t.setnormal(0, 0, -1);
//    triangles.insert(triangles.end(), t);
//    
//    // back
//    t = Triangle(buildvector(0, 1, 1), buildvector(1, 0, 1), buildvector(0, 0, 1));
//    t.setnormal(0, 0, 1);
//    triangles.insert(triangles.end(), t);
//    t = Triangle(buildvector(0, 1, 1), buildvector(1, 0, 1), buildvector(1, 1, 1));
//    t.setnormal(0, 0, 1);
//    triangles.insert(triangles.end(), t);
//    
//    // top
//    t = Triangle(buildvector(0, 1, 1), buildvector(1, 1, 0), buildvector(0, 1, 0));
//    t.setnormal(0, 1, 0);
//    triangles.insert(triangles.end(), t);
//    t = Triangle(buildvector(0, 1, 1), buildvector(1, 1, 0), buildvector(1, 1, 1));
//    t.setnormal(0, 1, 0);
//    triangles.insert(triangles.end(), t);
//    
//    // bottom
//    t = Triangle(buildvector(0, 0, 1), buildvector(1, 0, 0), buildvector(0, 0, 0));
//    t.setnormal(0, -1, 0);
//    triangles.insert(triangles.end(), t);
//    t = Triangle(buildvector(0, 0, 1), buildvector(1, 0, 0), buildvector(1, 0, 1));
//    t.setnormal(0, -1, 0);
//    triangles.insert(triangles.end(), t);
//    
//    // right
//    t = Triangle(buildvector(1, 1, 0), buildvector(1, 0, 1), buildvector(1, 0, 0));
//    t.setnormal(1, 0, 0);
//    triangles.insert(triangles.end(), t);
//    t = Triangle(buildvector(1, 1, 0), buildvector(1, 0, 1), buildvector(1, 1, 1));
//    t.setnormal(1, 0, 0);
//    triangles.insert(triangles.end(), t);
//    
//    // left
//    t = Triangle(buildvector(0, 1, 0), buildvector(0, 0, 1), buildvector(0, 0, 0));
//    t.setnormal(-1, 0, 0);
//    triangles.insert(triangles.end(), t);
//    t = Triangle(buildvector(0, 1, 0), buildvector(0, 0, 1), buildvector(0, 1, 1));
//    t.setnormal(-1, 0, 0);
//    triangles.insert(triangles.end(), t);
//    
//    
//    TextureManager tm = TextureManager(1024, 1024, triangles.size());
//    
//    vector<Triangle>::iterator i = triangles.begin();
//    
//    
//    vector<Vector> barycentuniform;
//    
//    // generate the barycentric coordinates, which are uniformly distributed over the triangle
//    for (float vy = 0; vy <= 1; vy+=0.0029)
//    {
//        for (float vx = 0; vx <= vy; vx+=0.0029)
//        {
//            float a, b, c;
//            barycent(0,0, 0,1, 1,1, vx,vy, &a, &b, &c);
//            //if (fabs(a+b+c - 1.0) > 0.00001) continue;
//            barycentuniform.insert(barycentuniform.end(), buildvector(a, b, c));
//        }
//    }
//    
//    
//    
//    int trictr = 0;
//    while (i != triangles.end()) {
//        Triangle t = *i++;
//        vector<Vector>::iterator baryit = barycentuniform.begin();
//        while (baryit != barycentuniform.end())
//        {
//            Vector bcentcoord = *baryit++;
//            float a = bcentcoord[0];
//            float b = bcentcoord[1];
//            float c = bcentcoord[2];
//            
//            float x = t.v0[0]*a + t.v1[0]*b + t.v2[0]*c;
//            float y = t.v0[1]*a + t.v1[1]*b + t.v2[1]*c;
//            float z = t.v0[2]*a + t.v1[2]*b + t.v2[2]*c;
//            
//            x-=0.5;
//            y-=0.5;
//            z-=0.5;
//            
//            // normalize the points so that they are on a sphere and not a cube.
//            // this is basically the secret to making a skycube look good            
//            
//            float length = sqrt(x*x + y*y + z*z);
//            float perlx = x/length;
//            float perly = y/length;
//            float perlz = z/length;                       
//            
//            tm.setcolor(trictr, a, b, c, procmap(perlx, perly, perlz));    
//            
//        }
//        
//        trictr++;
//    }
//    
//    // Really Nice Perspective Calculations
//    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
//    
//    // Create The Texture
//    GLuint mytexture;
//    glGenTextures(1, &mytexture);					
//    glBindTexture(GL_TEXTURE_2D, mytexture);
//    glTexImage2D(GL_TEXTURE_2D, 0, 3, 1024, 1024, 0, GL_RGB, GL_UNSIGNED_BYTE, tm.textmem);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//    
//    /* program main loop */
//    while (!bQuit)
//    {
//        /* check for messages */
//        if (PeekMessage (&msg, NULL, 0, 0, PM_REMOVE))
//        {
//            /* handle or dispatch messages */
//            if (msg.message == WM_QUIT)
//            {
//                bQuit = TRUE;
//            }
//            else
//            {
//                TranslateMessage (&msg);
//                DispatchMessage (&msg);
//            }
//        }
//        else
//        {
//            /* OpenGL animation code goes here */
//            
//            glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
//            glClear (GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
//            glEnable(GL_DEPTH_TEST);
//            glLoadIdentity();
//            gluPerspective(60.0f, 1, 0.1f, 100.0f);
//            
//            float theta=180*thetime;
//            glRotatef (theta, 0.0f, 1.0f, 0.0f);
//            
//            glTranslatef(-0.5, -0.5, -0.5);
//            
//            glEnable(GL_TEXTURE_2D);
//            glBindTexture(GL_TEXTURE_2D, mytexture);
//            vector<Triangle>::iterator i = triangles.begin();
//            int trictr = 0;
//            
//            glBegin(GL_TRIANGLES);
//            while (i != triangles.end()) 
//            {
//                Triangle t = *i++;
//                // let's shrink the triangles slightly, so we don't get weird edge issues
//                float centroidx = (tm.getu0(trictr) + tm.getu1(trictr) + tm.getu2(trictr))/3;
//                float centroidy = (tm.getv0(trictr) + tm.getv1(trictr) + tm.getv2(trictr))/3;
//                
//                
//                float realfraction=0.9925;
//                
//                float centroidfraction=1.0-realfraction;
//                
//                
//                float realx0 = realfraction*tm.getu0(trictr) + centroidfraction*centroidx;
//                float realx1 = realfraction*tm.getu1(trictr) + centroidfraction*centroidx;
//                float realx2 = realfraction*tm.getu2(trictr) + centroidfraction*centroidx;
//                
//                float realy0 = realfraction*tm.getv0(trictr) + centroidfraction*centroidy;
//                float realy1 = realfraction*tm.getv1(trictr) + centroidfraction*centroidy;
//                float realy2 = realfraction*tm.getv2(trictr) + centroidfraction*centroidy;
//                
//                glNormal3f(t.normal[0], t.normal[1], t.normal[2]);
//                glTexCoord2f(realx0, realy0);
//                glVertex3f(t.v0[0], t.v0[1], t.v0[2]);
//                
//                
//                glNormal3f(t.normal[0], t.normal[1], t.normal[2]);
//                glTexCoord2f(realx1, realy1);
//                glVertex3f(t.v1[0], t.v1[1], t.v1[2]);
//                
//                
//                glNormal3f(t.normal[0], t.normal[1], t.normal[2]);
//                glTexCoord2f(realx2, realy2);
//                glVertex3f(t.v2[0], t.v2[1], t.v2[2]);	
//                trictr++;
//            }
//            glEnd();
//            
//            
//            SwapBuffers (hDC);
//            
//            
//            
//            Sleep (1);
//        }
//    }
//    
//    /* shutdown OpenGL */
//    DisableOpenGL (hWnd, hDC, hRC);
//    
//    /* destroy the window explicitly */
//    DestroyWindow (hWnd);
//    
//    return msg.wParam;
//}


/********************
 * Window Procedure
 *
 ********************/

LRESULT CALLBACK WndProc (HWND hWnd, UINT message,
                          WPARAM wParam, LPARAM lParam)
{
    
    switch (message)
    {
        case WM_CREATE:
            return 0;
        case WM_CLOSE:
            PostQuitMessage (0);
            return 0;
            
        case WM_DESTROY:
            return 0;
            
        case WM_KEYDOWN:
            switch (wParam)
        {
            case VK_ESCAPE:
                PostQuitMessage(0);
                return 0;
        }
            return 0;
            
        default:
            return DefWindowProc (hWnd, message, wParam, lParam);
    }
}


/*******************
 * Enable OpenGL
 *
 *******************/

void EnableOpenGL (HWND hWnd, HDC *hDC, HGLRC *hRC)
{
    PIXELFORMATDESCRIPTOR pfd;
    int iFormat;
    
    /* get the device context (DC) */
    *hDC = GetDC (hWnd);
    
    /* set the pixel format for the DC */
    ZeroMemory (&pfd, sizeof (pfd));
    pfd.nSize = sizeof (pfd);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | 
    PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 24;
    pfd.cDepthBits = 16;
    pfd.iLayerType = PFD_MAIN_PLANE;
    iFormat = ChoosePixelFormat (*hDC, &pfd);
    SetPixelFormat (*hDC, iFormat, &pfd);
    
    /* create and enable the render context (RC) */
    *hRC = wglCreateContext( *hDC );
    wglMakeCurrent( *hDC, *hRC );
    
}


/******************
 * Disable OpenGL
 *
 ******************/

void DisableOpenGL (HWND hWnd, HDC hDC, HGLRC hRC)
{
    wglMakeCurrent (NULL, NULL);
    wglDeleteContext (hRC);
    ReleaseDC (hWnd, hDC);
}
