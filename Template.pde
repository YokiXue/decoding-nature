class Template {

  PVector position;
  PVector acceleration;
  PVector velocity;

  float lifetime;
  float maxspeed;
  float maxforce;
  float size;
  float r;            //size of the visual

  float maxLifetime; //maximum life and size of all creatures
  float maxSize;     
  float health;      //vital index
  float maxHealth;

  DNA dna;          
  DNA fatherDNA;

  //set weight coefficients for different behaviors
  float separateWeight;
  float cohesionWeight;
  float alignWeight;

  float breedProbability;
  float matingProbability;

  float xoff;
  float yoff;  //control random movement speed

  float periphery = PI/2; //view

  Boolean gender;
  Boolean isRut;   //rut status
  Boolean isPregnancy; //pregnancy status

  color col;      //color 

  Template(PVector pos, DNA initDNA) {
    position=pos.copy();
    dna = initDNA;

    lifetime = map(dna.genes.get("lifetime"), 0, 1, 0, 1);
    maxspeed = map(dna.genes.get("speed"), 0, 1, 0, 1);
    size = map(dna.genes.get("size"), 0, 1, 0, 1);

    maxforce = 0.05;
    breedProbability = 0.005;
    alignWeight = 1;
    separateWeight = 1;
    cohesionWeight = 1;

    xoff = random(1000);
    yoff = random(1000);
    float vx = map(noise(xoff), 0, 1, -maxspeed, maxspeed);
    float vy = map(noise(yoff), 0, 1, -maxspeed, maxspeed);
    velocity = new PVector(vx, vy);

    //initial acceleration
    acceleration = new PVector(0, 0);

    //initial rut status is off
    isRut = false;
    isPregnancy = false;
  }

  //Update
  void update() {
    move();
    borders();
    display();

    lifetime-=0.01;
  }

  //MOVEMENT
  void move() {
    velocity.add(acceleration); //acceleration
    velocity.limit(maxspeed);   //set maximum speed
    position.add(velocity);  //velocity
    acceleration.mult(0);    //zero acceleration at the end of each move
  }

  //VISUALS
  void display() {
    ellipseMode(CENTER);
    stroke(0);
    fill(0, lifetime);
    ellipse(position.x, position.y, r, r);
  }
  
  //forces to adjust acceleration
  void applyForce(PVector force) {
    acceleration.add(force);
  }

// Three flocking rules
// Separate to avoid collision
// Align steering force with neighbor
// Cohesion move toward the center of the neighborhood (stay in the group)
  void flock(ArrayList<? extends Template> Creatures) {

    PVector sep = separate(Creatures);   // Separation
    PVector ali = align(Creatures);      // Alignment
    PVector coh = cohesion(Creatures);   // Cohesion

    sep.mult(separateWeight);
    ali.mult(alignWeight);
    coh.mult(cohesionWeight);

    // add force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  //SEEK
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  
    // a vector pointing from the position to the target
    // normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    //Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // limit to maximum steering force
    return steer;
  }

  // Cohesion
  PVector cohesion (ArrayList<? extends Template> creatures) {
    float neighbordist = r * 5; //view
    PVector sum = new PVector(0, 0);   // start with empty vector to accumulate all positions
    int count = 0;
    for (Template other : creatures) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); //add the positions of other objects
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  //the average coordinate of the neighbor
    } else {
      return new PVector(0, 0);
    }
  }

  //SEPERATION
  PVector separate (ArrayList<? extends Template> creatures) {
    float desiredseparation = r*1.5; //view
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // for every boid in the system, check if it's too close
    for (Template other : creatures) {
      float d = PVector.dist(position, other.position);
      // if the distance is greater than 0 and less than an arbitrary amount (0 when alone)
      if ((d > 0) && (d < desiredseparation)) {
        //calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // weight by distance
        steer.add(diff);
        count++;            // keep track of how many
      }
    }
    // Average-divide by number
    if (count > 0) {
      steer.div((float)count);
    }

    // as long as the vector is greater than 0
    if (steer.mag() > 0) {
      //implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  //ALIGNMENT
  PVector align (ArrayList<? extends Template> creatures) {
    float neighbordist = r * 3;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Template other : creatures) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
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

  //rut status
  void rut() {
    if (r >= maxSize && health>maxHealth/2) {
      if (!isRut && !isPregnancy) {
        if (random(1)<matingProbability) {
          isRut = true;
          if (gender) {
            col = color(100, 0, 0);
          } else {
            col = color(0, 100, 0);
          }
        }
      }
    }
  }

  //MATING
  PVector mating(ArrayList<? extends Template> creatures) {
    float neighbordist = r * 15;
    if (isRut) {
      for (Template other : creatures) {
        if (other.isRut && gender != other.gender) {
          //both are in rut and of different genders
          //distance
          float d = PVector.dist(position, other.position);
          if ( (d < neighbordist) && (d>r)) {
            return seek(other.position);
          } else if (d<r) { //when close enough
            isRut = false;
            other.isRut = false;
            if (gender) {
              col = color(255, 0, 0);
              other.col = color(0, 255, 0);

              isPregnancy = true;
              fatherDNA = other.dna;
            } else {
              col = color(0, 255, 0);
              other.col = color(255, 0, 0);

              other.isPregnancy = true;
              other.fatherDNA = dna;
            }
          }
        }
      }
    }
    return new PVector(0, 0);
  }

  //FORAGING
  PVector foraging(ArrayList<? extends Template> creatures) {
    float neighbordist = r * 10;
    for (Template c:creatures) {
      PVector comparison = PVector.sub(c.position, position);
      //distance
      float d = PVector.dist(position, c.position);
      //angle
      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d < neighbordist)) {
        return seek(c.position);
      }
    }
    return new PVector(0, 0);
  }


  //BREEDING
  public Template  breed() {
    return null;
  };

  //set borders
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  //determine death
  boolean dead() {
    if (lifetime<0.0) {
      return true;
    } else {
      return false;
    }
  }


  public float getLifetime() {
    return lifetime;
  }

  public void setLifetime(float lifetime) {
    this.lifetime=lifetime;
  }

  public float getMaxspeed() {
    return maxspeed;
  }

  public void setMaxspeed(float speed) {
    maxspeed=speed;
  }

  public float getSize() {
    return size;
  }

  public void setSize(float size) {
    this.size=size;
  }

}
