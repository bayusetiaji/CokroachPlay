ArrayList<Cokroach> coks;
PImage img;

boolean nightMode = true;

final int SWARM_SIZE = 14;
final int MAX_ROACHES = 400;
final float LIGHT_RADIUS = 240;

void setup() {
  // size(800, 800);
  fullScreen();
  smooth();
  frameRate(60);
  imageMode(CENTER);
  coks = new ArrayList<Cokroach>();
  img = loadImage("kecoa.png");
}

void draw() {
  for (Cokroach c : coks) {
    c.live();
  }

  if (nightMode) {
    drawNight();
  } else {
    drawDay();
  }

  // info
  if (nightMode) {
    fill(190, 205, 225, 190);
  } else {
    fill(60, 160);
  }
  textAlign(LEFT, BOTTOM);
  textSize(14);
  text("klik kiri: munculkan kawanan   •   klik kanan: bersihkan   •   N: ganti siang/malam   •   kecoa: " + coks.size(),
       24, height - 24);
}

void drawDay() {
  background(255);
  for (Cokroach c : coks) {
    c.displayBody();
  }
}

void drawNight() {
  background(8, 10, 16);
  drawLightGlow(mouseX, mouseY, LIGHT_RADIUS);
  for (Cokroach c : coks) {
    c.displayBody();
  }
}

// Soft flashlight glow that follows the cursor.
void drawLightGlow(float cx, float cy, float radius) {
  blendMode(ADD);
  noStroke();
  int layers = 18;
  for (int i = layers; i > 0; i--) {
    float d = radius * 2.0 * i / layers;
    fill(60, 85, 120, 9);
    ellipse(cx, cy, d, d);
  }
  blendMode(BLEND);
}

void keyPressed() {
  if (key == 'n' || key == 'N') {
    nightMode = !nightMode;
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    spawnSwarm(mouseX, mouseY);
  } else if (mouseButton == RIGHT) {
    coks.clear();
  }
}

// Spawn a small group of cockroaches around the click point.
void spawnSwarm(float x, float y) {
  for (int i = 0; i < SWARM_SIZE; i++) {
    coks.add(new Cokroach(img, x, y));
  }
  while (coks.size() > MAX_ROACHES) {
    coks.remove(0);
  }
}
