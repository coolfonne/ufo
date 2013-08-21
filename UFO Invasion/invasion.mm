//#include <windows.h>
//#include <gl/gl.h>
//#include <gl/glu.h>
#include <vector>
#import <Cocoa/Cocoa.h>
#include "box.h"
#include "wavefront.h"
#include "newfont.h"
#import <AudioToolbox/AudioToolbox.h>
//#include "skycube\skycube.h"

#include "skycube.h"

enum gamestatetype {GAMEMENU, ACTION, PAUSED, INSTRUCTIONS, YOULOSE, YOUWIN};
enum menuselectiontype {PLAY, INFO, EXITGAME};

gamestatetype gamestate = GAMEMENU;

//int health=999100;
int health=100;

menuselectiontype menusel = PLAY;
float menuselrotatetime=0;

Newfont *nf;

//SystemSoundID explosion_sound_id;

//int window_width=800, window_height=600;
int window_width=1920, window_height=1200;
// last enemy spawn time
long lastspawn = 0;


int physicsactual=0, physicsgoal=0;

Skycube *skycube;

int level = -1;

float theta = 0.0f;

extern int rightkeydown,leftkeydown;
extern int missilekeydown;

extern NSSound* explosion;

//GLboolean rightKeyDown=false;
//GLboolean leftKeyDown=false;


double rand01(void)
{
    double num = double(rand())/double(RAND_MAX);
    return num;
}

//LRESULT CALLBACK WndProc (HWND hWnd, UINT message,
//			  WPARAM wParam, LPARAM lParam);
//void EnableOpenGL (HWND hWnd, HDC *hDC, HGLRC *hRC);
//void DisableOpenGL (HWND hWnd, HDC hDC, HGLRC hRC);

void drawinstructions(void);
void drawgamemenu(void);
void drawgamescreen(void);
void drawpausedscreen(void);
void drawyoulose(void);
void drawyouwin(void);
void spawnenemy(long tickctr);

Wavefront planemesh("plane.obj","plane.mtl", .002);
Wavefront ufo("ufo.obj","ufo.mtl", .002);
Wavefront ufodamaged("ufodamaged.obj","ufodamaged.mtl", .002);
Wavefront ufo2("ufo2.obj","ufo2.mtl", .001);
Wavefront ufo3("ufo3.obj","ufo3.mtl", .002);
Wavefront ufo3damaged("ufo3damaged.obj","ufo3damaged.mtl", .002);
Wavefront ufo4("ufo4.obj","ufo4.mtl", .004);
Wavefront ufo4damaged("ufo4damaged.obj","ufo4damaged.mtl", .004);
Wavefront bombmesh("bomb.obj","bomb.mtl", .001);
Wavefront bigufo("mothership.obj","mothership.mtl", .005);
Wavefront bigufodamaged("mothershipdamaged.obj","mothershipdamaged.mtl", .005);
Wavefront explodemesh("explosion.obj","explosion.mtl", .001);
Wavefront missile("missile.obj","missile.mtl", .0005);

float shipx=0;
float shipv=0;
float shipa=0;
float shipangle=0;

struct Missile {
    float x, y;
    float vy;
    float vx;
    float missileay;
    
    Box getbox()
    {
        return movebox(missile.box, x, y, 0);    
    }
    
    
};

vector<Missile> missiles;

struct Enemy {
    float x, y;       
    float vx, vy;
    float ax, ay;
    float freq, width;
    float xoff;
    float wobbleoffset;
    float lastbombtime;
    int strengthleft;
    Wavefront *mesh;
    
    // how often a bomb will be dropped
    // higher numbers are less likely
    int bombrand;
    
    // definite wait between bombs
    int bombwait;
    
    // mesh for when the ship is damaged
    Wavefront *damagemesh;
    
    Enemy(float x, float y)
    {
        this->x = x;
        this->y = y;            
        this->strengthleft=1;
        this->mesh = &ufo;
        this->lastbombtime = 0;
        this->damagemesh = NULL;
        this->bombrand = 100;
        this->bombwait = 100;    
        xoff=0;
    } 
    
