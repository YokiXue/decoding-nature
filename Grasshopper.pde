//Primary consumer--herbivore

class Grasshopper extends Template {
  Grasshopper(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    health = 100;
    maxHealth = 100;

    breedProbability = 0.01;//higher than hawk's
    matingProbability = 0.01;

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1);
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);

    //Set up the life span
    setLifetime(lifetime*50); //shorter than Hawk's
    setMaxspeed(speed*5);  //slower than hawk's
    setSize(size*50);   //smaller than hawk's

    maxLifetime=getLifetime();
    maxSize = getSize();


    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    velocity = velocity.limit(maxspeed);

    //  //determine the gender in a binary way
    if (random(0, 1)<= 0.5) {
      gender = true;
    } else {
      gender = false;
    }
    //different colors for two genders
    if (gender) {
      col = color(255, 0, 0);
    } else {
      col = color(0, 255, 0);
    }

   //assign the weight coefficients for different behaviors
    separateWeight = 1;
    alignWeight = 2;
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

    health -= 0.15; 
    lifetime-=0.03;

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
   image(g, r,r,r/1.2,r/1.2);
    fill(col);
    popMatrix();
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

  //AVOIDING HAWKS
  void moveElude(ArrayList<Hawk> hawks) {
    PVector elu = elude(hawks);
    elu.mult(10);
    applyForce(elu);
  }

  //Eluding
  PVector elude(ArrayList<Hawk> hawks) {
    float neighbordist = r * 10;
    for (Hawk f:hawks) {
      //Comparing
      PVector comparison = PVector.sub(f.position, position);
      //Distance
      float d = PVector.dist(position, f.position);
      //Angle
      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d < neighbordist)) {
        PVector result = seek(f.position);
        result = new PVector(-result.x, -result.y);
        return result;
      }
    }
    return new PVector(0, 0);
  }


    Grasshopper breed() {
    if (isPregnancy && random(1) < breedProbability) {
      DNA childDNA = dna.dnaCross(fatherDNA);
      childDNA.mutate(0.01); //DNA mutates
      return new Grasshopper(position, childDNA);
    } else {
      return null;
    }
  }

  //MOVEMENT
    void move() {
    velocity.add(acceleration); //acceleration
    velocity.limit(maxspeed);   //set maximum speed
    position.add(velocity);  //velocity
    acceleration.mult(0);    //zero acceleration at the end of each move
  }

  //Alignment
    //add view angle
    PVector align (ArrayList<? extends Template> creatures) {
    float neighbordist = size * 2;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Template other : creatures) {
      //Comparing
      PVector comparison = PVector.sub(other.position, position);
      //distance
      float d = PVector.dist(position, other.position);
      //angle
      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  //EAT THE CACTUS
  void eat(ArrayList<Cactus> cactuses) {
    if (health<100) {
      for (Cactus p : cactuses) {
        float d = PVector.dist(position, p.position);
        if (d<r) {
          p.health-=5;
          health+=1;
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
