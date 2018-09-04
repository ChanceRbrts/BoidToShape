class Boid{
  private float x, y, orientation;
  private float dOr;
  private int col;
  final float velocity = 200;
  final float TOOCLOSE = 6;
  private int goForth;
  private int maxGoForth;
  private ArrayList<Boid> closeBoids;
  private Attractor a;
  public Boid(float X, float Y){
    x = X;
    y = Y;
    orientation = random(PI*2);
  }
  
  public void update(ArrayList<Boid> close, float deltaTime){
    goForth = 0;
    maxGoForth = 0;
    dOr = 0;
    closeBoids = close;
    for (int i = 0; i < close.size(); i++){
      if (close.get(i) != this){
        float[] closeBoidPath = close.get(i).location();
        float closeOrientation = close.get(i).getOrientation();
        if (col != close.get(i).getColor()){
          closeOrientation = -closeOrientation;
          if (close.get(i).getAttractor() == a)
            goForth += 1;
        } 
        maxGoForth += 1;
        if (sqrt(sq(x-closeBoidPath[0])+sq(y-closeBoidPath[1])) < TOOCLOSE){
          closeOrientation = -closeOrientation*2;
        }
        if (abs(closeOrientation-orientation) > abs(closeOrientation+2*PI-orientation))
          closeOrientation += 2*PI;
        else if (abs(closeOrientation-orientation) > abs(closeOrientation-2*PI-orientation))
          closeOrientation -= 2*PI;
        dOr += (closeOrientation-orientation)*2.5/close.size();
      }
    }
    
    
    if (a != null){
      float aOrientation = a.getOrientation(this);
      if (abs(aOrientation-orientation) > abs(aOrientation+2*PI-orientation))
          aOrientation += 2*PI;
      else if (abs(aOrientation-orientation) > abs(aOrientation-2*PI-orientation))
        aOrientation -= 2*PI;
      if (a.getClass().getName().equals("BoidToShape$WeakAttractor"))
        dOr = ((aOrientation-orientation)/(deltaTime*4))*1/10+dOr*9/10;
      else 
        dOr = ((aOrientation-orientation)/(deltaTime*4))*1/4+dOr*3/4; //(close.size());
      //orientation = aOrientation;
    }
    
    dOr += random(-PI,PI);
    
    if ((x+velocity*cos(orientation)*deltaTime < 0 || x+velocity*cos(orientation)*deltaTime > width)
    && (y+velocity*sin(orientation)*deltaTime < 0 || y+velocity*sin(orientation)*deltaTime > height)){
      dOr += PI/deltaTime;
    } else if ((x+velocity*cos(orientation)*deltaTime < 0 || x+velocity*cos(orientation)*deltaTime > width)){
      dOr += 2*-(orientation+PI/2)/deltaTime;
    } else if ((y+velocity*sin(orientation)*deltaTime < 0 || y+velocity*sin(orientation)*deltaTime > height)){
      dOr += 2*-orientation/deltaTime;
    }
  }
  
  public void finishUpdate(float deltaTime){
    orientation += dOr*deltaTime;
    if (orientation > PI*2) orientation -= PI*2;
    else if (orientation < 0) orientation += PI*2;
    x += velocity*cos(orientation)*deltaTime;
    y += velocity*sin(orientation)*deltaTime;
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x >= width) x = width-1;
    if (y >= height) y = height-1;
  }
  
  public float[] location(){
    return new float[]{x,y};
  }
  
  public Attractor getAttractor(){
    return a;
  }
  
  public int[] approximateLocation(){
    return new int[]{round(x),round(y)};
  }
  
  public int getColor(){
    return col;
  }
  
  public void setColor(int colo){
    col = colo;
  }
  
  public void setAttractor(Attractor att){
    a = att;
  }
  
  public void draw(boolean night){
    float dStroke = night? 255: 0;
    float bright = night? 50: 0;
    strokeWeight(2);
    if (withPoints){
      if (col == 1) stroke(255,0,0); 
      else if (col == 2) stroke(0, 0, 255);
      else
        stroke(dStroke);
      point(x, y);
    }
    for (int i = 0; i < closeBoids.size(); i++){
      if (random(1) < 0.1 && closeBoids.get(i) != this){
        float[] loc = closeBoids.get(i).location();
        float dist = 4/sqrt(sq(x-loc[0])+sq(y-loc[1]));
        if (night) dist = dist*1.5;
        if (!withPoints){
          dist = dist*1.25;
          bright = bright*1.10;
        }
        if (dist > 1) dist = 1;
        if (bright > 255) bright = 255;
        if (col == 0) stroke(dStroke, 255*dist);
        else if (col == 1 && closeBoids.get(i).getColor() == 1) 
          stroke(255, bright, bright, 255*dist);
        else if (col == 2 && closeBoids.get(i).getColor() == 2) 
          stroke(bright, bright, 255, 255*dist);
        else stroke(255, bright, 255, 255*dist);
        line(x,y,loc[0],loc[1]);
      }
    }
  }
  
  public float getPercentageOfDone(){
    if (maxGoForth == 0) return 0;
    return goForth/float(maxGoForth);
  }
  
  
  public float getOrientation(){
    return orientation;
  }
  
}

