private float currentTime, endTime, deltaTime;
private Flock f;
private int pat, prevPat;
private boolean withPoints, showAttractors, followMouse, colored;

void setup(){
  size(640, 480);
  f = new Flock(200);
  withPoints = true;
}

void draw(){
  if (deltaTime > 0){
    f.update(deltaTime, pat);
    f.draw();
  }
  endTime = currentTime;
  currentTime = System.nanoTime()/1000000000.0;
  if (endTime > 0) deltaTime = currentTime-endTime;
  //background(random(100), random(100), random(100));
}

void keyPressed(){
  if (keyCode >= 47 && keyCode <= 55){
    pat = keyCode-48;
    followMouse = false;
  }
  if (keyCode == 65){
    showAttractors = !showAttractors;
  }
  if (keyCode == 78){
    f.night = !f.night;
  }
  if (keyCode == 80){
    withPoints = !withPoints;
    followMouse = false;
  }
  if (keyCode == 77){
    followMouse = !followMouse;
    int beforePat = pat;
    pat = followMouse? -1 : prevPat;
    prevPat = beforePat;
  } 
  if (keyCode == 82){
    colored = !colored;
  }
}