boolean record = false;
int seed = 0;

String getSetting(String key, String defaultValue) {
    String value = System.getenv(key);

    if(value == null || value.equals("")) {
        return defaultValue;
    } else {
        return value;
    }
}

void settings() {
    println("settings");

    String WIDTH = getSetting("WIDTH", "500");
    String HEIGHT = getSetting("HEIGHT", "500");
    String SEED = getSetting("SEED", "0");
    String RENDERER = P2D;

    if(getSetting("RENDERER", "P2D").equals("P3D")) {
        RENDERER = P3D;
    }

    size(int(WIDTH), int(HEIGHT), RENDERER);
    println("size: ", WIDTH, "x", HEIGHT);

    _setSeed(int(SEED));

    if(System.getenv("RECORD") != null) {
        println("recording: true");
        record = true;
    }
}

void draw() {
    float r = (float(frameCount - 1) / frames) * period;
    render(r);
    _record(r);
    _ui();
}

void _ui() {
    if(keyPressed && key == 'q') {
        exit();
    }

    if(keyPressed && key == 'r') {
        _setSeed(0);
    }
}

void _record(float r) {
    if(!record) {  
        return; 
    }

    int start = 0;
    int end = frames;

    if(preload) {
        start = frames + 1;
        end = frames * 2;
    }

    end += (periods - 1) * frames;

    if(frameCount >= start) {
        int progress = int(map(frameCount, start, end, 0, 100));
        if(progress % 5 == 0) {
            print("\rprogress:", progress, "%");
        }

        saveFrame("frame-########.png");
    }

    if(frameCount >= end) {
        exit();
        return;
    }
}

void _setSeed(int s) {
    if (s == 0) {
        seed = int(random(999999999));
    } else {
        seed = s;
    }

    println("seed: ", seed);
    noiseSeed(seed);
    randomSeed(seed);
    frameCount = 0;
}

// https://github.com/sighack/easing-functions/blob/1016fc1ff73d293959c90e4ce545017e36b869b6/code/easing/easing.pde
// MIT License Copyright (c) 2018 sighack

/* The map2() function supports the following easing types */
final int LINEAR = 0;
final int QUADRATIC = 1;
final int CUBIC = 2;
final int QUARTIC = 3;
final int QUINTIC = 4;
final int SINUSOIDAL = 5;
final int EXPONENTIAL = 6;
final int CIRCULAR = 7;
final int SQRT = 8;

/* When the easing is applied (in, out, or both) */
final int EASE_IN = 0;
final int EASE_OUT = 1;
final int EASE_IN_OUT = 2;

/*
 * A map() replacement that allows for specifying easing curves
 * with arbitrary exponents.
 *
 * value :   The value to map
 * start1:   The lower limit of the input range
 * stop1 :   The upper limit of the input range
 * start2:   The lower limit of the output range
 * stop2 :   The upper limit of the output range
 * type  :   The type of easing (see above)
 * when  :   One of EASE_IN, EASE_OUT, or EASE_IN_OUT
 */
float map2(float value, float start1, float stop1, float start2, float stop2, int type, int when) {
  float b = start2;
  float c = stop2 - start2;
  float t = value - start1;
  float d = stop1 - start1;
  float p = 0.5;
  switch (type) {
  case LINEAR:
    return c*t/d + b;
  case SQRT:
    if (when == EASE_IN) {
      t /= d;
      return c*pow(t, p) + b;
    } else if (when == EASE_OUT) {
      t /= d;
      return c * (1 - pow(1 - t, p)) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*pow(t, p) + b;
      return c/2 * (2 - pow(2 - t, p)) + b;
    }
    break;
  case QUADRATIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      return -c * t*(t-2) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t + b;
      t--;
      return -c/2 * (t*(t-2) - 1) + b;
    }
    break;
  case CUBIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return c*(t*t*t + 1) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t*t + b;
      t -= 2;
      return c/2*(t*t*t + 2) + b;
    }
    break;
  case QUARTIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return -c * (t*t*t*t - 1) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t*t*t + b;
      t -= 2;
      return -c/2 * (t*t*t*t - 2) + b;
    }
    break;
  case QUINTIC:
    if (when == EASE_IN) {
      t /= d;
      return c*t*t*t*t*t + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return c*(t*t*t*t*t + 1) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2*t*t*t*t*t + b;
      t -= 2;
      return c/2*(t*t*t*t*t + 2) + b;
    }
    break;
  case SINUSOIDAL:
    if (when == EASE_IN) {
      return -c * cos(t/d * (PI/2)) + c + b;
    } else if (when == EASE_OUT) {
      return c * sin(t/d * (PI/2)) + b;
    } else if (when == EASE_IN_OUT) {
      return -c/2 * (cos(PI*t/d) - 1) + b;
    }
    break;
  case EXPONENTIAL:
    if (when == EASE_IN) {
      return c * pow( 2, 10 * (t/d - 1) ) + b;
    } else if (when == EASE_OUT) {
      return c * ( -pow( 2, -10 * t/d ) + 1 ) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return c/2 * pow( 2, 10 * (t - 1) ) + b;
      t--;
      return c/2 * ( -pow( 2, -10 * t) + 2 ) + b;
    }
    break;
  case CIRCULAR:
    if (when == EASE_IN) {
      t /= d;
      return -c * (sqrt(1 - t*t) - 1) + b;
    } else if (when == EASE_OUT) {
      t /= d;
      t--;
      return c * sqrt(1 - t*t) + b;
    } else if (when == EASE_IN_OUT) {
      t /= d/2;
      if (t < 1) return -c/2 * (sqrt(1 - t*t) - 1) + b;
      t -= 2;
      return c/2 * (sqrt(1 - t*t) + 1) + b;
    }
    break;
  };
  return 0;
}

/*
 * A map() replacement that allows for specifying easing curves
 * with arbitrary exponents.
 *
 * value :   The value to map
 * start1:   The lower limit of the input range
 * stop1 :   The upper limit of the input range
 * start2:   The lower limit of the output range
 * stop2 :   The upper limit of the output range
 * v     :   The exponent value (e.g., 0.5, 0.1, 0.3)
 * when  :   One of EASE_IN, EASE_OUT, or EASE_IN_OUT
 */
float map3(float value, float start1, float stop1, float start2, float stop2, float v, int when) {
  float b = start2;
  float c = stop2 - start2;
  float t = value - start1;
  float d = stop1 - start1;
  float p = v;
  float out = 0;
  if (when == EASE_IN) {
    t /= d;
    out = c*pow(t, p) + b;
  } else if (when == EASE_OUT) {
    t /= d;
    out = c * (1 - pow(1 - t, p)) + b;
  } else if (when == EASE_IN_OUT) {
    t /= d/2;
    if (t < 1) return c/2*pow(t, p) + b;
    out = c/2 * (2 - pow(2 - t, p)) + b;
  }
  return out;
}
