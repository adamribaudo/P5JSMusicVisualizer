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

float colorHue = 0;
float colorHueChange = .001;

float perspectiveX = 1;

float maxWidth = 600;
float maxHeight = 200;
float minWidth = 1;
float minHeight = 1;

void setup()
{
  size(800, 450, P3D);
  background(0);
  minim = new Minim(this);
  player = minim.loadFile("coincidence-final.mp3");
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
}

void draw()
{
  colorMode(HSB, 1);
  background(.5);
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, width/perspectiveX/float(height), 
  cameraZ/10.0, cameraZ*10.0);

  //JavaScript
  //if (player.isLoaded())
    //Java version
    if (player.isPlaying())
  {
    //JavaScript
    //playHead = (int)(player.getCurrentTime() * 1000) + 120;
    //Java version
    playHead = (int)(player.position());

    cameraZ = -playHead - 500;
    objectStartZ = -playHead;

    camera(0, -200, -300, 0.0, -200, 0, 0.0, 1.0, 0.0);
    //lights();

    pushMatrix();
    noStroke();
    fill(colorHue, .8, .5);
    translate(0, 0, 3100);
    scale(12);
    rect(-width/2, -height/2, width, height);
    //directionalLight(1, 1, 1, 0, 0, 0);
    popMatrix();

    pushMatrix();
    translate(0, 0, -cameraZ);

    executeGlobalEvents();
    executeEvents();
    incrementColorHue();

    popMatrix();
  }
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
  if (colorHue>1)colorHue = 0;
}

