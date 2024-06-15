float speed = 10.0;

void setup() {
    print("setup");
    noFill();
}

void render(float r) {
    background(0);

    translate(width/2, height/2);

    stroke(255);
    fill(255, 0, 0);
    rect(cos(r)*width*0.25, sin(r)*width*0.25, 50, 50);
}
