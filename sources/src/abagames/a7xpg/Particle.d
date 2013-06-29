/*
 * $Id: Particle.d,v 1.2 2003/09/21 04:01:27 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Particle;

import std.math;
import opengl;
import abagames.util.Vector;
import abagames.util.Rand;
import abagames.util.Actor;
import abagames.a7xpg.LuminousActor;
import abagames.a7xpg.Field;
import abagames.a7xpg.A7xScreen;

/**
 * Particles.
 */
public class Particle: LuminousActor {
 private:
  static const float GRAVITY = 0.2;
  Field field;
  Rand rand;
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
    A7xScreen.setColor(r, g, b, 1);
    glVertex3f(ppos.x, ppos.y, pz);
    glVertex3f(pos.x, pos.y, z);
    A7xScreen.setColor(r, g, b, 0.7);
    glVertex3f(ppos.x, ppos.y, -pz);
    glVertex3f(pos.x, pos.y, -z);
  }

  public override void drawLuminous() {
    if (lumAlp < 0.2) return;
    A7xScreen.setColor(r, g, b, lumAlp);
    glVertex3f(ppos.x, ppos.y, pz);
    glVertex3f(pos.x, pos.y, z);
  }
}

public class ParticleInitializer: ActorInitializer {
 public:
  Field field;
  Rand rand;

  public this(Field field, Rand rand) {
    this.field = field;
    this.rand = rand;
  }
}
