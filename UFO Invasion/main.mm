//
//  main.m
//  UFO Invasion
//
//  Created by administrator a on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <GLUT/glut.h>
#include "wavefront.h"
#include "skycube.h"
#include "newfont.h"
#import <AudioToolbox/AudioToolbox.h>

SystemSoundID explosion_sound_id;

extern Wavefront planemesh;
extern Wavefront ufo;
extern Wavefront ufodamaged;
extern Wavefront ufo2, ufo3, ufo4;
extern Wavefront  ufo3damaged, ufo4damaged;

extern Wavefront  bombmesh, bigufo, bigufodamaged;
extern Wavefront  explodemesh, missile;

extern int physicsgoal;
extern int physicsactual;

extern Skycube *skycube;

extern void drawgamescreen(void);
extern void physicsloop(void);
extern void spawnenemy(long tickctr);

int rightkeydown=0,leftkeydown=0;

int missilekeydown=0;

extern int window_width, window_height;

extern int health;

NSSound* explosion;

extern Newfont *nf;

enum gamestatetype {GAMEMENU, ACTION, PAUSED, INSTRUCTIONS, YOULOSE, YOUWIN};
enum menuselectiontype {PLAY, INFO, EXITGAME};

extern gamestatetype gamestate;
extern menuselectiontype menusel;

extern void drawpausedscreen(void);
extern void drawgamemenu(void);
extern void drawinstructions(void);
extern void drawyoulose(void);
extern void drawyouwin(void);
extern void reseteverything(void);

extern float menuselrotatetime;

void stuff(void);

void light2(void)
{
    
    glEnable(GL_LIGHTING);
    GLfloat LightAmbient[]= { 0.0, 0.0, 0.0, 1.0f };
    GLfloat LightDiffuse[]= { 1.04, 1.04, 1.04, 1.0f };
    GLfloat LightGlobal[]= { .205, .205, .205, 1.0f };
    
    //GLfloat LightPosition[]= { 100.0f,00.0f, 00.0f, 0.0f };
    
    
       GLfloat LightPosition[]= { 0.0f,00.0f, 100.0f, 0.0f };
    
    glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);	
    glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);	
    glLightfv(GL_LIGHT1, GL_POSITION,LightPosition);
    glEnable(GL_LIGHT1);
    
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LightGlobal); 
    
}



void SetLighting(unsigned int mode)
{
	GLfloat mat_specular[] = {1.0, 1.0, 1.0, 1.0};
	GLfloat mat_shininess[] = {90.0};
    
	GLfloat position[4] = {7.0,-7.0,12.0,0.0};
	GLfloat ambient[4]  = {0.2,0.2,0.2,1.0};
    GLfloat diffuse[4]  = {0.0,0.0,1.0,1.0};
	GLfloat specular[4] = {1.0,1.0,1.0,1.0};
	
	glMaterialfv (GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
	glMaterialfv (GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
	
	glEnable(GL_COLOR_MATERIAL);
	glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
    
	switch (mode) {
		case 0:
			break;
		case 1:
			glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,GL_FALSE);
			glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER,GL_FALSE);
			break;
		case 2:
			glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,GL_FALSE);
			glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER,GL_TRUE);
			break;
		case 3:
			glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,GL_TRUE);
			glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER,GL_FALSE);
			break;
		case 4:
			glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,GL_TRUE);
			glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER,GL_TRUE);
			break;
	}
	
	glLightfv(GL_LIGHT0,GL_POSITION,position);
	glLightfv(GL_LIGHT0,GL_AMBIENT,ambient);
	glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuse);
	glLightfv(GL_LIGHT0,GL_SPECULAR,specular);
	glEnable(GL_LIGHT0);
}




void* PosixThreadMainRoutine(void* data)
{
    
    srand(time(NULL));
    sleep(1);    
    while (1) 
    {                      
        
        if (gamestate == ACTION) physicsgoal++;        
        if (gamestate == GAMEMENU) menuselrotatetime+=.03;  
        
        
        usleep(14000);
    }      
    
}    







pthread_t       posixThreadID;
void LaunchThread()
{
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
    
    int     threadError = pthread_create(&posixThreadID, &attr, &PosixThreadMainRoutine, NULL);
    
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
        // Report an error.
    }
}




void display(void)
{
    usleep(11000
           
           );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    
    // take care of the physics
    while (physicsactual < physicsgoal) {physicsloop(); 
        
        
        for (int ctr = 0; ctr < 10; ctr++)
		spawnenemy(physicsactual);
		physicsactual++;}
    
    light2();
    
    stuff();
    glShadeModel( GL_SMOOTH );    
    glutSwapBuffers();
}




