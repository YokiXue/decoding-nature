//Secondary consumer carnivore


class Hawk extends Template {
  
  Hawk(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    health = 100;
    maxHealth = 100;

    breedProbability = 0.001;
    
    matingProbability = 0.01; 

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1);
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);

    //Set up the life span
    setLifetime(lifetime*100);
    setMaxspeed(speed*8);
    setSize(size*100);

    maxLifetime=getLifetime();
    maxSize = getSize();

    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    velocity = velocity.limit(maxspeed);
    
    //determine the gender in a binary way
    if (random(1)<0.5) {
      gender = true;
    } else {
      gender = false;
    }
    
    //different colors for two genders
    if (gender) {
      col = color(84, 48, 13);
    } else {
      col = color(140, 83, 28);
    }

    //assign the weight coefficients for different behaviors
    separateWeight = 2;
    alignWeight = 0;
    cohesionWeight = 0;

    //The estrus period is initially set to "off"
    isRut = false;
  }

  //Update
    void update() {
    rut();
    move();
    borders();
    display();

    health -= 0.1; 
    lifetime-=0.01;
    if (health<maxHealth/2) {
      isRut = false;
    }
  }

    void display() {
    r = map(lifetime, maxLifetime, 0, 0, 2*maxSize);
    if (r>=maxSize) {
      r = maxSize;
    }
    float theta = velocity.heading2D() + radians(90);
    float alpha = map(health, 0, maxHealth, 100, 255);
    //Transparency represents health status
    fill(col, alpha);
    strokeWeight(1);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    image(h, r,r,r*10,r*10);
    fill(col);
    popMatrix();
  }


    Hawk breed() {
    if (isPregnancy && random(1) < breedProbability) {
      DNA childDNA = dna.dnaCross(fatherDNA);
      childDNA.mutate(0.01); //DNA mutates
      return new Hawk(position, childDNA);
    } else {
      return null;
    }
  }

    void flock(ArrayList<? extends Template> Creatures) {
    if (isRut) {
      PVector mat = mating(Creatures);
      PVector sep = separate(Creatures);   // Separation
      PVector ali = align(Creatures);      // Alignment
      PVector coh = cohesion(Creatures);   // Cohesion

      mat.mult(5);
      sep.mult(separateWeight);
      ali.mult(alignWeight);
      coh.mult(cohesionWeight);

      applyForce(mat);
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    } else {
      PVector sep = separate(Creatures);   // Separation
      PVector ali = align(Creatures);      // Alignment
      PVector coh = cohesion(Creatures);   // Cohesion

      sep.mult(separateWeight);
      ali.mult(alignWeight);
      coh.mult(cohesionWeight);

      // add the force vectors to acceleration
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    }
  }

  //FORAGING on grasshopper
  void moveForaging(ArrayList<Grasshopper> grasshoppers) {
    PVector fora = foraging(grasshoppers);

    fora.mult(5);

    applyForce(fora);
  }

  //MOVEMENT
    void move() {
      
    //move Randomly
    velocity.add(acceleration); //acceleration
    velocity.limit(maxspeed);   //set maximum speed
    position.add(velocity);  //velocity
    acceleration.mult(0);    //zero acceleration at the end of each move

  }

  //EAT THE GRASSHOPPER
  void eat(ArrayList<Grasshopper> grasshoppers) {
    if (health<100) {
      for (Grasshopper f : grasshoppers) {
        float d = PVector.dist(position, f.position);
        if (d<r && r>f.r/2 &&f.r>r/6) {
          f.health-=100;
          health+=5;
          break;
        }
      }
    }
  }

  //Determine the death
    boolean dead() {
    if (lifetime<0.0 || health<0.0) {
      return true;
    } else {
      return false;
    }
  }
}
