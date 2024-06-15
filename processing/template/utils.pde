boolean record = false;
int seed = 0;
boolean preload = false;

String renderer() {
    String RENDERER = System.getenv("RENDERER");

    if(RENDERER == null) {
        return P2D;
    }

    if(RENDERER.equals("P3D")) {
        return P3D;
    } else {
        return P2D;
    }
}

void settings() {
    println("settings");

    String WIDTH = System.getenv("WIDTH");
    String HEIGHT = System.getenv("HEIGHT");

    if(WIDTH == null || HEIGHT == null) {
        size(500, 500, renderer());
        println("size: 500x500");
    } else {
        size(int(WIDTH), int(HEIGHT), renderer());
        println("size: ", WIDTH, HEIGHT);
    }
    if(System.getenv("SEED") != null) {
        seed = int(System.getenv("SEED"));
        _setSeed(seed);
    } else {
        _setSeed(0);
    }

    if(System.getenv("RECORD") != null){
        println("recording: true");
        record = true;
    }
}

void draw() {
    float r = frameCount / speed;
    render(r);
    _save(r);
}

void _save(float r) {
    if(record && !preload) {
        int progress = int(map(r, 0, TWO_PI, 0, 100));
        if(progress % 5 == 0) {
            print("\rprogress:", progress, "%");
        }

        saveFrame("frame-########.png");
    }

    if(record && r > TWO_PI && !preload) {
        exit();
        return;
    }

    if(record && r > TWO_PI && preload) {
        if(r > TWO_PI * 2) {
             exit();
             return;
        }

        int progress = int(map(r, TWO_PI, TWO_PI*2, 0, 100));
        if(progress % 5 == 0) {
            print("\rprogress:", progress, "%");
        }

        saveFrame("frame-########.png");
    }

    if(keyPressed && key == 'q') {
        exit();
    }

    if(keyPressed && key == 'r') {
        _setSeed(0);
    }
}


void _setSeed(int s) {
    if (s == 0) {
        seed = int(random(999999999));
    } else {
        seed = s;
    }

    noiseSeed(seed);
    randomSeed(seed);
    frameCount = 0;

    println("seed: ", seed);
}
