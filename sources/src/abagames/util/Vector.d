/*
 * $Id: Vector.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.Vector;

import std.math;

/**
 * Vector.
 */
public class Vector {
 public:
  float x, y;

 private:

  public this() {}

  public this(float x, float y) {
    this.x = x; this.y = y;
  }

  public float innerProduct(Vector v) {
    return x * v.x + y * v.y;
  }

  public Vector getElement(Vector v) {
    Vector rsl;
    float ll = v.x * v.x + v.y * v.y;
    if (ll != 0) {
      float mag = innerProduct(v);
      rsl.x = mag * v.x / ll;
      rsl.y = mag * v.y / ll;
    } else {
      rsl.x = rsl.y = 0;
    }
    return rsl;
  }

  public void add(Vector v) {
    x += v.x;
    y += v.y;
  }

  public void sub(Vector v) {
    x -= v.x;
    y -= v.y;
  }

  public void mul(float a) {
    x *= a;
    y *= a;
  }

  public void div(float a) {
    x /= a;
    y /= a;
  }

  public int checkSide(Vector pos1, Vector pos2) {
    int xo = cast(int)(pos2.x - pos1.x);
    int yo = cast(int)(pos2.y - pos1.y);
    if (xo == 0) {
      if (yo == 0)
	return 0;
      return cast(int)(x - pos1.x);
    } else if (yo == 0) {
      return cast(int)(pos1.y - y);
    } else {
      if (xo * yo > 0) {
	return cast(int)((x - pos1.x) / xo - (y - pos1.y) / yo);
      } else {
	return cast(int)(-(x - pos1.x) / xo + (y - pos1.y) / yo);
      }
    }
  }

  public float size() {
    return sqrt(x * x + y * y);
  }

  public float dist(Vector v) {
    float ax = fabs(x - v.x);
    float ay = fabs(y - v.y);
    if ( ax > ay ) {
      return ax + ay / 2;
    } else {
      return ay + ax / 2;
    }
  }
}
