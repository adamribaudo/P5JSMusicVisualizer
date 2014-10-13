import ddf.minim.*;

Minim minim;
AudioPlayer player;
boolean firstPlay = true;
boolean played = false;
int timeOffset;
int playHead;

boolean[] triggers;
int[] fills;
float[] widths;
float[] heights;
float[] startDepths;
float[] endDepths;
float[] translateInnerShapeX;
float[] translateInnerShapeY;
float translateInnerShapeRadius = 100;
float[] faceColors;
float cameraSpeed = .2;
float cameraZ = 0;
float objectStartZ = 0;
int curGlobalEvent = 0;

float colorHue = 0;
float colorHueChange = .001;

float perspectiveX = 1;



void setup()
{
  size(800, 450, P3D);
  background(0);
  minim = new Minim(this);
  player = minim.loadFile("coincidence.mp3");
  player.play();  

  triggers = new boolean[events.length];
  fills = new int[events.length];
  startDepths = new float[events.length];
  endDepths = new float[events.length];
  widths = new float[events.length];
  heights = new float[events.length];
  translateInnerShapeX = new float[events.length];
  translateInnerShapeY = new float[events.length];
  
  faceColors = new float[events.length];
  
  offlineImage = createGraphics(width, height, P3D);
}

void draw()
{
  colorMode(HSB, 1);
  background(.5);
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width/perspectiveX)/float(height), 
            cameraZ/10.0, cameraZ*10.0);

  //JavaScript
  if (player.isLoaded())
  //Java version
  //if (player.isPlaying())
  {
    //JavaScript
    playHead = (int)(player.getCurrentTime() * 1000) + 120;
    //Java version
    //playHead = (int)(player.position());

    cameraZ = -playHead - 500;
    objectStartZ = -playHead;

    camera(0, -200, cameraZ, 0.0, -200, 0.0, 0.0, 1.0, 0.0);

    executeGlobalEvents();
    executeEvents();
    incrementColorHue();
  }
  
  image(offlineImage, width/2, height/2);
}

int findMaxEvent()
{
  int maxEvent = -1;

  for (int i=0; i<events.length; i++)
  {
    if (events[i] <= playHead)
      maxEvent = i;
    else return maxEvent;
  }

  return maxEvent;
}

void incrementColorHue()
{
  colorHue += colorHueChange;
  if(colorHue>1)colorHue = 0;
}

int findFirstEvent()
{
  int firstEvent = findMaxEvent() - 100;
  return firstEvent < 0 ? 0 : firstEvent;
}

/*
Ideas for global events
 -bg color change
 -shape color change
 -shape translate
 */

float translateInnerShapeXCue = 0;
float translateInnerShapeYCue = 0;

void executeGlobalEvents()
{

  //If curGlobalEvent isn't at the last event, check if the playhead has reached the next event 
  if (curGlobalEvent < globalEvents.length - 1)
    if (playHead >= globalEvents[curGlobalEvent + 1])
      curGlobalEvent++;


println(globalEvents[curGlobalEvent]);
  //0, 739, 2247, 3738, 5237, 6749, 6847, 8249
  switch(globalEvents[curGlobalEvent])
  {
  case 0:
    break;
  case 739:
    break;
  case 2247:
  translateInnerShapeXCue = -200;
  
    break;
  case 3738:
  translateInnerShapeXCue = 200;
    break;
    case 5237:
    translateInnerShapeXCue = 0;
    break;
    case 6749:
    perspectiveX = 100;
    break;
    case 6847:
    perspectiveX = 1;
    break;
  break;
  }
}

