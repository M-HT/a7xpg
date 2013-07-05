/*
 * $Id: Particle.d,v 1.2 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Particle;

import std.math;
version (USE_GLES) {
  import opengles;
} else {
  import opengl;
}
import abagames.util.Vector;
import abagames.util.Rand;
import abagames.util.Actor;
import abagames.a7xpg.LuminousActor;
import abagames.a7xpg.Field;
import abagames.a7xpg.A7xScreen;

/**
 * Particles.
 */
public class ParticleDrawData {
 public:
  GLfloat[] vertices;
  GLfloat[] colors;

  public void clearData()
  {
    vertices = [];
    colors = [];
  }

  public void draw()
  {
    const int numVertices = cast(int)(colors.length / 4);

    if (numVertices > 0) {
      glEnableClientState(GL_VERTEX_ARRAY);
      glEnableClientState(GL_COLOR_ARRAY);

      glVertexPointer(3, GL_FLOAT, 0, cast(void *)(vertices.ptr));
      glColorPointer(4, GL_FLOAT, 0, cast(void *)(colors.ptr));
      glDrawArrays(GL_LINES, 0, numVertices);

      glDisableClientState(GL_COLOR_ARRAY);
      glDisableClientState(GL_VERTEX_ARRAY);
    }
  }
}

public class Particle: LuminousActor {
 private:
  static const float GRAVITY = 0.2;
  Field field;
  Rand rand;
  ParticleDrawData drawData;
  Vector pos, ppos;
  Vector vel;
  float z, mz, pz;
  float r, g, b;
  float lumAlp;
  int cnt;

  public override Actor newActor() {
    return new Particle;
  }

  public override void init(ActorInitializer ini) {
    ParticleInitializer pi = cast(ParticleInitializer) ini;
    field = pi.field;
    rand = pi.rand;
    drawData = pi.drawData;
    pos = new Vector;
    ppos = new Vector;
    vel = new Vector;
  }

  public void set(Vector p, float d, float ofs, float speed, float r, float g, float b) {
    pos.x = p.x + sin(d) * ofs;
    pos.y = p.y + cos(d) * ofs;
    z = 0.5;
    float sb = rand.nextFloat(0.5) + 0.75;
    vel.x = sin(d) * speed * sb;
    vel.y = cos(d) * speed * sb;
    mz = rand.nextFloat(1);
    this.r = r; this.g = g; this.b = b;
    cnt = 12 + rand.nextInt(48);
    lumAlp = 0.8 + rand.nextFloat(0.2);
    isExist = true;
  }

  public override void move() {
    cnt--;
    if (cnt < 0) {
      isExist = false;
      return;
    }
    ppos.x = pos.x; ppos.y = pos.y; pz = z;
    pos.add(vel);
    vel.mul(0.98);
    if (pos.x < -field.size.x || pos.x > field.size.x) {
      vel.x *= -0.9;
      pos.x += vel.x * 2;
    }
    if (pos.y < -field.size.y || pos.y > field.size.y) {
      vel.y *= -0.9;
      pos.y += vel.y * 2;
    }
    z += mz;
    mz -= GRAVITY;
    if (z < 0) {
      mz *= -0.5;
      vel.mul(0.8);
      z += mz * 2;
    }
    lumAlp *= 0.98;
  }

  public override void draw() {
    drawData.vertices ~= [
      ppos.x, ppos.y,  pz,
      pos.x , pos.y ,  z,
      ppos.x, ppos.y, -pz,
      pos.x , pos.y , -z
    ];
    drawData.colors ~= [
      r * A7xScreen.brightness, g * A7xScreen.brightness, b * A7xScreen.brightness, 1  ,
      r * A7xScreen.brightness, g * A7xScreen.brightness, b * A7xScreen.brightness, 1  ,
      r * A7xScreen.brightness, g * A7xScreen.brightness, b * A7xScreen.brightness, 0.7,
      r * A7xScreen.brightness, g * A7xScreen.brightness, b * A7xScreen.brightness, 0.7
    ];
  }

  public override void drawLuminous() {
    if (lumAlp < 0.2) return;

    drawData.vertices ~= [
      ppos.x, ppos.y, pz,
      pos.x , pos.y , z
    ];
    drawData.colors ~= [
      r * A7xScreen.brightness, g * A7xScreen.brightness, b * A7xScreen.brightness, lumAlp,
      r * A7xScreen.brightness, g * A7xScreen.brightness, b * A7xScreen.brightness, lumAlp
    ];
  }

}

public class ParticleInitializer: ActorInitializer {
 public:
  Field field;
  Rand rand;
  ParticleDrawData drawData;

  public this(Field field, Rand rand, ParticleDrawData drawData) {
    this.field = field;
    this.rand = rand;
    this.drawData = drawData;
  }
}
