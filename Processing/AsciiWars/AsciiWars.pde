import java.nio.charset.StandardCharsets;

boolean fullspeed =   false;
boolean showframes = false;
boolean saveframes = false;

byte[] delays;
byte[] rawdata;
int FRAMES = 3410;
int LINES_PER_FRAME= 13;
int  CHARS_PER_LINE = 67;
int CHARS_PER_FRAME  = CHARS_PER_LINE * LINES_PER_FRAME;
int FPS = 25;   PFont mono;
byte[] get_frame(byte[] source, int fnum){
  return subset(source, fnum * CHARS_PER_FRAME,CHARS_PER_FRAME);
}

void setup() {
  size(1280, 720);
  if (!fullspeed)
    frameRate(FPS);
  mono =  createFont("mono.ttf", 28);
  textFont(mono);
  rawdata =  loadBytes("rawframes.bin");
  delays = loadBytes("delays.bin");
}


void centerText(String s, int ypos) {
  int w = (int)textWidth(s);
  text(s, (width - w) / 2, ypos);
}

int cframe = 0;
int WAIT_UNIT = fullspeed ? 1: (1000 / FPS);
int startframe= -1; 
String[] frame = new String[LINES_PER_FRAME];
boolean first = true; 
int rframe = 0;

void draw() {
  if ((millis() - startframe) > (delays[cframe] * WAIT_UNIT)) {
   byte[]  bframe = get_frame(rawdata,  cframe);
     for (int  l = 0; l < LINES_PER_FRAME; l++) {
        byte[] bline = subset(bframe, l * CHARS_PER_LINE, CHARS_PER_LINE); 
        frame[l]= new String(bline,  StandardCharsets.US_ASCII);  
     }
    cframe += 1;
    if (cframe > FRAMES ){
      cframe = 0;
       delay(5000);
      first = false;
    }
    startframe = millis();
  }
  background(0, 0, 0);
  fill(0, 255, 0);
  centerText("AsciiWars",30); //<>//
  centerText("Animation: Simon Jansen - Code: Frédéric Delhoume", 680);
  fill(255, 255, 255);
  for (int  l = 0; l < LINES_PER_FRAME; ++l) {
    text(frame[l], 40,160 + 34 * l); 
  }   
  rframe += 1;  
  if (showframes) {
      fill(0, 255, 255);
    if(fullspeed)
      text(String.format("global frame: %06d", rframe), 10, 40);
    else
      text(String.format("frame: %06d - global frame: %06d", cframe, rframe), 10, 40);
  }
 if (first && saveframes) {
   String formatted = String.format("frames/frame_%06d.jpg", rframe);
   saveFrame(formatted);

  }
}