    Box getbox()
    {
        //return mesh->box;
        return movebox(mesh->box, x, y, 0);
        //return movebox(mesh->box, x, y, -0.01);    
    }
    
};

vector<Enemy> enemies;

int countsincemissile=0;


struct Explosion
{
    float x, y;       
    int timeleft;       
};

vector<Explosion> explosions;


struct FallingEnemy
{
    // positions
    float x, y, z;
    // velocities       
    float vx, vy, vz;                       
    float angle;  
    Wavefront *mesh;  
};

vector<FallingEnemy> fallingenemies;

struct Bomb
{
    float x, y;
    float vx, vy;             
    float rotation_x;
    float rotation_dx;
    
    float rotation_axis_x;
    float rotation_axis_y;
    float rotation_axis_z;
    
    Box getbox()
    {
        return movebox(bombmesh.box, x, y, 0);    
    }
    
};

vector<Bomb> bombs;


void physicsloop(void);

//void CALLBACK cbFunct(UINT , UINT , DWORD_PTR , DWORD_PTR , DWORD_PTR ) 
//{ 
//  if (gamestate == ACTION) physicsgoal++;        
//  if (gamestate == GAMEMENU) menuselrotatetime+=.03;         
//} 

bool musicrolling = false;    

//DWORD WINAPI MusicThread( LPVOID lpParam ) 
//{   
//  mciSendString("open \"music.mid\" type sequencer alias coolmidi", 0, 0, 0);   musicrolling = true;
//  while (TRUE) mciSendString("play coolmidi from 0 wait", 0, 0, 0);        
//}

//HINSTANCE globalhinst;
//LPVOID expRes; 

//int WINAPI WinMain (HINSTANCE hInstance,
//                    HINSTANCE hPrevInstance,
//                    LPSTR lpCmdLine,
//                    int iCmdShow)

void mymain(void)
{

    
    nf = new Newfont("myfont.obj", "myfont.mtl", 1);  

    
    glEnable(GL_LIGHTING);
    GLfloat LightAmbient[]= { 0, 0, 0, 1.0f };
    GLfloat LightDiffuse[]= { .04, .04, .04, 1.0f };
    GLfloat LightGlobal[]= { .5, .5, .5, 1.0f };
    
    GLfloat LightPosition[]= { 0.0f, 0.0f, -100.0f, 1.0f };
    glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);	
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);	
    glLightfv(GL_LIGHT1, GL_POSITION,LightPosition);
    glEnable(GL_LIGHT1);
    
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LightGlobal);
    
    

    

    
    glClearColor (0.0f, 0.0f, 0.0f, 0.0f);
    glClear (GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glLoadIdentity();
    gluPerspective(60.0f, float(window_width)/float(window_height), 0.1f, 100.0f);
    
    if (gamestate == GAMEMENU) {drawgamemenu(); 
        
    }
    else if (gamestate == ACTION) drawgamescreen();
    else if (gamestate == PAUSED) 
    {
        drawgamescreen();
        drawpausedscreen();
    }
    else if (gamestate == INSTRUCTIONS) drawinstructions();
    else if (gamestate == YOULOSE) 
    {
        drawgamescreen();     
        drawyoulose();
    }
    else if (gamestate == YOUWIN) 
    {
        drawgamescreen();     
        drawyouwin();
    }
    
    // SwapBuffers (hDC);
    
    
    if (gamestate == ACTION)
    {
        // take care of the physics
        while (physicsactual < physicsgoal) {physicsloop(); 
            
            for (int ctr=0; ctr<10; ctr++) {
                spawnenemy(physicsactual);
            }
            
            physicsactual++;}
        
        if (health == 0) gamestate = YOULOSE;
        if (physicsactual > 43250) gamestate = YOUWIN;
    }
    
    
   
}


void centertext(char *str)
{
    glPushMatrix();
    float fontwid = nf->getwidth(str, .05);
    glTranslatef(-fontwid/2.0, 0, 0);            
    nf->drawstring(str, .05);
    glPopMatrix();
    
}