void executeEvents()
{
 for (int i=findMaxEvent (); i>=findFirstEvent (); i--)
  {
    if (!triggers[i])
    {
      fills[i] = (int)random(255);
      startDepths[i] = objectStartZ;
      triggers[i] = true;
      widths[i] = random(600);
      heights[i] = random(200);
      
      //Translate inner shape
      translateInnerShapeX[i] = translateInnerShapeXCue;
      translateInnerShapeY[i] = translateInnerShapeYCue;
      
      faceColors[i] = colorHue;
      
      if (i > 0)
      {
        endDepths[i-1] = startDepths[i] - startDepths[i-1];
      }
    }

    float endDepthPoint=0;

    pushMatrix();
    translate(0, 0, startDepths[i]  +100);

    float faceColor = 0;
    //If shape is the current shape
    if (i == findMaxEvent())
    {
      faceColor = colorHue;
      
      endDepthPoint = objectStartZ - startDepths[i] - 1;
    }
    //process older shapes
    else if (findMaxEvent() > 0)
    {
      faceColor = faceColors[i];
      endDepthPoint = endDepths[i];
    }
    //fill(fills[i]);
    noStroke();
    //drawPyramid();
    pushMatrix();
    translate(translateInnerShapeX[i], translateInnerShapeY[i], 0);
    drawBox(widths[i], heights[i], endDepthPoint, faceColor, .8, .9, 0, 0, 0, 0, 0, .3);
    popMatrix();

    stroke(1);
    strokeWeight(.1);
    scale(10);
    noFill();
    rotateZ(radians(widths[i]));

    //drawHeMesh(); 
    drawCurveHeMesh();

    popMatrix();
  }
}

void drawBox(float boxWidth, float boxHeight, float endDepthPoint, float faceR, float faceG, float faceB, float startR, float startG, float startB, float endR, float endG, float endB)
{
  beginShape(QUADS);
  fill(endR, endG, endB);
  vertex(-boxWidth/2, boxHeight/2, 0);
  vertex( boxWidth/2, boxHeight/2, 0);
  vertex( boxWidth/2, -boxHeight/2, 0);
  vertex(-boxWidth/2, -boxHeight/2, 0);

  fill(endR, endG, endB);
  vertex( boxWidth/2, boxHeight/2, 0);
  fill(startR, startG, startB);
  vertex( boxWidth/2, boxHeight/2, endDepthPoint);
  vertex( boxWidth/2, -boxHeight/2, endDepthPoint);
  fill(endR, endG, endB);
  vertex( boxWidth/2, -boxHeight/2, 0);

  fill(faceR, faceG, faceB);
  vertex( boxWidth/2, boxHeight/2, endDepthPoint);
  vertex(-boxWidth/2, boxHeight/2, endDepthPoint);
  vertex(-boxWidth/2, -boxHeight/2, endDepthPoint);
  vertex( boxWidth/2, -boxHeight/2, endDepthPoint);

  fill(startR, startG, startB);
  vertex(-boxWidth/2, boxHeight/2, endDepthPoint);
  fill(endR, endG, endB);
  vertex(-boxWidth/2, boxHeight/2, 0);
  vertex(-boxWidth/2, -boxHeight/2, 0);
  fill(startR, startG, startB);
  vertex(-boxWidth/2, -boxHeight/2, endDepthPoint);

  fill(startR, startG, startB);
  vertex(-boxWidth/2, boxHeight/2, endDepthPoint);
  vertex( boxWidth/2, boxHeight/2, endDepthPoint);
  fill(endR, endG, endB);
  vertex( boxWidth/2, boxHeight/2, 0);
  vertex(-boxWidth/2, boxHeight/2, 0);

  fill(startR, startG, startB);
  vertex(-boxWidth/2, -boxHeight/2, endDepthPoint);
  vertex( boxWidth/2, -boxHeight/2, endDepthPoint);
  fill(endR, endG, endB);
  vertex( boxWidth/2, -boxHeight/2, 0);
  vertex(-boxWidth/2, -boxHeight/2, 0);
  endShape();
}

void drawPyramid()
{
  beginShape();
  vertex(-100, -100, -100);
  vertex( 100, -100, -100);
  vertex(   0, 0, 100);

  vertex( 100, -100, -100);
  vertex( 100, 100, -100);
  vertex(   0, 0, 100);

  vertex( 100, 100, -100);
  vertex(-100, 100, -100);
  vertex(   0, 0, 100);

  vertex(-100, 100, -100);
  vertex(-100, -100, -100);
  vertex(0, 0, 100);
  endShape();
}

