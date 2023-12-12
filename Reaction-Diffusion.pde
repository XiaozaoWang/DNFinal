Pixel[][] grid;
Pixel[][] prev;
int[] seedsX = {200,300,500,900,400,350};
int[] seedsY = {300,800,500,400,350,650};

float dA = 1;
float dB = 0.5;
float feed = 0.055;
//float feed = 0.03;
float k = 0.062;
//float feed = 0.01545;
//float k = 0.04702;
//float feed = 0.03433;
//float k = 0.05686;
//float feed = 0.09162;
//float k = 0.05695;


int w = 1200;
int h = 1200;
int resolution = 4;
int row, col;
int seed_size = 1;

void setup() {
  size(1200, 1200);
  frameRate(240);
  colorMode(HSB, 360, 100, 100);
  noStroke();
  row = floor( h / resolution);
  col = floor( w / resolution);

  grid = new Pixel[row][col];
  prev = new Pixel[row][col];
  for (int y = 0; y < row; y++) {
    for (int x = 0; x < col; x++) {
      float d = dist(x, y, width/2, height/2);
      float val = map(d, 0, width, 0, 1.5);
      grid[y][x] = new Pixel(x, y, val, 0);
      prev[y][x] = new Pixel(x, y, val, 0);
    }
  }

  // Set seed
  for (int n = 0; n < seedsX.length; n ++) {
    for (int j = floor(seedsY[n]/resolution) - seed_size; j < floor(seedsY[n]/resolution) + seed_size; j++) {
      for (int i = floor(seedsX[n]/resolution) - seed_size; i < floor(seedsX[n]/resolution) + seed_size; i++) {
        prev[j][i].b = 1;
      }
    }
  }
}

void draw() {
  feed = map(mouseX, 0, width, 0.01, 0.1);
  k = map(mouseY, height, 0, 0.045, 0.07);
  //if (frameCount % 60 == 0) {
  //  println(frameRate);
  //}
   //Calculate a/b density
  for (int y = 1; y < row-1; y++) {
    for (int x = 1; x < col-1; x++) {
      feed = map(y, 1, row-1, 0.02, 0.065);
      float a = prev[y][x].a;
      float b = prev[y][x].b;
      grid[y][x].a = a +
        ((dA * laplaceA(x, y)) -
        (a * b * b) +
        (feed * (1 - a))) * 1;
      grid[y][x].b = b +
        ((dB * laplaceB(x, y)) +
        (a * b * b) -
        ((k + feed) * b)) * 1;

      grid[y][x].a = constrain(grid[y][x].a, 0, 1);
      grid[y][x].b = constrain(grid[y][x].b, 0, 1);
    }
  }

  // Modify pixel colors
  for (int y = 0; y < row; y++) {
    for (int x = 0; x < col; x++) {
      float a = grid[y][x].a;
      float b = grid[y][x].b;
      int c = floor((a - b) * 255);
      c = constrain(c, 0, 255);
      c = floor(map(c, 0, 255, 20, 230));
      fill(c, 85, 85);
      rect(x*resolution, y*resolution, resolution, resolution);
    }
  }
  prev = grid;
}




void mouseDragged() {
  if (mouseX > 2*resolution && mouseX < width-2*resolution && mouseY > 2*resolution && mouseY < height-2*resolution) {
    for (int j = floor(mouseY/resolution) - seed_size; j < floor(mouseY/resolution) + seed_size; j++) {
      for (int i = floor(mouseX/resolution) - seed_size; i < floor(mouseX/resolution) + seed_size; i++) {
        prev[j][i].b = 1;
        grid[j][i].b = 1;
      }
    }
  }
}


void keyPressed() {
  feed = 0.055;
}



float laplaceA(int x, int y) {
  float sumA = 0;
  sumA += prev[y][x].a * -1;
  sumA += prev[y][x - 1].a * 0.2;
  sumA += prev[y][x + 1].a * 0.2;
  sumA += prev[y + 1][x].a * 0.2;
  sumA += prev[y - 1][x].a * 0.2;
  sumA += prev[y - 1][x - 1].a * 0.05;
  sumA += prev[y - 1][x + 1].a * 0.05;
  sumA += prev[y + 1][x + 1].a * 0.05;
  sumA += prev[y + 1][x - 1].a * 0.05;
  return sumA;
}

float laplaceB(int x, int y) {
  float sumB = 0;
  sumB += prev[y][x].b * -1;
  sumB += prev[y][x - 1].b * 0.2;
  sumB += prev[y][x + 1].b * 0.2;
  sumB += prev[y + 1][x].b * 0.2;
  sumB += prev[y - 1][x].b * 0.2;
  sumB += prev[y - 1][x - 1].b * 0.05;
  sumB += prev[y - 1][x + 1].b * 0.05;
  sumB += prev[y + 1][x + 1].b * 0.05;
  sumB += prev[y + 1][x - 1].b * 0.05;
  return sumB;
}