void drawinstructions(void)
{
    
    
    glPushMatrix();     
    glTranslatef(0, 0, -1);
    
    // draw the skycube 
    glDepthMask(GL_FALSE);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    skycube->draw();	  
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glPopMatrix();
    
    skycube->scrolldown();
    
    
    
    
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);            
    glPushMatrix ();
    glTranslatef(0, 2.25, -7);            
    glColor3f(.1, 1, .1);
    centertext("Instructions");
    glColor3f(1, 1, 1);
    glTranslatef(0, 0, -7);            
    glTranslatef(0, -1.25, 0);             
    centertext("Left and right arrow to move");	  
    glTranslatef(0, -1.25, 0);            
    //centertext("Right CTRL to fire");
    
        centertext("Z to fire");
    glTranslatef(0, -1.25, 0);            
    centertext("P to pause or unpause");
    glColor3f(0.1, 1, 0.1);
    glTranslatef(0, -1.25, 0);            
    centertext("Press Enter to return to main menu");     
    glPopMatrix ();
    glEnable(GL_LIGHTING);
    glEnable(GL_DEPTH_TEST);                 
}



// draw the menu screen
void drawgamemenu(void)
{
    
    
    glPushMatrix();     
    glTranslatef(0, 0, -1);
    
    // draw the skycube 
    glDepthMask(GL_FALSE);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    skycube->draw();	  
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glPopMatrix();
    
    skycube->scrolldown();
    //skycube->draw();
    
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);            
    glPushMatrix ();
    glTranslatef(0, .25, -8);            
    glTranslatef(-1.1, 0, 0);            
    glColor3f(1, 1, 1); 
    float fontwid;  
    glPushMatrix();
    fontwid = nf->getwidth("Play", .05);
    nf->drawstring("Play", .05);
    glPopMatrix(); 	  	  	  
    glTranslatef(0, -1, 0);            
    glPushMatrix();
    fontwid = nf->getwidth("Instructions", .05);
    nf->drawstring("Instructions", .05);
    glPopMatrix();
    glTranslatef(0, -1, 0);            
    glPushMatrix();
    fontwid = nf->getwidth("Exit", .05);
    nf->drawstring("Exit", .05);
    glPopMatrix();
    glTranslatef(0, 3, 4);            
    glColor3f(0.1, 1, 0.1);
    glTranslatef(1.1, 0, 0);            
    glPushMatrix();
    centertext("UFO Invasion");
    glPopMatrix();
    glPopMatrix ();	    
    glPushMatrix ();	    
    if (menusel == PLAY) glTranslatef(-.3, 0.005, -1);
    else if (menusel == INFO) glTranslatef(-.3, -.125, -1);
    else if (menusel == EXITGAME) glTranslatef(-.3, -.25, -1);
    glEnable(GL_DEPTH_TEST);            
    glDisable(GL_BLEND);
    glDisable(GL_POLYGON_SMOOTH);	    
    glEnable(GL_LIGHTING);
    glRotatef(sin(menuselrotatetime)*30, 1, 0, 0);
    //ufo.draw();   
      ufo3.draw();  
    glPopMatrix ();	       	     
}

