import frames.timing.*;
import frames.primitives.*;
import frames.processing.*;

ArrayList<Point> dots = new ArrayList<Point>();
ArrayList<Point> dotsline = new ArrayList<Point>();
// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;

// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;

//testing vector
Vector v4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

void setup() {
  //use 2^n to change the dimensions
  size(1024, 1024, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      spin();
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow( 2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  if (debug) {
    pushStyle();
    stroke(255, 255, 255, 125);
    point(round(frame.coordinatesOf(v1).x()), round(frame.coordinatesOf(v1).y()));
    point(round(frame.coordinatesOf(v2).x()), round(frame.coordinatesOf(v2).y()));
    point(round(frame.coordinatesOf(v3).x()), round(frame.coordinatesOf(v3).y()));

    //pushStyle();
    //strokeWeight( 100 );
    //stroke( 255, 255, 255 );
    point(v1.x(), v1.y());
    point(v2.x(), v2.y());
    point(v3.x(), v3.y());
    //popStyle();

    float v1v2p3 = ( (v1.y() - v2.y()) * v3.x() ) + ( ( v2.x() - v1.x() ) * v3.y() ) + ( ( v1.x() * v2.y() ) - ( v1.y() * v2.x() ) );
    if( v1v2p3 < 0 ){
      Vector aux = v2;
      v2 = v3;
      v3 = aux;
    }



    for(int k = (int) -pow(2,n)/2; k <= pow(2,n)/2; k++){
      for(int l = (int) -pow(2,n)/2; l <= pow(2,n)/2; l++){
        float xValue =  width/pow(2,n)*k;
        float yValue =  width/pow(2,n)*l;

        float v1v2 = ( (v1.y() - v2.y()) * xValue) + ( ( v2.x() - v1.x() ) * yValue) + ( ( v1.x() * v2.y() ) - ( v1.y() * v2.x() ) );
        float v2v3 = ( (v2.y() - v3.y()) * xValue) + ( ( v3.x() - v2.x() ) * yValue) + ( ( v2.x() * v3.y() ) - ( v2.y() * v3.x() ) );
        float v3v1 = ( (v3.y() - v1.y()) * xValue) + ( ( v1.x() - v3.x() ) * yValue) + ( ( v3.x() * v1.y() ) - ( v3.y() * v1.x() ) );

        float triangulito = v1v2 + v2v3 + v3v1;
        float l0 = v2v3/triangulito;
        float l1 = v3v1/triangulito;
        float l2 = v1v2/triangulito;

        if( l0 > 0 && l1 >0 && l2 > 0 ){
          if( l0 > 0.05 && l1 > 0.05 && l2 > 0.05 ){
            dots.add(new Point(xValue,yValue));
          }
          else{
            dotsline.add(new Point(xValue,yValue));
          }
        }

        //if( l0 > 0.1 && l1 > 0.1 && l2 > 0.1 )
          //dots.add(new Point(xValue,yValue));
        //if( 0 < l0 && l0 < 0.1 || 0 < l1 && l1 < 0.1 || 0 < l2 &&l2 < 0.1 )
          //dotsline.add(new Point(xValue,yValue));

      }
    }
    popStyle();
  }
}

void randomizeTriangle() {
  dots = new ArrayList<Point>();
  dotsline = new ArrayList<Point>();
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
  v4 = new Vector(((-8)*width/pow(2,n)),(width/pow(2,n))*(-8));

}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  //triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(10);
  stroke(0, 0, 255);

  for(Point p: dots){
    point(p.x(),p.y());
  }
  pushStyle();
  stroke( 0, 100, 200 );
  for(Point p: dotsline){
    point(p.x(),p.y());
  }
  popStyle();

  pushStyle();
  stroke( 255, 0, 0 );
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
  popStyle();
}

void spin() {
  if (scene.is2D())
    scene.eye().rotate(new Quaternion(new Vector(0, 0, 1), PI / 100), scene.anchor());
  else
    scene.eye().rotate(new Quaternion(yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100), scene.anchor());
}

void debugx() {
  print( "v1 x: ", v1.x(), " y: ", v1.y(), "\n");
  print( "v2 x: ", v2.x(), " y: ", v2.y(), "\n");
  print( "v3 x: ", v3.x(), " y: ", v3.y(), "\n");
  print( "v1r x: ", round(frame.coordinatesOf(v1).x()), " y: ", round(frame.coordinatesOf(v1).y()), "\n");
  print( "v2r x: ", round(frame.coordinatesOf(v2).x()), " y: ", round(frame.coordinatesOf(v2).y()), "\n");
  print( "v3r x: ", round(frame.coordinatesOf(v3).x()), " y: ", round(frame.coordinatesOf(v3).y()), "\n");

  float xValue = 0;
  float yValue = 0;
  float v1v2 = ( (v1.y() - v2.y()) * xValue) + ( ( v2.x() - v1.x() ) * yValue) + ( ( v1.x() * v2.y() ) - ( v1.y() * v2.x() ) );
  float v2v3 = ( (v2.y() - v3.y()) * xValue) + ( ( v3.x() - v2.x() ) * yValue) + ( ( v2.x() * v3.y() ) - ( v2.y() * v3.x() ) );
  float v3v1 = ( (v3.y() - v1.y()) * xValue) + ( ( v1.x() - v3.x() ) * yValue) + ( ( v3.x() * v1.y() ) - ( v3.y() * v1.x() ) );
  float triangulito = v1v2 + v2v3 + v3v1;
  float l0 = v2v3/triangulito;
  float l1 = v3v1/triangulito;
  float l2 = v1v2/triangulito;

  //print( "w0 = ", v2v3, "\n" );
  //print( "w1 = ", v3v1, "\n" );
  //print( "w2 = ", v1v2, "\n" );
  //print( "2t = ", triangulito, "\n" );
  print( "l0 = ", l0, "\n" );
  print( "l1 = ", l1, "\n" );
  print( "l2 = ", l2, "\n" );
}

void normie() {
  v1 = new Vector( round(frame.coordinatesOf(v1).x())*(width/pow(2,n)), round(frame.coordinatesOf(v1).y())*(width/pow(2,n)) );
  v2 = new Vector( round(frame.coordinatesOf(v2).x())*(width/pow(2,n)), round(frame.coordinatesOf(v2).y())*(width/pow(2,n)) );
  v3 = new Vector( round(frame.coordinatesOf(v3).x())*(width/pow(2,n)), round(frame.coordinatesOf(v3).y())*(width/pow(2,n)) );
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    dots = new ArrayList<Point>();
    dotsline = new ArrayList<Point>();
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    dots = new ArrayList<Point>();
    dotsline = new ArrayList<Point>();
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
  if ( key == 'f' )
    debugx();
  if ( key == 'n' )
    normie();
}