class WeakAttractor extends Attractor{
  public WeakAttractor(float X, float Y){
    super(X,Y);
  }
  
  public void draw(boolean night){
    if (night) stroke(15, 255, 15, 150); else stroke(0, 150, 0, 150);
    strokeWeight(8);
    point(x,y);
  }
  
  public void update(float deltaTime){
    super.update(deltaTime);
    if (mouseX > 0 && mouseX < 640){
      x = mouseX;
      y = mouseY;
    }
  }
}

class Attractor{
  protected float x, y;
  public Attractor(float X, float Y){
    x = X;
    y = Y;
  }
  
  public void update(float deltaTime){};
  
  public float getOrientation(Boid b){
    float[] loc = b.location();
    if (x-loc[0] >= 0){
      return (atan((y-loc[1])/(x-loc[0])))%(PI);
    }
    return (atan((y-loc[1])/(x-loc[0])))%PI+PI;
  }
  
  public void draw(boolean night){
    if (night) stroke(50); else stroke(255);
    strokeWeight(8);
    point(x,y);
  }
}

class MovingAttractor extends Attractor{
  private float angle, dY;
  public MovingAttractor(float X, float Y){
    super(X,Y);
  }
  
  public void update(float deltaTime){
    super.update(deltaTime);
    angle += deltaTime;
    dY = cos(PI/4*angle);
    y += 100*dY*deltaTime;
  }
}

class Boids{
  private  ArrayList<Boid> boid;
  public Boids(){
    boid = new ArrayList<Boid>();
  }
  
  public ArrayList<Boid> me(){
    return boid;
  }
}

class Attractors{
  private ArrayList<Attractor> attr;
  public Attractors(){
    attr = new ArrayList<Attractor>();
  }
  
  public ArrayList<Attractor> me(){
    return attr;
  }
}

class Flock{
  private ArrayList<Boid> boids;
  private ArrayList<Attractor> att;
  private Boids[][] loca;
  private Attractors[][] attr;
  private int currentPattern;
  private boolean myColored;
  final int NEARBY = 15;
  final int NEARBY_ATT = 2;
  final int pPL = 5;
  public boolean night;
  
  public Flock(int boids){
    loca = new Boids[width/pPL+1][height/pPL+1];
    this.boids = new ArrayList<Boid>();
    for (int i = 0; i < boids; i++){
      this.boids.add(new Boid(random(620)+10, random(460)+10));
    }
    initialize();
    currentPattern = 1;
    if (currentPattern > 0){
      loadAttractors(pattern[currentPattern-1]);
    }
  }
  
  public void initialize(){
    attr = new Attractors[width/pPL+1][height/pPL+1];
    att = new ArrayList<Attractor>();
    for (int i = 0; i < boids.size(); i++){
      boids.get(i).setAttractor(null);
    }
    for (int i = 0; i < attr.length; i++){
      for (int j = 0; j < attr[i].length; j++){
        attr[i][j] = new Attractors();
      }
    }
  }
  
  public void update(float deltaTime, int patte){
    if (colored != myColored){
      myColored = colored;
      for (int i = 0; i < boids.size(); i++){
        boids.get(i).setColor(colored?floor(random(2)+1):0);
      }
    }
    if (currentPattern != patte){
      initialize();
      for (int i = 0; i < boids.size(); i++){
        boids.get(i).setAttractor(null);
      }
      if (patte > 0){
        loadAttractors(pattern[patte-1]);
      } else if (patte == -1){
        att.add(new WeakAttractor(mouseX, mouseY));
        for (int i = 0; i < boids.size(); i++){
          boids.get(i).setAttractor(att.get(0));
        }
      }
      currentPattern = patte;
    }
    updateLocations();
    updateBoids(deltaTime);
    finishUpdate(deltaTime);
  }
  
