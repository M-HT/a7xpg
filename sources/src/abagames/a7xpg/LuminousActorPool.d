/*
 * $Id: LuminousActorPool.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.a7xpg.LuminousActorPool;

import abagames.util.Actor;
import abagames.util.ActorPool;
import abagames.util.ActorInitializer;
import abagames.a7xpg.LuminousActor;

/**
 * Actor pool for the LuminousActor.
 */
public class LuminousActorPool: ActorPool {
  public this(int n, Actor act, ActorInitializer ini) {
    super(n, act, ini);
  }

  public void drawLuminous() {
    for (int i = 0; i < actor.length; i++) {
      if (actor[i].isExist)
	(cast(LuminousActor) actor[i]).drawLuminous();
    }
  }
}
