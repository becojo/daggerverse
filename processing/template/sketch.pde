///////////////////////////////////////////////////////////////////////////////////
int frames = 30;           // number of frames per period
float period = TWO_PI;     // period of the animation
boolean preload = false;   // run the sketch for 1 period before starting to record
///////////////////////////////////////////////////////////////////////////////////

void setup() {
    print("setup");
}

void render(float r) {
    background(0);

    translate(width/2, height/2);

    stroke(255);
    fill(255, 0, 0);
    ellipse(cos(r)*width*0.25, sin(r)*width*0.25, 50, 50);
}
