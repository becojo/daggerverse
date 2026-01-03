///////////////////////////////////////////////////////////////////////////////
int frames = 60;           // number of frames per period
float period = TWO_PI;     // animation cycle length (TWO_PI, 1)
boolean preload = false;   // warmup run before recording
String mode = P2D;         // renderer either P2D or P3D
///////////////////////////////////////////////////////////////////////////////

void setup() {
    print("setup");
    if(!record) frameRate(25);
}

void render(float r) {
    background(0);

    translate(width/2, height/2);

    float xy = map2(sin(r)/4, -1, 1, -width, width, QUADRATIC, EASE_IN_OUT);
    fill(255, 150);
    rect(xy, xy, 50, 50);


    fill(255, 0, 0);
    ellipse(cos(r)*width/4, sin(r)*width/4, 50, 50);
}