int findFirstEvent()
{
  int firstEvent = findMaxEvent() - 12;
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
  if (playHead >= 0 && playHead < 739)
  {
    maxWidth = 400;
    maxHeight = 200;
  } else if (playHead >= 739 && playHead < 2247)
  {
  } else if (playHead >= 2247 && playHead < 3738)
  {
    translateInnerShapeXCue = -200;
  } else if (playHead >= 3738 && playHead < 5237)
  {
    translateInnerShapeXCue = 200;
  } else if (playHead >= 5237 && playHead < 6749)
  {
    translateInnerShapeXCue = 0;
  } else if (playHead >= 6749 && playHead < 6847)
  {
    perspectiveX = 100;
  } else if (playHead >= 6846 && playHead < 8200)
  {

    perspectiveX = 1;
  } else if (playHead >= 8200 && playHead < 8825)
  {
    minWidth = 600;
    maxWidth = 1000;
    minHeight = 600;
    maxHeight = 1000;
  } else if (playHead >= 8825)
  {
    minWidth = 1;
    maxWidth = 600;
    minHeight = 1;
    maxHeight = 200;
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
      widths[i] = random(minWidth, maxWidth);
      heights[i] = random(minHeight, maxHeight);

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
  endShape(CLOSE);
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
int [] events = {
  96,376,487,660,844,1032,1314,1501,1691,1878,2063,2344,2720,2833,3000,3106,3282,3657,3844,3964,4128,4313,4414,4594,4876,4996,5159,5348,5725,5912,6098,6289,6473,6662,6848,6948,7317,7598,7882,8073,8347,8451,8728,8830,9099,9200,9383,9570,9758,9859,9962,10227,10356,10505,10789,10976,11162,11348,11448,11630,11820,12099,12379,12661,12848,13226,13599,13882,14161,14348,14817,15098,15663,15852,16321,16603,16883,17165,17351,17821,18102,18383,18573,18852,19321,19434,19602,19977,20352,20543,20821,21102,21385,21490,21667,21851,22322,22602,22883,23164,23351,23669,23822,24102,24665,24856,25133,25321,25430,25603,25883,25984,26170,26355,26545,26650,26824,26929,27106,27480,27672,27859,28138,28324,28425,28607,28888,29171,29359,29547,29671,29825,29936,30106,30388,30488,30671,30859,31048,31159,31325,31607,32359,32824,33106,33387,33669,33859,34136,34324,34606,35359,35638,35824,36106,36390,36862,37141,37328,37429,37612,38363,38828,38929,39110,39673,39863,39965,40140,40328,40429,40610,40984,41363,41640,41828,41933,42109,42484,42862,43329,43446,43609,43984,44363,44641,44828,44935,45109,45217,45321,45436,45540,45863,46080,46328,46429,46544,46661,46888,46988,47098,47204,47308,47418,47545,47650,47824,47925,48026,48138,48241,48481,48591,48693,48802,48906,49050,49151,49252,49364,49468,49606,49713,49886,49987,50089,50189,50291,50392,50493,50594,50694,50824,50934,51105,51208,51329,51481,51581,51688,51797,51897,52000,52121,52225,52325,52432,52541,52655,52884,52987,53092,53202,53305,53406,53550,53658,53825,53926,54041,54147,54250,54395,54498,54613,54866,54969,55106,55209,55310,55414,55610,55713,55815,55918,56027,56127,56230,56614,56717,56817,56921,57021,57125,57291,57394,57501,57608,57711,57813,57916,58016,58120,58229,58340,58449,58612,58715,58822,58945,59109,59213,59317,59426,59528,59629,59731,59839,59939,60106,60208,60311,60482,60615,60920,61110,61293,61476,61604,61727,61916,62106,62290,62478,62605,62727,62911,63099,63288,63608,63796,63914,64101,64290,64606,64979,65354,65539,65640,65821,65922,66098,66477,66659,66853,66953,67131,67317,67418,67597,67876,68161,68351,68630,68816,68917,69098,69380,69481,69660,69850,70034,70134,70316,70417,70596,70969,71154,71344,71444,71625,71813,71913,72093,72374,72657,72844,72944,73125,73312,73592,73877,73978,74156,74344,74444,74545,74649,74814,74914,75094,75375,75476,75654,75844,75944,76125,76226,76326,76427,76527,76630,76969,77344,77445,77545,77724,77824,78094,78377,78478,78582,78843,79028,79129,79313,79413,79593,79695,80156,80344,80448,80549,80651,80811,80912,81092,81197,81379,81479,81661,81850,81951,82051,82225,82327,82598,82973,83159,83351,83456,83557,83815,83915,84096,84475,84660,84850,84950,85131,85315,85599,85882,85983,86159,86351,86455,86632,86816,86917,87097,87377,87477,87657,87850,87975,88132,88314,88415,88596,88879,88980,89159,89349,89464,89566,89666,89815,90099,90475,90662,90852,90952,91132,91233,91335,91435,91600,91882,91984,92163,92266,92366,92467,92634,92819,92920,93106,93666,93766,93866,93967,94233,94334,94603,94984,95164,95265,95365,95916,96102,96202,96483,96666,96855,97234,97334,97608,97709,97988,98091,98358,98736,99108,99487,99588,99688,99790,99891,100237,100608,100985,101356,101456,101736,101837,101938,102107,102488,102671,102771,102871,103235,103419,103607,103708,103987,104087,104188,104357,104736,104922,105022,105123,105485,105855,106236,106336,106608,106708,106987,107171,107359,107467,107638,107739,107917,108104,108204,108668,108768,108869,108974,109233,109605,110166,110282,110382,110484,110640,110912,111102,111481,111662,111849,112136,112417,112600,112704,112981,113167,113269,113369,113728,113913,114101,114479,114662,114851,115418,115601,115979,116165,116351,116637,116916,117103,117203,117383,117484,117584,117692,117792,117893,118135,118417,118599,118790,118892,118993,119096,119197,119297,119400,119637,119916,120102,120203,120303,120404,120506,120608,120713,120818,120932,121135,121413,121598,121978,122160,122349,122633,122909,123098,123200,123301,123404,123504,123606,123708,123808,123910,124133,124410,124599,124700,124800,124901,125002,125105,125212,125312,125414,125633,125911,126099,126202,126303,126404,126504,126606,126706,126808,126910,127019,127598,127973,128098,128851,129097,129480,129848,130226,130599,130846,131099,131476,131595,131784,132092,132469,132847,133217,133598,134341,135093,136221,136595,137342,138094,139595,140345,141096,141321,141421,141526,141635,141758,142230,142536,142799,142945,143347,144097,144201,144304,144425,144553,144656,146349,146450,146550,146658,146759,146919,147092,147210,147730,147833,147949,148050,148150,148290,148658,150310,150851,164888,165026,165128,165230
};

