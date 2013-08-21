//
//  matrixlib.h
//  reversi2
//
//  Created by administrator a on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#pragma once

#include <cstdlib>
#include <iostream.h>
#include <math.h>

using namespace std;

struct Matrix
{
    float e[16];              
    
    inline float& operator[](int index) {return e[index];}
    inline const float& operator[](int index) const {return e[index];}
};

struct Vector
{
    float e[4];              
    
    inline float& operator[](int index) {return e[index];}
    inline const float& operator[](int index) const {return e[index];}
    
    Vector normalize(void)
    {
        float length = sqrt(e[0]*e[0] + e[1]*e[1] + e[2]*e[2]);
        e[0]/=length;
        e[1]/=length;
        e[2]/=length;
        return *this;
    }
    
};

ostream& operator<<(ostream& out, Matrix &m);
ostream& operator<<(ostream& out, Vector &v);

Matrix buildidentitymatrix(void);
Matrix buildrotationmatrix(float theta, float x, float y, float z);
Matrix buildscalematrix(float x, float y, float z);
Matrix buildtranslationmatrix(float x, float y, float z);

Vector buildvector(float x, float y, float z);

Matrix operator*(const Matrix &a, const Matrix &b);
void operator*=(Matrix &a, const Matrix &b);
Vector operator*(const Matrix &a, const Vector &v);
Vector operator/(const Vector &v, const float &f);

//ostream& operator<<(ostream& out, const Matrix &m)
//{
//    out << m[0] << " " << m[4] << " " <<  m[8] << " " <<  m[12] << endl;
//    out << m[1] << " " <<  m[5] << " " <<  m[9] << " " <<  m[13] << endl;
//    out << m[2] << " " <<  m[6] << " " <<  m[10] << " " <<  m[14] << endl;
//    out << m[3] << " " <<  m[7] << " " <<  m[11] << " " <<  m[15];
//    return out;         
//}
//
//ostream& operator<<(ostream& out, Vector &v)
//{
//    out << "(" << v[0] << ", " << v[1] << ", " <<  v[2] << ")";
//    return out;         
//}