  public void draw(){
    if (night) background(0);
    else background(235, 235, 235);
    
    if (showAttractors){
      for (int i = 0; i < att.size(); i++){
        att.get(i).draw(night);
      }
    }
    
    for (int i = 0; i < boids.size(); i++){
      boids.get(i).draw(night);
    }
  }
  
  public void updateLocations(){
    for (int i = 0; i < loca.length; i++){
      for (int j = 0; j < loca[i].length; j++){
        loca[i][j] = new Boids();
      }
    }
    for (int i = 0; i < boids.size(); i++){
      float[] approxLoc = boids.get(i).location();
      loca[floor(approxLoc[0]/pPL)][floor(approxLoc[1]/pPL)].me().add(boids.get(i));
    }
  }
  
  public void updateBoids(float deltaTime){
    for (int i = 0; i < boids.size(); i++){
      ArrayList<Boid> close = new ArrayList<Boid>();
      ArrayList<Attractor> attra = new ArrayList<Attractor>();
      float[] boidLoc = boids.get(i).location();
      for (int x = floor((boidLoc[0])/pPL-NEARBY); x <= floor((boidLoc[0])/pPL+NEARBY) && x <= width/pPL; x++){
        for (int y = floor((boidLoc[1])/pPL-NEARBY); y <= floor((boidLoc[1])/pPL+NEARBY) && y <= height/pPL; y++){
          if (x >= 0 && y >= 0){
            close.addAll(loca[x][y].me());
          }
        }
      }
      for (int x = floor((boidLoc[0])/pPL-NEARBY_ATT); x <= floor((boidLoc[0])/pPL+NEARBY_ATT) && x <= width/pPL; x++){
        for (int y = floor((boidLoc[1])/pPL-NEARBY_ATT); y <= floor((boidLoc[1])/pPL+NEARBY_ATT) && y <= height/pPL; y++){
          if (x >= 0 && y >= 0){
            attra.addAll(attr[x][y].me());
          }
        }
      }
      if (random(1) < 0.01 && attra.size() > 0){
        boids.get(i).setAttractor(attra.get(int(random(attra.size()))));
      } else if (random(1) < 0.0005+(0.9*boids.get(i).getPercentageOfDone()) && att.size() > 0){
        boids.get(i).setAttractor(att.get(int(random(att.size()))));
      }
      boids.get(i).update(close, deltaTime);
    }
  }
  
  public void finishUpdate(float deltaTime){
    for (int i = 0; i < boids.size(); i++){
      boids.get(i).finishUpdate(deltaTime);
    }
    for (int i = 0; i < att.size(); i++){
      att.get(i).update(deltaTime);
    }
  }
  
  public void loadAttractors(String[] s){
    ArrayList<Boid> notAttracted = new ArrayList<Boid>();
    notAttracted.addAll(boids);
    int h = s.length;
    int w = s[0].length();
    for (int y = 0; y < h; y++){
      for (int x = 0; x < w; x++){
        if (s[y].charAt(x) == '1'){
          Attractor a = new Attractor(x*width/w,y*height/h);
          attr[x*width/(pPL*w)][y*height/(h*pPL)].me().add(a);
          att.add(a);
        } else if (s[y].charAt(x) == '2'){
          Attractor a = new MovingAttractor(x*width/w,y*height/h);
          attr[x*width/(pPL*w)][y*height/(h*pPL)].me().add(a);
          att.add(a);
        }
      }
    }
    ArrayList<Attractor> evenized = new ArrayList<Attractor>();
    evenized.addAll(att);
    while (notAttracted.size() > 0){
      if (evenized.size() == 0){
        evenized.addAll(att);
      }
      int attractor = floor(random(evenized.size()));
      int boid = floor(random(notAttracted.size()));
      notAttracted.get(boid).setAttractor(evenized.get(attractor));
      evenized.remove(attractor);
      notAttracted.remove(boid);
    }
  }
}