// If the the sketch is being recorded
boolean record = false;

// The random seed used for noise() and random()
int seed = 0;

// Number of periods to run
int _periods = 0;

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

    _periods = int(getSetting("PERIODS", "0"));

    size(int(WIDTH), int(HEIGHT), mode);
    println("size: ", WIDTH, "x", HEIGHT);

    _setSeed(int(SEED));

    if(System.getenv("RECORD") != null) {
        println("recording: true");
        record = true;
    }

    if(record && _periods == 0) {
      _periods = 1;
    }

    if (_periods > 0) {
      println("periods: ", _periods);
    }
}

void draw() {
    float p = float(frameCount - 1) / frames;
    float r = p * period;
    render(r);
    _record(r);
    _ui();

    if(!record && _periods > 0 && int(p) >= _periods) {
      exit();
    }
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

    end += (_periods - 1) * frames;

    if(frameCount >= start) {
        int progress = int(map(frameCount, start, end, 0, 100));
        if(progress % 5 == 0) {
            print("\rprogress:", progress, "% ");
        }

        if(record) {
          saveFrame("frame-########.png");
        }
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

void outputFrame() {
  saveFrame(String.format("output/frame_%dx%d_%s.png", width, height, seed));
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


/**
 * Draws a radial gradient using a triangle fan.
 * @param cx The x-coordinate of the center of the gradient.
 * @param cy The y-coordinate of the center of the gradient.
 * @param radiusX The horizontal radius of the gradient.
 * @param radiusY The vertical radius of the gradient.
 * @param c The color at the center of the gradient.
 * @param c2 The color at the edges of the gradient.
 * @param steps The number of steps to create the gradient (higher values result in a smoother gradient).
 */
void ellipseGradient(float cx, float cy, float radiusX, float radiusY, color c, color c2, int steps) {
  noStroke();
  beginShape(TRIANGLE_FAN);

  fill(c, 255);   // center: opaque color
  vertex(cx, cy);

  fill(c2);     // edge: fully transparent
  for (int i = 0; i <= steps; i++) {
    float a = TWO_PI * i / steps;
    vertex(cx + cos(a) * radiusX, cy + sin(a) * radiusY);
  }

  endShape(CLOSE);
}

/**
 * Draws an ellipse mask that allows only the area inside the ellipse to be visible
 * up to the edges of the screen. Avoid translating before applying the mask.
 * @param cx The x-coordinate of the center of the ellipse.
 * @param cy The y-coordinate of the center of the ellipse.
 * @param radiusX The horizontal radius of the ellipse.
 * @param radiusY The vertical radius of the ellipse.
 */
void ellipseMask(float cx, float cy, float radiusX, float radiusY) {
  int steps = 72;
  beginShape();

  // Outer screen-sized rectangle in translated coordinates.
  vertex(-width, -height);
  vertex( width, -height);
  vertex( width,  height);
  vertex(-width,  height);

  // Circular hole so only inside the circle remains visible.
  beginContour();
  for (int i = steps; i >= 0; i--) {
    float a = TWO_PI * i / steps;
    vertex(cx + cos(a) * radiusX, cy + sin(a) * radiusY);
  }
  endContour();

  endShape(CLOSE);
}