void reshape2()
{ 
    
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
    //
    gluPerspective(60.0f, 800.0/560.0, 0.1f, 100.0f);
    //glDepthFunc(GL_GREATER);
//    glDepthRange(100, -100
//                 
//                 
//                 ); 
    
    glDepthRange(0.1
                 
                 , 100
                 
                 
                 
                 
                 ); 
    
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
}

void idle(void)
{
    glutPostRedisplay();
}



void reshape(int width, int height)
{
    glViewport(0, 0, width, height);
    reshape2();
}



void key(unsigned char inkey, int px, int py)
{
    if (inkey==27) exit(0);
    
    if (inkey=='s' || inkey=='S') rightkeydown=1;
    if (inkey=='a' || inkey=='A') leftkeydown=1;
    
    if (inkey=='p' || inkey=='P') {
        
        if (gamestate == ACTION) gamestate = PAUSED;
        else if (gamestate == PAUSED) gamestate = ACTION;
    }
    
    
    
    if (inkey==13)
    {
        
        if (gamestate == INSTRUCTIONS) {gamestate = GAMEMENU; return;}
        if (gamestate == YOULOSE || gamestate == YOUWIN) {reseteverything(); return;}
        if (gamestate != GAMEMENU) return;
        if (menusel == PLAY) gamestate = ACTION;             
        if (menusel == INFO) gamestate = INSTRUCTIONS;
        if (menusel == EXITGAME)    exit(0);
    }
    
    if (inkey=='z' || inkey=='Z') missilekeydown=1;
}


void stuff(void)
{
    glClearColor (1.0f, 0.0f, 0.0f, 0.0f);
    glClear (GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glLoadIdentity();
    
    if (gamestate == GAMEMENU) {drawgamemenu(); //Sleep(20);
        
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
    
    
    if (gamestate == ACTION)
    {
        // take care of the physics
        while (physicsactual < physicsgoal) {physicsloop(); 
            spawnenemy(physicsactual);
            physicsactual++;}
        
        if (health == 0) gamestate = YOULOSE;
        if (physicsactual > 43250) gamestate = YOUWIN;
    }
    
    
}



void keyUp(unsigned char inkey, int px, int py)
{
    if (inkey=='s' || inkey=='S') rightkeydown=0;
    if (inkey=='a' || inkey=='A') leftkeydown=0;
    if (inkey=='z' || inkey=='Z') missilekeydown=0;
}


void specialup(int key, int x, int y)
{
    if (key==GLUT_KEY_RIGHT || key==GLUT_KEY_RIGHT) rightkeydown=0;
    if (key==GLUT_KEY_LEFT || key==GLUT_KEY_LEFT ) leftkeydown=0;
    
}


void specialdown(int key, int x, int y)
{
    if (key==GLUT_KEY_RIGHT || key==GLUT_KEY_RIGHT) rightkeydown=1;
    if (key==GLUT_KEY_LEFT || key==GLUT_KEY_LEFT ) leftkeydown=1;  
    
    
    if (key==GLUT_KEY_UP)
    {
        if (gamestate != GAMEMENU) return;
        if (menusel == PLAY) menusel = EXITGAME;
        else if (menusel == INFO) menusel = PLAY;
        else if (menusel == EXITGAME) menusel = INFO;
        //return 0;
        
    }
    
    
    if (key==GLUT_KEY_DOWN)
    {
        if (gamestate != GAMEMENU) return;
        if (menusel == PLAY) menusel = INFO;
        else if (menusel == INFO) menusel = EXITGAME;
        else if (menusel == EXITGAME) menusel = PLAY;
      //  return 0;
        
    }
    
    
    
    
    
    
    
    
}

int main(int argc, char *argv[])
{
    NSURL *leverSoundURL   = [[NSBundle mainBundle] URLForResource: @"explosion"
                                                     withExtension: @"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)leverSoundURL, &explosion_sound_id);
    AudioServicesPlaySystemSound(explosion_sound_id);
    
    glutInit(&argc, argv);
    //glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);
 //   glutInitDisplayString(" rgba double depth>=32 samples");
       glutInitDisplayMode(GLUT_RGBA | GLUT_SINGLE | GLUT_DEPTH);
    //glutInitWindowSize(1280, 1000);
    glutInitWindowSize(1280, 800);
    explosion = [NSSound soundNamed:@"explosion"];
    glutCreateWindow("UFO Invasion");
    glutFullScreen();
    skycube = new Skycube();
    nf = new Newfont("myfont.obj", "myfont.mtl", 1);  
    
    LaunchThread();
    
    glutKeyboardFunc (key);
    glutKeyboardUpFunc (keyUp);
    glutSpecialFunc(specialdown);
    glutSpecialUpFunc(specialup);
    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutIdleFunc(idle);
    
    GLint double_buffered;
    glGetIntegerv(GL_DOUBLEBUFFER, &double_buffered);
    printf("bah %d", double_buffered);

    
    glutMainLoop();
    return EXIT_SUCCESS;
}