void drawgamescreen(void)
{
    
    if (!nf)
        nf = new Newfont("myfont.obj", "myfont.mtl", 1);  
    
    glPushMatrix();     
    glTranslatef(0, 0, -1);
    
    // draw the skycube 
    glDepthMask(GL_FALSE);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    skycube->draw();	  
    glDepthMask(GL_TRUE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    
    
    //glDisable(GL_CULL_FACE);
    // draw the missiles
    for (int ctr = 0; ctr < missiles.size(); ctr++)
    {
        glPushMatrix();	  	  
        Missile &m = missiles[ctr];
        glTranslatef(m.x, m.y, -.01);
        glRotatef (theta*5, 0, 1.0f, 0.0f);
        missile.draw(); 
        glPopMatrix();	  	  
    }
    
    
    // draw the explosions
    for (int ctr = 0; ctr < explosions.size(); ctr++)
    {
        glPushMatrix();	  	  
        Explosion &e = explosions[ctr];
        glTranslatef(e.x, e.y, 0);
        explodemesh.draw(); 
        glPopMatrix();	  	  
    }
    
    
    
    
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    glClear(GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    glTranslatef(0, 0, -1   );
    // draw the plane
    glPushMatrix();	  	  
    glTranslatef(0, -.4, 0);
    glTranslatef(shipx, 0, 0);
    float rotangle=0;
    if (shipangle > 0) rotangle = shipangle*shipangle;
    if (shipangle < 0) rotangle = -shipangle*shipangle;
    glRotatef (sin(theta/20.0)*10, 0, 1.0f, 0.0f);
    glRotatef (rotangle, 0, 1.0f, 0.0f);
    
   //  glDepthMask(GL_FALSE);
    //
    
  //  glDisable(GL_LIGHTING);
    planemesh.draw();
    glPopMatrix();	  	  
    
    shipa=0;
    
    // draw the bombs
    for (int ctr = 0; ctr < bombs.size(); ctr++)
    {
        glPushMatrix();	  	  
        glTranslatef(bombs[ctr].x, bombs[ctr].y, 0);
        //float angle = bombs[ctr].rotation_x;
        //glRotatef(bombs[ctr].rotation_x, 1, 0, 0);
        glRotatef(bombs[ctr].rotation_x, bombs[ctr].rotation_axis_x, bombs[ctr].rotation_axis_y, bombs[ctr].rotation_axis_z);
        bombmesh.draw();
        glPopMatrix();	  	  
    }	  
    
    // draw the enemies
    for (int ctr = 0; ctr < enemies.size(); ctr++)
    {
        glPushMatrix();	  	  
        glTranslatef(enemies[ctr].x, enemies[ctr].y, 0);      
        // wobble
        glRotatef (sin(theta/20.0+enemies[ctr].wobbleoffset)*15+17, 1, 0, 0.0f);	      
        if (enemies[ctr].strengthleft==1 && enemies[ctr].damagemesh) enemies[ctr].damagemesh->draw();
        else enemies[ctr].mesh->draw();
        glPopMatrix();	  	  
    }	 
    
    
    // draw falling enemies
    for (int ctr = 0; ctr < fallingenemies.size(); ctr++)
    {
        FallingEnemy &f = fallingenemies[ctr];
        glPushMatrix();	  	  
        glTranslatef(f.x, f.y, f.z);
        glRotatef(-f.angle, 1, 0, 0);
        f.mesh->draw();
        glPopMatrix();	  	  	      	      
    }      
    
    // draw the health
    glDisable(GL_DEPTH_TEST);            
    glPushMatrix ();
    glTranslatef(-8, 5.5, -10);            
    char healthstr[80];
    sprintf(healthstr, "Health: %d%%", health);
    glEnable(GL_COLOR_MATERIAL);
    glColor3f(1, 1, 1);
    glColor3f(.9, .4, 0);
    glEnable(GL_POLYGON_SMOOTH);
    nf->drawstring(healthstr, .05);
    glPopMatrix ();	    
    glEnable(GL_DEPTH_TEST);            
    glDisable(GL_BLEND);
    glDisable(GL_POLYGON_SMOOTH);	    
    glPopMatrix();     
}

void drawpausedscreen(void)
{
    glDisable(GL_LIGHTING);
    // draw the paused screen
    glDisable(GL_DEPTH_TEST);            
    glPushMatrix ();
    glTranslatef(-1.20, .25, -2);            
    glColor3f(1, 1, 1);
    nf->drawstring("Paused", .05);
    glPopMatrix ();	    
    glEnable(GL_DEPTH_TEST);            
    glDisable(GL_BLEND);
    glDisable(GL_POLYGON_SMOOTH);	    
    glEnable(GL_LIGHTING);     
}

void drawyouwin(void)
{
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);            
    glPushMatrix ();	  
    glTranslatef(0, .5, -3);            
    glColor3f(1, 1, 1);
    centertext("You win!");     
    glPopMatrix ();	    	  	  
    glPushMatrix ();
    glTranslatef(0, -1, -9);      
    centertext("Press Enter to return to main menu");     
    glPopMatrix ();	  	  	  	  
    glEnable(GL_DEPTH_TEST);            
    glDisable(GL_BLEND);
    glDisable(GL_POLYGON_SMOOTH);	    
    glEnable(GL_LIGHTING);    
}

void drawyoulose(void)
{
    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);            
    glPushMatrix ();  
    glTranslatef(0, .5, -3);            	  
    glColor3f(1, 1, 1);
    float fontwid = nf->getwidth("Game over", .05);
    glTranslatef(-fontwid/2.0, 0, 0);                    
    nf->drawstring("Game over", .05);
    glPopMatrix ();	    	  	  	  
    glPushMatrix ();
    glTranslatef(0, -1, -9);      
    centertext("Press Enter to return to main menu");     
    glPopMatrix ();	  	  	  	  
    glEnable(GL_DEPTH_TEST);            
    glDisable(GL_BLEND);
    glDisable(GL_POLYGON_SMOOTH);	    
    glEnable(GL_LIGHTING);     
}

