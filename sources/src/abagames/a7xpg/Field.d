/*
 * $Id: Field.d,v 1.2 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Field;

import opengl;
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
    glBegin(GL_TRIANGLE_STRIP);
    A7xScreen.setColor(r, g, b, 0.4);
    glVertex3f(-size.x, -size.y, 0);
    A7xScreen.setColor(r, g, b, 0.8);
    glVertex3f(-size.x, -size.y, HEIGHT);
    A7xScreen.setColor(r, g, b, 0.4);
    glVertex3f(size.x, -size.y, 0);
    A7xScreen.setColor(r, g, b, 0.8);
    glVertex3f(size.x, -size.y, HEIGHT);
    A7xScreen.setColor(r, g, b, 0.4);
    glVertex3f(size.x, size.y, 0);
    A7xScreen.setColor(r, g, b, 0.8);
    glVertex3f(size.x, size.y, HEIGHT);
    A7xScreen.setColor(r, g, b, 0.4);
    glVertex3f(-size.x, size.y, 0);
    A7xScreen.setColor(r, g, b, 0.8);
    glVertex3f(-size.x, size.y, HEIGHT);
    A7xScreen.setColor(r, g, b, 0.4);
    glVertex3f(-size.x, -size.y, 0);
    A7xScreen.setColor(r, g, b, 0.8);
    glVertex3f(-size.x, -size.y, HEIGHT);
    glEnd();
  }

  public void drawLuminous() {
    A7xScreen.setColor(lr, lg, lb, 0.9 * alpha);
    glBegin(GL_LINE_STRIP);
    glVertex3f(-size.x, -size.y, HEIGHT);
    glVertex3f(size.x, -size.y, HEIGHT);
    glVertex3f(size.x, size.y, HEIGHT);
    glVertex3f(-size.x, size.y, HEIGHT);
    glVertex3f(-size.x, -size.y, HEIGHT);
    glEnd();
    float hz = HEIGHT_OFFSET - z;
    for (int i = 0; i < 8; i++) {
      A7xScreen.setColor(lr, lg, lb, (0.8 - i * 0.05) * alpha);
      glBegin(GL_LINE_STRIP);
      glVertex3f(-size.x, -size.y, hz);
      glVertex3f(size.x, -size.y, hz);
      glVertex3f(size.x, size.y, hz);
      glVertex3f(-size.x, size.y, hz);
      glVertex3f(-size.x, -size.y, hz);
      glEnd();
      hz -= HEIGHT_OFFSET;
    }
  }
}
