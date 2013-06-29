/*
 * $Id: Logger.d,v 1.2 2003/09/20 04:04:06 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.Logger;

import std.stdio;

/**
 * Logger(error/info).
 */
public class Logger {
  public static void info(const char[] msg) {
    stderr.writeln("Info: " ~ msg);
  }

  public static void error(const char[] msg) {
    //stderr.writeLine("Error: " ~ msg);
    throw new Exception("Error: " ~ msg.idup ~ "\0");
  }

  public static void error(Exception e) {
    //stderr.writeLine("Error: " ~ e.toString());
    throw new Exception("Error: " ~ e.toString() ~ "\0");
  }

  public static void error(Error e) {
    //stderr.writeLine("Error: " ~ e.toString());
    //if (e.next)
    //  error(e.next);
    throw new Exception("Error: " ~ e.toString() ~ "\0");
  }
}
