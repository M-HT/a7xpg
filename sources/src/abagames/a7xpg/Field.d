/*
 * $Id: Field.d,v 1.2 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Field;

version (USE_GLES) {
  import opengles;
} else {
  import opengl;
}
import abagames.util.Vector;
import abagames.a7xpg.A7xScreen;

/**
 * Stage field.
 */
public class Field {
 public:
  Vector size;
  float eyeZ;
  float eyeZa;
  float alpha;
 private:
  const float HEIGHT = 1;
  const float HEIGHT_OFFSET = 8;
  float z;
  float r, g, b;
  float lr, lg, lb;

  public void init() {
    size = new Vector;
    eyeZ = 0;
    alpha = 1;
  }

  private const float[][] COLOR =
    [[0.4, 0.8, 1], [0.4, 1, 0.8], [1, 0.8, 0.4]];
  private const float[][] LUMINOUS_COLOR =
    [[0.2, 0.2, 1], [0.2, 0.6, 0.7], [0.6, 0.2, 0.7]];

  public void start(int colorType) {
    if (size.x > size.y)
      eyeZa = size.x * 1.3;
    else
      eyeZa = size.y * 1.3 / 480 * 640;
    z = 0;
    r = COLOR[colorType % 3][0];
    g = COLOR[colorType % 3][1];
    b = COLOR[colorType % 3][2];
    lr = LUMINOUS_COLOR[colorType % 3][0];
    lg = LUMINOUS_COLOR[colorType % 3][1];
    lb = LUMINOUS_COLOR[colorType % 3][2];
  }

  public void addSpeed(float s) {
    z -= s;
    if (z < 0)
      z += HEIGHT_OFFSET;
  }

  public void move() {
    eyeZ += (eyeZa - eyeZ) * 0.06;
  }

  public void draw() {
    const int fieldNumVertices = 10;
    GLfloat[3*fieldNumVertices] fieldVertices;
    GLfloat[4*fieldNumVertices] fieldColors;

    foreach (i; 0..fieldNumVertices) {
      fieldColors[i*4 + 0] = r * A7xScreen.brightness;
      fieldColors[i*4 + 1] = g * A7xScreen.brightness;
      fieldColors[i*4 + 2] = b * A7xScreen.brightness;
      if ((i % 2) == 0) {
        fieldVertices[i*3 + 2] = 0;
        fieldColors[i*4 + 3] = 0.4;
      } else {
        fieldVertices[i*3 + 2] = HEIGHT;
        fieldColors[i*4 + 3] = 0.8;
      }
      if (i >= 2 && i <= 5)
        fieldVertices[i*3 + 0] = size.x;
      else
        fieldVertices[i*3 + 0] = -size.x;
      if (i >= 4 && i <= 7)
        fieldVertices[i*3 + 1] = size.y;
      else
        fieldVertices[i*3 + 1] = -size.y;
    }


    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(fieldVertices.ptr));
    glColorPointer(4, GL_FLOAT, 0, cast(void *)(fieldColors.ptr));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, fieldNumVertices);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
  }

  public void drawLuminous() {
    const int fieldNumVertices = 5;
    GLfloat[3*fieldNumVertices] fieldVertices;

    foreach (i; 0..fieldNumVertices) {
      fieldVertices[i*3 + 2] = HEIGHT;

      if (i >= 1 && i <= 2)
        fieldVertices[i*3 + 0] = size.x;
      else
        fieldVertices[i*3 + 0] = -size.x;
      if (i >= 2 && i <= 3)
        fieldVertices[i*3 + 1] = size.y;
      else
        fieldVertices[i*3 + 1] = -size.y;
    }

    glEnableClientState(GL_VERTEX_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, cast(void *)(fieldVertices.ptr));
    A7xScreen.setColor(lr, lg, lb, 0.9 * alpha);
    glDrawArrays(GL_LINE_STRIP, 0, fieldNumVertices);

    float hz = HEIGHT_OFFSET - z;
    foreach (j; 0..8) {
        foreach (i; 0..fieldNumVertices) {
          fieldVertices[i*3 + 2] = hz;
        }
        A7xScreen.setColor(lr, lg, lb, (0.8 - j * 0.05) * alpha);
        glDrawArrays(GL_LINE_STRIP, 0, fieldNumVertices);
        hz -= HEIGHT_OFFSET;
    }

    glDisableClientState(GL_VERTEX_ARRAY);
  }
}