void drawCurveHeMesh()
{
  beginShape();
  curveVertex(30.0, -2.706345629988333E-15, -50.0);
  curveVertex(30.0, 3.416888365748433E-15, 50.0);
  curveVertex(9.270509831248425, -28.531695488854602, 50.0);
  curveVertex(9.270509831248425, -28.53169548885461, -50.0);
  curveVertex(9.270509831248425, -28.531695488854602, 50.0);
  curveVertex(-24.27050983124842, -17.633557568774194, 50.0);
  curveVertex(-24.27050983124842, -17.6335575687742, -50.0);
  curveVertex(-24.27050983124842, -17.633557568774194, 50.0);
  curveVertex(-24.270509831248425, 17.633557568774194, 50.0);
  curveVertex(-24.270509831248425, 17.633557568774187, -50.0);
  curveVertex(-24.270509831248425, 17.633557568774194, 50.0);
  curveVertex(9.270509831248418, 28.531695488854613, 50.0);
  curveVertex(9.270509831248418, 28.531695488854606, -50.0);
  curveVertex(9.270509831248418, 28.531695488854613, 50.0);
  curveVertex(30.0, -2.706345629988333E-15, -50.0);

  endShape();
}

void drawHeMesh()
{
  beginShape();
  vertex(30.0, -2.706345629988333E-15, -50.0);
  vertex(30.0, 3.416888365748433E-15, 50.0);
  vertex(9.270509831248425, -28.531695488854602, 50.0);
  vertex(9.270509831248425, -28.53169548885461, -50.0);
  vertex(9.270509831248425, -28.531695488854602, 50.0);
  vertex(-24.27050983124842, -17.633557568774194, 50.0);
  vertex(-24.27050983124842, -17.6335575687742, -50.0);
  vertex(-24.27050983124842, -17.633557568774194, 50.0);
  vertex(-24.270509831248425, 17.633557568774194, 50.0);
  vertex(-24.270509831248425, 17.633557568774187, -50.0);
  vertex(-24.270509831248425, 17.633557568774194, 50.0);
  vertex(9.270509831248418, 28.531695488854613, 50.0);
  vertex(9.270509831248418, 28.531695488854606, -50.0);
  vertex(9.270509831248418, 28.531695488854613, 50.0);
  vertex(30.0, -2.706345629988333E-15, -50.0);

  endShape();
}

//Coincidence
int [] globalEvents = {
  0, 739, 2247, 3738, 5237, 6749, 6847, 8249
};