void reseteverything(void)
{
    health=100;              
    physicsactual=0;
    physicsgoal=0;
    lastspawn = 0;
    shipx=0;
    shipv=0;
    shipa=0;
    enemies.clear();
    missiles.clear();
    explosions.clear();
    fallingenemies.clear();
    bombs.clear();
    gamestate = GAMEMENU;     
}




void physicsloop(void)
{
    
    theta += 1.0f;
    
    
    
    if (rightkeydown) 
    {
        shipa=.002;
        if (shipangle < 6) shipangle++;
    }
    else if (shipangle > 0) shipangle--;
    
    if (leftkeydown) {
        
        shipa=-.002;
        if (shipangle > -6) shipangle--;
    }
    else if (shipangle < 0) shipangle++;
    

    if (missilekeydown && countsincemissile>15) 
    {
        countsincemissile=0;                                   
        Missile m;                                   
        m.x=shipx;
        m.y=-.35;
        m.vy=.006;
        m.vx=0;
        m.missileay=.0;
        missiles.push_back(m);  
        
        
        m.vx=.002;
        missiles.push_back(m);  
        m.vx=-.002;
        missiles.push_back(m);  
        
        
    }
    else countsincemissile++;	
    
    // missile physics
    
    for (int ctr = 0; ctr < missiles.size(); ctr++)
    {
        Missile &m = missiles[ctr];
        
        // if the missile is too high up, don't check for collisions
        if (m.y > .5) continue;
        
        for (int ctr2 = 0; ctr2 < enemies.size(); ctr2++)
        {
            Enemy &enemy = enemies[ctr2];    
            if (intersect(m.getbox(), enemy.getbox()))
            {                       
                Box i = isection(m.getbox(), enemy.getbox());                       	     		      
                enemy.strengthleft--;		      
                
                if (enemy.strengthleft <= 0)
                {		      
                    // add a falling enemy
                    FallingEnemy f;
                    f.x = enemy.x;
                    f.y = enemy.y;
                    f.z=0;
                    f.vy=.006;
                    f.vx=m.vx;
                    f.vz=-.005;
                    
                    if (enemy.damagemesh) f.mesh = enemy.damagemesh;
                    else f.mesh = enemy.mesh;
                    
                    f.angle=0;
                    fallingenemies.push_back(f);		      
                    
                    enemies.erase(enemies.begin()+ctr2);
                    ctr2--;  		      
                }
                
                missiles.erase(missiles.begin()+ctr);
                ctr--;
                
                // add the explosion
                Explosion e;
                e.x = (i.minx+i.maxx)/2.0;
                e.y = (i.miny+i.maxy)/2.0;
                e.timeleft=15;
                explosions.push_back(e);
                
                [explosion stop];
                [explosion play];
                
                // PlaySound("explosion", globalhinst, SND_RESOURCE | SND_ASYNC); 
                break;  
            }
            
            
            
        }
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    for (int ctr = 0; ctr < missiles.size(); ctr++)
    {
        Missile &m = missiles[ctr];
        
        // if the missile is too high up, don't check for collisions
        if (m.y > .5) continue;
        
        
        
        
        
        // check bomb/missile intersections
        
        for (int ctr3 = 0; ctr3 < bombs.size(); ctr3++)
        {
            // Enemy &enemy = enemies[ctr2];   
            
            Bomb &b = bombs[ctr3];
            
            if (intersect(m.getbox(), b.getbox()))
            {                       
                Box i = isection(m.getbox(), b.getbox());                       	     	
                
                
                bombs.erase(bombs.begin()+ctr3); ctr3--;
                
                // add the explosion
                Explosion e;
                e.x = (i.minx+i.maxx)/2.0;
                e.y = (i.miny+i.maxy)/2.0;
                e.timeleft=15;
                explosions.push_back(e);
                
                [explosion stop];
                [explosion play];
                
                missiles.erase(missiles.begin()+ctr);
                ctr--;
                
                break;  
                
                //enemy.strengthleft--;		      
                
            }
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    // move missiles
    for (int ctr = 0; ctr < missiles.size(); ctr++)
    {
        Missile &m = missiles[ctr];
        m.y+=m.vy;
        m.vy+=m.missileay;
        m.x+=m.vx;
        
    }
    
    // delete far away missiles
    for (int ctr = 0; ctr < missiles.size(); ctr++)
    {
        Missile &m = missiles[ctr];
        if (m.y > .65) {missiles.erase(missiles.begin()+ctr); ctr--;}
    }
    
    // move ship	 
    shipx+=shipv;	 
    
    if (shipx > .66) shipx = .66;
    if (shipx < -.66) shipx = -.66;
    
    if (fabs(shipv) < 0.014) shipv+=shipa;	 
    
    // friction
    if (shipv > 0) {
        if (shipv < 0.0015) shipv = 0;
        else          shipv-=0.001;
    }
    else if (shipv < 0) 
    {
        if (shipv > -0.0015) shipv = 0;
        else shipv+=0.001;
    }
    
    // remove finished explosions
    for (int ctr = 0; ctr < explosions.size(); ctr++)
    {
        Explosion &e = explosions[ctr];
        e.timeleft--;
        if (e.timeleft <= 0) {explosions.erase(explosions.begin()+ctr); ctr--;}
    }
    
    // make falling enemies fall
    for (int ctr = 0; ctr < fallingenemies.size(); ctr++)
    {
        FallingEnemy &f = fallingenemies[ctr];
        f.x+=f.vx;
        f.y+=f.vy;
        f.z+=f.vz;
        // gravity
        f.vy-=.001;
        f.angle+=10;
    }
    
    // remove finished falling enemies
    for (int ctr = 0; ctr < fallingenemies.size(); ctr++)
    {
        FallingEnemy &f = fallingenemies[ctr];	      
        if (f.y < -3.8) {fallingenemies.erase(fallingenemies.begin()+ctr); ctr--;}
    }
    
    
    // remove finished unkilled enemies
    for (int ctr = 0; ctr < enemies.size(); ctr++)
    {
        Enemy &e = enemies[ctr];	      
        if (e.y < -1.0) {enemies.erase(enemies.begin()+ctr); ctr--;}
    }
    
    for (int ctr = 0; ctr < enemies.size(); ctr++)
    {
        Enemy &e = enemies[ctr];
        e.x = sin(theta*e.freq + e.y*4  + e.xoff)*e.width + e.xoff;
        e.y += e.vy;
        e.vx+=e.ax;               
    }
    
    // scroll the sky
    skycube->scrolldown();
    
    // let's see if we want to drop a bomb
    for (int ctr = 0; ctr < enemies.size(); ctr++)
    {        
        Enemy &e = enemies[ctr];           
        if (rand()%e.bombrand == 0 && e.y < .6 && theta-e.lastbombtime > e.bombwait)
        {
            Bomb b;
            b.x = enemies[ctr].x;               
            b.y = enemies[ctr].y-0.03;
            Enemy &e = enemies[ctr];
            b.vx = cos(theta*e.freq + e.y*4  + e.xoff)*e.width*e.freq ;
            b.vy=-0.004;
            
            b.rotation_x=0.0;
            b.rotation_dx=5;
            
            b.rotation_axis_x=rand01();
            b.rotation_axis_y=rand01();
            b.rotation_axis_z=rand01();
            
            bombs.push_back(b);               
            enemies[ctr].lastbombtime=theta;
        }       
    }
    
    // move the bombs down and see if they hit the plane
    Box scaledplane = scalebox(planemesh.box, .2, 1, 1);
    Box planebox = movebox(scaledplane, shipx, -0.4, 0);
    
    for (int ctr = 0; ctr < bombs.size(); ctr++)
    {
        Bomb &b =     bombs[ctr];
        bombs[ctr].x+=bombs[ctr].vx;    
        bombs[ctr].y+=bombs[ctr].vy;
        bombs[ctr].rotation_x+=bombs[ctr].rotation_dx;
        
        if (bombs[ctr].y < -1) {bombs.erase(bombs.begin()+ctr); ctr--; continue;}
        if (intersect(bombs[ctr].getbox(), planebox)) 
        {
            Box i = isection(b.getbox(), planebox); 
            health-=10;
            if (health < 0) health=0;                                  
            bombs.erase(bombs.begin()+ctr); ctr--;
            
            // add the explosion
            Explosion e;
            e.x = (i.minx+i.maxx)/2.0;
            e.y = (i.miny+i.maxy)/2.0;
            e.timeleft=15;
            explosions.push_back(e);
            
            [explosion stop];
            [explosion play];
            //PlaySound("explosion", globalhinst, SND_RESOURCE | SND_ASYNC);       
        }
        
        
    }
    
    // see if any enemies collide with the player
    
    for (int ctr = 0; ctr < enemies.size(); ctr++)
    {
        Enemy &enemy =     enemies[ctr];
        
        if (!intersect(enemy.getbox(), planebox)) continue;
        
        // collision between plane and enemy
        health-=25;
        if (health < 0) health=0;
        
        Box i = isection(enemy.getbox(), planebox); 
        // add the explosion
        Explosion e;
        e.x = (i.minx+i.maxx)/2.0;
        e.y = (i.miny+i.maxy)/2.0;
        e.timeleft=15;
        explosions.push_back(e);
        
        [explosion stop];
        [explosion play];
        
        // PlaySound("explosion", globalhinst, SND_RESOURCE | SND_ASYNC); 
        
        // add a falling enemy
        FallingEnemy f;
        f.x = enemy.x;
        f.y = enemy.y;
        f.z=0;
        f.vy=.006;
        f.vx=shipv;
        f.vz=0;
        
        if (enemy.damagemesh) f.mesh = enemy.damagemesh;
        else f.mesh = enemy.mesh;
        
        f.angle=0;
        fallingenemies.push_back(f);		      
        
        enemies.erase(enemies.begin()+ctr); ctr--;
    }
    
    
    
    
    // if we're out of enemies, send out the next wave
    if (enemies.size() == 0)
    {
        if (level == 0)
        {
            
            for (float y = .9; y < 1.1; y+=.18)
            {
                Enemy e = Enemy(0, y);
                e.vx=0;
                e.xoff=.2;
                e.vy=-.001;
                e.freq=.05;
                e.width=.1;
                e.wobbleoffset = rand01()*100;
                e.mesh = &ufo2;
                enemies.push_back(e);    
                e.wobbleoffset = rand01()*100;	
                e.xoff=-.2;
                e.y-=.1;
                enemies.push_back(e);    	
            }
            
            level++;
            
        }      
        
        else if (level == 1)
        {
            
            for (float x = -.4; x <= .41; x+=.4) {
                for (float y = .9; y < 1.3; y+=.18)
                {
                    Enemy e = Enemy(0, y+fabs(x));
                    e.vx=0;
                    e.xoff=x;
                    e.vy=-.001;
                    e.freq=.05;
                    e.width=.04;
                    
                    e.wobbleoffset = rand01()*100;
                    e.mesh = &ufo3;
                    e.damagemesh = &ufo3damaged;
                    e.strengthleft=2;
                    enemies.push_back(e);    
                }
            }
            
            level++;     
        }
        else if (level == 2)
        {
            for (float x = -.4; x <= .41; x+=.4) {
                for (float y = .9; y < 1.3; y+=.18)
                {
                    Enemy e = Enemy(0, y+fabs(x));
                    e.vx=0;
                    e.xoff=x;
                    e.vy=-.001;
                    e.freq=.05;
                    e.width=.04;
                    e.wobbleoffset = rand01()*100;
                    e.mesh = &ufo4;
                    e.damagemesh = &ufo4damaged;
                    e.strengthleft=2;
                    enemies.push_back(e);    
                }
            }
            
            level++;       
        }
        else if (level == 3)
        {
            Enemy e = Enemy(0, .9);
            e.vx=0;
            e.xoff=0;
            e.vy=-.0005;
            e.freq=.05;
            e.width=.04;
            e.mesh = &bigufo;
            e.damagemesh = &bigufodamaged;
            e.wobbleoffset = rand01()*100;
            e.strengthleft=5;
            enemies.push_back(e);    
            level++;
        }
        
    }
    
    
}

void spawnenemy(long tickctr)
{
    // mothership code
    if (tickctr > 40000)
    {
        if (tickctr != 41250) return;
        Enemy e = Enemy(0, .7);
        e.mesh = &bigufo;
        e.damagemesh = &bigufodamaged;
        e.freq=.05;
        e.bombrand = 2;              
        e.bombwait = 5;              
        e.vy=-.0005;
        e.strengthleft = 10;
        enemies.push_back(e);
        lastspawn = tickctr;                                    
        return;             
    }
    
    Wavefront *mesharray[4] = {&ufo, &ufo2, &ufo3, &ufo4};
    Wavefront *meshdamagedarray[4] = {&ufodamaged, &ufo2, &ufo3damaged, &ufo4damaged};
    
    // prevent spawning too quickly
  //  if (tickctr - lastspawn < 140) return;
    
    if (rand() % 100 == 0) 
    {
        // spawn
        Enemy e = Enemy(0, .7);
        e.vx=0;
        e.xoff=rand01()-0.5;
        e.vy=-.001;
        e.freq=.05;
        e.width = (tickctr%10000)*.0001*0.2+0.05;
        //
        //e.width=0;
        e.wobbleoffset = rand01()*100;
        
                e.x = sin(theta*e.freq + e.y*4  + e.xoff)*e.width + e.xoff;
        
        int meshindex = tickctr/10000;
        if (meshindex > 3) meshindex=3;
        
        if (meshindex == 1) e.bombrand = 100;              
        if (meshindex == 2) e.bombrand = 50;              
        if (meshindex == 3) e.bombrand = 50;              
        
        if (meshindex == 1) e.bombwait = 50;              
        if (meshindex == 2) e.bombwait = 40;              
        if (meshindex == 3) e.bombwait = 30;              
        
        e.mesh = mesharray[meshindex];
        
        if (meshindex != 1) e.strengthleft = rand()%(9+meshindex)+1;
        if (meshindex == 0) e.strengthleft = 2;
        if (e.strengthleft > 1) e.damagemesh = meshdamagedarray[meshindex];
        
        
        
        for (int ctr2 = 0; ctr2 < enemies.size(); ctr2++)
        {
            Enemy &enemy = enemies[ctr2];    
            if (intersect(e.getbox(), enemy.getbox()))
            {            
                return;
                //Box i = isection(m.getbox(), enemy.getbox());                       	     		      
                //enemy.strengthleft--;	
            }
        }
        
        
        
        enemies.push_back(e);
        lastspawn = tickctr;
    }
}



