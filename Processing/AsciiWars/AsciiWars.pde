import java.nio.charset.StandardCharsets;
import com.github.luben.zstd.Zstd;

boolean use_zstd = true;
boolean fullspeed =   false;
boolean showframes = true;
boolean saveframes = false;

int cframe = 0; // current frame in a imation 
int rframe = 0; // global frame
byte[] delays;
byte[] rawdata;
byte[] compdata;
int FRAMES = 3410;
int LINES_PER_FRAME= 13;
int  CHARS_PER_LINE = 67;
int CHARS_PER_FRAME  = CHARS_PER_LINE * LINES_PER_FRAME;
int FPS = 25;


int PARTS = 62;  // change this depending on zstd split
int PART_SIZE = FRAMES * CHARS_PER_FRAME / PARTS;
int FRAMES_PER_PART = PART_SIZE / CHARS_PER_FRAME; 

int PART_SIZES[]  = {     966,  567,  236,  860,  988, 1240, 1420,  999, 1159,  596,  562,  735,  680,  835,  454, 1185,  
890, 1092, 1018,  748, 1222,  942,  982,  871, 1148,
  999,  866,  879,  788,  780,  442,  584, 1004,  817, 1099, 1431,  988,  806,  705, 1055, 1008,  690, 1090,  882, 1308,  942,  812, 
  892,  931,  994,  923, 1054,  778,  942, 1252,  950, 1081,  979,  504,  719,  698,   987
};
int part_offsets[]  = new int[PARTS];
byte[] buffer;
int cpartnum= -1;

byte[] get_zstd_frame(int fnum) {
    if (compdata == null) {
      compdata = loadBytes("rawframes.bin.zst");
      // init parts offsets
      int coffset = 0;
      for (int idx = 0; idx < PARTS; ++idx) {
        part_offsets[idx] = coffset;
        coffset += PART_SIZES[idx];
      }
       System.out.println(String.format( "parts %d, part size %d, frames per part %d", PARTS, PART_SIZE,  FRAMES_PER_PART));
    }
    if (compdata != null) {
      int partnum = fnum / PARTS;
      if (cpartnum != partnum) {
        byte[] partbytes = subset(compdata, part_offsets[partnum], PART_SIZES[partnum]);
        System.out.println(String.format( "decompressing %d", partnum));
        buffer = Zstd.decompress(partbytes);  
        cpartnum = partnum;
      }
     return subset(buffer, (fnum % FRAMES_PER_PART) * CHARS_PER_FRAME,CHARS_PER_FRAME);
  }
  return null;
}

 byte[] get_frame(int fnum) {
    if (rawdata == null) {
      rawdata = loadBytes("rawframes.bin");
    }
    if (rawdata != null) {
       return subset(rawdata, fnum * CHARS_PER_FRAME, CHARS_PER_FRAME);
     }
     return null;
 }
 
void setup() { 
  size(1280, 720);
  if (!fullspeed)
    frameRate(FPS);
  PFont mono =  createFont("mono.ttf", 28);
  textFont(mono);
  delays = loadBytes("delays.bin");
}


void centerText(String s, int ypos) {
  int w = (int)textWidth(s);
  text(s, (width - w) / 2, ypos);
}


boolean first = true;
int WAIT_UNIT = fullspeed ? 1: (1000 / FPS);
int startframe= -1; 
String[] frame = new String[LINES_PER_FRAME];
void draw() {
  if ((millis() - startframe) > (delays[cframe] * WAIT_UNIT)) {
     byte[]  bframe = use_zstd ? get_zstd_frame(cframe) : get_frame(cframe);
     for (int  l = 0; l < LINES_PER_FRAME; l++) {
       if (bframe != null) { 
           byte[] bline = subset(bframe, l * CHARS_PER_LINE, CHARS_PER_LINE); 
          frame[l]= new String(bline,  StandardCharsets.US_ASCII); 
       } else {
         frame[l] =  "Error in AsciiWars";
       }
     }
    cframe += 1;
    if (cframe >= FRAMES ){
      cframe = 0;
       delay(5000);
      first = false;
    }
    startframe = millis();
  }
  background(0,0,0);
  fill(0, 255, 0);
  centerText("AsciiWars",30);
  centerText("Animation: Simon Jansen - Code: Frédéric Delhoume", 680);
  fill(255, 255, 255);
  for (int  l = 0; l < LINES_PER_FRAME; ++l) {
    text(frame[l], 40,160 + 34 * l); 
  }   
  rframe += 1;  
  if (showframes) {
      fill(0, 255, 255);
    if(fullspeed)
      text(String.format("global frame: %06d", rframe), 10, 50);
    else
      text(String.format("frame: %06d - global frame: %06d", cframe, rframe), 10, 50);
  }
 if (first && saveframes) {
   String formatted = String.format("frames/frame_%06d.jpg", rframe);
   saveFrame(formatted);

  }
} 
  //<>//
