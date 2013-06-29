/*
 * $Id: Bonus.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.Bonus;

import abagames.util.Vector;
import abagames.util.Actor;
import abagames.util.ActorInitializer;
import abagames.a7xpg.LetterRender;

/**
 * Bonus score indicators.
 */
public class Bonus: Actor {
 private:
  Vector pos;
  int cnt;
  float size;
  float my;
  int num;

  public override Actor newActor() {
    return new Bonus;
  }

  public override void init(ActorInitializer ini) {
    pos = new Vector;
  }

  public void set(int n, Vector p, float s) {
    num = n;
    int tn = n, dig;
    for (dig = 0; tn > 0; dig++)
      tn /= 10;
    pos.x = p.x - s / 2 * tn; pos.y = p.y;
    size = s;
    cnt = 32 + cast(int)(s * 24);
    my = 0.03 + s * 0.2;
    isExist = true;
  }

  public override void move() {
    cnt--;
    if (cnt <= 0) {
      isExist = false;
      return;
    }
    pos.y += my;
    my *= 0.95f;
  }

  public override void draw() {
    LetterRender.drawNumReverse(num, pos.x, pos.y, size);
  }
}

public class BonusInitializer: ActorInitializer {
}
