import java.nio.charset.StandardCharsets;
import java.nio.ByteBuffer;

import com.github.luben.zstd.Zstd;

boolean use_zstd = true;
boolean fullspeed =   false;
boolean showframes = false;
boolean saveframes = true;

int cframe = 0; // current frame in a imation 
int rframe = 0; // global frame
byte[] delays;
byte[] rawdata;
byte[] compdata;
int FRAMES = 3410;
int LINES_PER_FRAME= 13;
int  CHARS_PER_LINE = 67;
int CHARS_PER_FRAME  = CHARS_PER_LINE * LINES_PER_FRAME;
int FPS = 15;


int parts;
byte part_sizes[];
int part_offsets[];
byte buffer[];
int cpartnum= -1;
ByteBuffer partsbuf;
int partsize;
int framesperpart;

byte[] get_zstd_frame(int fnum) {
    if (compdata == null) {
      compdata = loadBytes("rawframes.bin.zst");
      
      part_sizes = loadBytes("parts.bin");
      partsbuf = ByteBuffer.wrap(part_sizes);
      parts = part_sizes.length /4;
      partsize =  FRAMES * CHARS_PER_FRAME / parts;
      framesperpart = partsize / CHARS_PER_FRAME;
      part_offsets = new int[parts];
      // init parts offsets
      int coffset = 0;
      for (int idx = 0; idx < parts; ++idx) {
        part_offsets[idx] = coffset;
        coffset += partsbuf.getInt(4 * idx);
      }
       System.out.println(String.format( "parts %d, part size %d, frames per part %d",parts, partsize,framesperpart));
    }
    if (compdata != null) {
      int partnum = fnum / parts;
      if (cpartnum != partnum) {
        byte[] partbytes = subset(compdata, part_offsets[partnum], partsbuf.getInt(4 * partnum));
        System.out.println(String.format( "decompressing part %d", partnum));
        buffer = Zstd.decompress(partbytes);  
        cpartnum = partnum;
      }
     return subset(buffer, (fnum % framesperpart) * CHARS_PER_FRAME,CHARS_PER_FRAME);
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
  //size(1280, 720);
  size(336, 200);
  if (!fullspeed)
    frameRate(FPS);
    init_chars();
  PFont mono =  createFont("mono.ttf", 28);
  textFont(mono);
  delays = loadBytes("delays.bin");
}


void centerText(String s, int ypos) {
  int w = (int)textWidth(s);
  text(s, (width - w) / 2, ypos);
}

PImage font5x5[];
void init_chars() {
  font5x5 = new PImage[128];
  for (int i = 0 ; i < 128; ++i) {
  PImage img = createImage(5, 5, ARGB);
  img.loadPixels();
   for (int y = 0; y < 5; y++) 
   for (int x = 0; x < 5; x++) {
        if ((nitram_micro_mono.fontData_CP437[i * 5 + y] & (1 << x)) == (1 << x)) {
          int offs = y * 5 + x;
          img.pixels[offs] = color(255, 255, 255,255);
        }
   }
   img.updatePixels();
    font5x5[i] = img;
  }
}

void render_char(int c, float xpos, float ypos) {
      if (c != 32)   image(font5x5[c], xpos, ypos);
}

boolean first = true;
int WAIT_UNIT = fullspeed ? 1: 1000 / FPS;
int startframe= -1; 
String[] frame = new String[LINES_PER_FRAME];
void draw() {
  if ((millis() - startframe) >= (delays[cframe] * WAIT_UNIT)) {
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
       //delay(5000);
      first = false;
    }
    
 startframe = millis();
  }
  background(0,0,0);
  fill(0, 255, 0);
  //centerText("AsciiWars",30);
  //centerText("Animation: Simon Jansen - Code: Frédéric Delhoume", 680);
  fill(255, 255, 255);
  for (int  l = 0; l < LINES_PER_FRAME; ++l) {
    float startx = 0;
    float starty = 60 + 5 * l;
    String textt = frame[l];
    if (textt != null) {
   for(int i = 0; i < textt.length(); i++) {
      render_char(textt.charAt(i), startx + 5 * i, starty); 
    }
    } else{
    }
   // text(textt, startx, starty);
  }
stroke(0, 255, 255);
line(320, 0 , 320, 200);
  rframe += 1;  
  if (false && showframes) {
      fill(0, 255, 255);
    if(fullspeed)
      text(String.format("global frame: %06d", rframe), 10, 50);
    else
      text(String.format("frame: %06d - global frame: %06d", cframe, rframe), 10, 50);
      }
 if (first && saveframes) {
   String formatted = String.format("savedframes/frame_%06d.jpg", rframe);
   saveFrame(formatted);

  }
} 
  //<>//
