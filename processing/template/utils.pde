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
