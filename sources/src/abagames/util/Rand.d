/*
 * $Id: Rand.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.Rand;

import random;
import date;

/**
 * Random number generator.
 */
public class Rand {
  
  public this() {
    d_time timer = getUTCtime();
    rand_seed(timer, 0);   
  }

  public int nextInt(int n) {
    return random.rand() % n;
  }

  public int nextSignedInt(int n) {
    return random.rand() % (n * 2) - n;
  }

  public float nextFloat(float n) {
    return ((float)(random.rand() % (n * 10000))) / 10000;
  }
}
