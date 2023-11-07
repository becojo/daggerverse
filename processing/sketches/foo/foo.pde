void setup() {
    String WIDTH = System.getenv("WIDTH");
    String HEIGHT = System.getenv("HEIGHT");
    size(int(WIDTH), int(HEIGHT));

    textSize(20);
    textAlign(CENTER, CENTER);
}


void draw() {
    background(int(random(255)), 0, 0);
    fill(255);

    text("DAGGER", width/2, height/2);

    saveFrame("frame-########.png");

    if(frameCount > 10) {
        exit();
    }
}
