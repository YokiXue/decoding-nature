//Producer //<>//

class Cactus extends Template {
  Cactus(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    //set the life span

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); 
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);
    setLifetime(lifetime*7);//shortest
    setMaxspeed(speed*0.5);//slowest-almost static
    setSize(size*30);
    health = 100;

    maxLifetime=getLifetime();
    maxSize = getSize();
    maxHealth = health;


    breedProbability = 0.004;
  }


    void display() {
    noStroke();
    float alpha = map(health, 0, maxHealth, 100, 255);//transparency
    r=map(lifetime, maxLifetime, 0, 0, 2*maxSize);
    if (r>maxSize) {
      r = maxSize;
    }

    fill(0, 0, 180, alpha);
    strokeWeight(1);
    pushMatrix();
    translate(position.x, position.y);
    image(c, r,r+200,r*1.77,r*1.75);//only display in the lower area
    fill(col);
    popMatrix();
  }

 
    Cactus breed() {
    if (r==maxSize&&random(1) < breedProbability) {
      DNA childDNA = dna.dnaCopy();
      childDNA.mutate(0.01); //DNA mutates
      PVector childPosition = new PVector(random(position.x-100, position.x+100), 
        random(position.y-100, position.y+100));
      return new Cactus(childPosition, childDNA);
    } else {
      return null;
    }
  }

  //MOVEMENT
    void move() {
    float vx = map(noise(xoff), 0, 1, -maxspeed, maxspeed);
    float vy = map(noise(yoff), 0, 1, -maxspeed, maxspeed);
    velocity = new PVector(vx, vy); //random velocity
    xoff += 0.01;
    yoff += 0.01;

    velocity.add(acceleration); //ACCELERATION
    velocity.limit(maxspeed);   //set maximum speed
    //println(velocity);
    position.add(velocity);  //velocity

    acceleration.mult(0);    //zero acceleration at the end of each move
  }

  //determine death
    boolean dead() {
    if (lifetime<0.0 || health<0.0) {
      return true;
    } else {
      return false;
    }
  }
}
