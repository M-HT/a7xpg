/*
 * $Id: Rand.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.Rand;

import std.random;

/**
 * Random number generator.
 */
public class Rand {
  private Random rnd;

  public this() {
    rnd = Random(unpredictableSeed);
  }

  public int nextInt(int n) {
    return uniform(0, n, rnd);
  }

  public int nextSignedInt(int n) {
    return uniform(-n, n, rnd);
  }

  public float nextFloat(float n) {
    return (cast(float)uniform(0, n * 10000, rnd)) / 10000;
  }
}
