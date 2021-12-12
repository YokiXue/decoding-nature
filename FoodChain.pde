class World {
  ArrayList<Grasshopper> grasshoppers;
  ArrayList<Cactus> cactuses;
  ArrayList<Hawk> hawks;

  World(int cactusesNum, int grasshopperNum, int hawkNum) {
    cactuses = new ArrayList<Cactus>();
    for (int i=0; i<cactusesNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      cactuses.add(new Cactus(pos, new DNA()));
    }

    grasshoppers = new ArrayList<Grasshopper>();
    for (int i=0; i<grasshopperNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      grasshoppers.add(new Grasshopper(pos, new DNA()));
    }

    hawks = new ArrayList<Hawk>();
    for (int i=0; i<hawkNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      hawks.add(new Hawk(pos, new DNA()));
    }
  }

  void update() {
    for (int i = cactuses.size()-1; i >= 0; i--) {
      Cactus p = cactuses.get(i);
      p.update();
      if (p.dead()) {
        cactuses.remove(i);
      }
      Cactus newP = p.breed();
      if (newP!=null) {
        cactuses.add(newP);
      }
    }


    for (Grasshopper f : grasshoppers) {
      f.flock(grasshoppers);
      f.moveElude(hawks);
    }
    for (int i = grasshoppers.size()-1; i >= 0; i--) {
      Grasshopper f = grasshoppers.get(i);
      f.update();
      f.eat(cactuses);
      if (f.dead()) {
        grasshoppers.remove(i);
      }
      Grasshopper newP = f.breed();
      if (newP!=null) {
        grasshoppers.add(newP);
      }
    }

    for (Hawk f : hawks) {
      f.flock(hawks);
      f.moveForaging(grasshoppers);
    }
    for (int i = hawks.size()-1; i >= 0; i--) {
      Hawk f = hawks.get(i);
      f.update();
      f.eat(grasshoppers);
      if (f.dead()) {
        hawks.remove(i);
      }
      Hawk newP = f.breed();
      if (newP!=null) {
        hawks.add(newP);
      }
    }
  }

  float getHawkNum() {
    return hawks.size();
  }

  float getGrasshopperNum() {
    return grasshoppers.size();
  }

  float getCactusNum() {
    return cactuses.size();
  }

  void addHawk(PVector pvector) {
    hawks.add(new Hawk(pvector, new DNA()));
  }

  void addGrasshopper(PVector pvector) {
    grasshoppers.add(new Grasshopper(pvector, new DNA()));
  }

  void addCactus(PVector pvector) {
    cactuses.add(new Cactus(pvector, new DNA()));
  }

  void reduceHawk() {
    hawks.remove(0);
  }
  void reduceCactus() {
    cactuses.remove(0);
  }
  void reduceGrasshopper() {
    grasshoppers.remove(0);
  }
}