int [] events = {
  22
    , 398
    , 751
    , 958
    , 1223
    , 1429
    , 1971
    , 2251
    , 2741
    , 2908
    , 3022
    , 3189
    , 3658
    , 3761
    , 4220
    , 4335
    , 4502
    , 4877
    , 4981
    , 5255
    , 6029
    , 6197
    , 6755
    , 6856
    , 7244
    , 7506
    , 8255
    , 8747
    , 9006
    , 9107
    , 9478
    , 9668
    , 9770
    , 10134
    , 10245
    , 10414
    , 10525
    , 10697
    , 11255
    , 11355
    , 11537
    , 12005
    , 12755
    , 13245
    , 14255
    , 15006
    , 15758
    , 16247
    , 17259
    , 17748
    , 18029
    , 18759
    , 19251
    , 19884
    , 20259
    , 20728
    , 21009
    , 21759
    , 22248
    , 22509
    , 23259
    , 23730
    , 24030
    , 24762
    , 25328
    , 25529
    , 26263
    , 26754
    , 27766
    , 28046
    , 28232
    , 28533
    , 29266
    , 30034
    , 30387
    , 30766
    , 31231
    , 31535
    , 32266
    , 33037
    , 33766
    , 34513
    , 35266
    , 35752
    , 36037
    , 36770
    , 37048
    , 37337
    , 38270
    , 38735
    , 39770
    , 40047
    , 40891
    , 41270
    , 42016
    , 42770
    , 43329
    , 44269
    , 44548
    , 44735
    , 45038
    , 45770
    , 46048
    , 46235
    , 46516
    , 46913
    , 47017
    , 47266
    , 47472
    , 47580
    , 47862
    , 48013
    , 48766
    , 49055
    , 49252
    , 49532
    , 49926
    , 50095
    , 50266
    , 50544
    , 50752
    , 51015
    , 51419
    , 51791
    , 51976
    , 52234
    , 52356
    , 52513
    , 52941
    , 53266
    , 53855
    , 54036
    , 54427
    , 55297
    , 55523
    , 56532
    , 56770
    , 56894
    , 57515
    , 57765
    , 57888
    , 58530
    , 58717
    , 59050
    , 59518
    , 59647
    , 61266
    , 61513
    , 61704
    , 61884
    , 62263
    , 62516
    , 63265
    , 63518
    , 63705
    , 63887
    , 64269
    , 64889
    , 65265
    , 66762
    , 67040
    , 68261
    , 68540
    , 68819
    , 69010
    , 69385
    , 69759
    , 70044
    , 70505
    , 71251
    , 71532
    , 71723
    , 72001
    , 72751
    , 73222
    , 73522
    , 74251
    , 74720
    , 74832
    , 75021
    , 75379
    , 75751
    , 76047
    , 76220
    , 76331
    , 76502
    , 77251
    , 77721
    , 77830
    , 78001
    , 78303
    , 78427
    , 78751
    , 79220
    , 79501
    , 80084
    , 80251
    , 80444
    , 80549
    , 80723
    , 80831
    , 81001
    , 81385
    , 81759
    , 82040
    , 82226
    , 82525
    , 82883
    , 83259
    , 83725
    , 83836
    , 84005
    , 84383
    , 84758
    , 85040
    , 85224
    , 85525
    , 85883
    , 86259
    , 86542
    , 86727
    , 86830
    , 87385
    , 87758
    , 88045
    , 88224
    , 88327
    , 88505
    , 88887
    , 89258
    , 89541
    , 89724
    , 90008
    , 90382
    , 90759
    , 91041
    , 91226
    , 91333
    , 91509
    , 91791
    , 91901
    , 92091
    , 92262
    , 92543
    , 92729
    , 92831
    , 93012
    , 93597
    , 93762
    , 94142
    , 94512
    , 94893
    , 95284
    , 95824
    , 96033
    , 96392
    , 96763
    , 97141
    , 97519
    , 97895
    , 98269
    , 98646
    , 99016
    , 99395
    , 99767
    , 100145
    , 100517
    , 100894
    , 101287
    , 101645
    , 102016
    , 102395
    , 102769
    , 103144
    , 103516
    , 103895
    , 104266
    , 104645
    , 105019
    , 105393
    , 105766
    , 106145
    , 106517
    , 106896
    , 107267
    , 107547
    , 108013
    , 108763
    , 109515
    , 110265
    , 110548
    , 111011
    , 111765
    , 112329
    , 112512
    , 113266
    , 114011
    , 114591
    , 114766
    , 115337
    , 115511
    , 116262
    , 116836
    , 117111
    , 117395
    , 117574
    , 117762
    , 118340
    , 118531
    , 118709
    , 118816
    , 118997
    , 119186
    , 119295
    , 119830
    , 120010
    , 120115
    , 120334
    , 120478
    , 120592
    , 120759
    , 121047
    , 121508
    , 122257
    , 122547
    , 122832
    , 123022
    , 123195
    , 123302
    , 123403
    , 123568
    , 123670
    , 123770
    , 124069
    , 124327
    , 124508
    , 124610
    , 124712
    , 124886
    , 124994
    , 125102
    , 125258
    , 125554
    , 125831
    , 126005
    , 126122
    , 126227
    , 126330
    , 126481
    , 126588
    , 126762
    , 126863
    , 127507
    , 128028
    , 128779
    , 129008
    , 129763
    , 131010
    , 131502
    , 131721
    , 132004
    , 135001
    , 138015
    , 141295
    , 142147
    , 143293
    , 147888
    , 147990
    , 165182
};


