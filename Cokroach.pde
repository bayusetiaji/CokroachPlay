class Cokroach {
  Cokroach(PImage _img, float _x, float _y) {
    img = _img;

    // Scatter the swarm around the click point.
    pos = new PVector(_x + random(-22, 22), _y + random(-22, 22));

    float a = random(TWO_PI);
    cruise = random(1.2, 3.2);
    vel = new PVector(cos(a), sin(a)).mult(cruise);
    heading = a;

    bodyScale = random(0.55, 1.05);
    phase = random(TWO_PI);
    noiseSeed = random(10000);
  }

  void live() {
    float dx = pos.x - mouseX;
    float dy = pos.y - mouseY;
    float d = sqrt(dx * dx + dy * dy);

    updateReaction(d);

    if (reaction == FROZEN) {
      // Caught in the flashlight: freeze for a moment.
      vel.mult(0.5);
    } else {
      // Wander: slow, organic heading changes.
      float turn = (noise(noiseSeed + frameCount * 0.01) - 0.5) * 0.26;
      vel.rotate(turn);

      // Every now and then a roach darts in a new direction.
      if (random(1) < 0.004) {
        vel.rotate(random(-0.9, 0.9));
        cruise = random(1.2, 4.0);
      }

      // Scatter away from the cursor.
      if (reaction == PANIC) {
        // Bolt away after the freeze.
        if (d > 0.001) {
          vel.x += (dx / d) * 2.2;
          vel.y += (dy / d) * 2.2;
        }
      } else if (reaction == ESCAPE) {
        if (d > 0.001) {
          vel.x += (dx / d) * 1.2;
          vel.y += (dy / d) * 1.2;
        }
      } else if (d < FLEE_RADIUS && d > 0.001) {
        float force = map(d, 0, FLEE_RADIUS, 1.4, 0);
        vel.x += (dx / d) * force;
        vel.y += (dy / d) * force;
      }

      // Steer away from the screen edges before hitting them.
      float margin = 90;
      if (pos.x < margin)          vel.x += map(pos.x, 0, margin, 1.1, 0);
      if (pos.x > width - margin)  vel.x -= map(width - pos.x, 0, margin, 1.1, 0);
      if (pos.y < margin)          vel.y += map(pos.y, 0, margin, 1.1, 0);
      if (pos.y > height - margin) vel.y -= map(height - pos.y, 0, margin, 1.1, 0);

      // Settle back to a normal crawling speed.
      float sp = vel.mag();
      if (sp < 0.001) {
        vel.set(cruise, 0);
      } else {
        vel.mult(lerp(sp, cruise, 0.06) / sp);
      }

      float maxSpeed = (reaction == PANIC) ? cruise * 4.0 : cruise * 3.2;
      vel.limit(maxSpeed);
    }

    pos.add(vel);

    // Never let them leave the canvas.
    pos.x = constrain(pos.x, 8, width - 8);
    pos.y = constrain(pos.y, 8, height - 8);

    heading = atan2(vel.y, vel.x);
  }

  // React once per entry into the flashlight beam: freeze, then bolt.
  void updateReaction(float d) {
    if (!nightMode || d > LIGHT_RADIUS) {
      reaction = NORMAL;
      inBeam = false;
      return;
    }

    if (!inBeam && d < LIGHT_RADIUS * 0.75) {
      inBeam = true;
      reaction = FROZEN;
      reactionTimer = random(12, 30);
      return;
    }

    if (reaction == FROZEN) {
      reactionTimer--;
      if (reactionTimer <= 0) {
        reaction = PANIC;
        reactionTimer = random(30, 52);
      }
    } else if (reaction == PANIC) {
      reactionTimer--;
      if (reactionTimer <= 0) {
        reaction = ESCAPE;
      }
    }
  }

  void displayBody() {
    if (nightMode) {
      float d = dist(pos.x, pos.y, mouseX, mouseY);
      float a = constrain(map(d, 0, LIGHT_RADIUS * 1.8, 240, 110), 110, 240);
      tint(215, 230, 255, a);
    } else {
      noTint();
    }

    pushMatrix();
      // Slight shiver while frozen.
      float shiver = (reaction == FROZEN) ? 0.6 : 0;
      translate(pos.x + random(-shiver, shiver), pos.y + random(-shiver, shiver));
      rotate(heading + HALF_PI);
      float wobble = 1 + sin(frameCount * 0.9 + phase) * 0.03;
      scale(bodyScale * wobble, bodyScale);
      image(img, 0, 0);
    popMatrix();
  }

  static final int NORMAL = 0;
  static final int FROZEN = 1;
  static final int PANIC  = 2;
  static final int ESCAPE = 3;
  static final float FLEE_RADIUS = 110;

  PVector pos;
  PVector vel;
  PImage img;
  float heading;
  float cruise;
  float bodyScale;
  float phase;
  float noiseSeed;

  int reaction = NORMAL;
  float reactionTimer = 0;
  boolean inBeam = false;
}
