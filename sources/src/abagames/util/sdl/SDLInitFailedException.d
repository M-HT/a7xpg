/*
 * $Id: SDLInitFailedException.d,v 1.1.1.1 2003/09/19 14:55:49 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.SDLInitFailedException;

/**
 * SDL initialize failed.
 */
public class SDLInitFailedException: Exception {
  public this(char[] msg) {
    super(msg);
  }
}
