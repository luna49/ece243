#include <stdlib.h>
#include <stdbool.h>
	
void swap(int *, int *);
void plot_pixel(int, int, short int);
void clear_screen();
void draw_line(int, int, int, int, short int);
void vsync();
void square(int, bool);
void initializesquare(int);

volatile int pixel_buffer_start; // global variable
short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];

// declare other variables(not shown)
int xBox[8][3], yBox[8][3]; // top left of square
int dx[8], dy[8]; // direction can be -1 or +1
int colorBox[8]; // color of each box
int color[10] = { 0xffff, 0xf800, 0x07e0, 0x001f, 0xF81F, 0xff04, 0x0200, 0xf42f, 0x0f55, 0xf0f0 };

int main(void)
{	
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    
	// initialize location and direction of rectangles(not shown)
	for (int i = 0; i < 8; i++) {
        initializesquare(i);
    }

    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        //clear_screen();

        // code for drawing the boxes and lines (not shown)
        // code for updating the locations of boxes (not shown)
		for (int i = 0; i < 8; i++) {
			// erase 2 frames ago
			square(i, false);
			// draw new frame
			square(i, true);
			
			// use of wrap around like a loop so the first is connected to the last
			// erase line from 2 frames ago
    		int nextIndex = (i == 7) ? 0 : i + 1; 
    		draw_line(xBox[i][2], yBox[i][2], xBox[nextIndex][2], yBox[nextIndex][2], 0x00);

    		// draw the new line
    		draw_line(xBox[i][0], yBox[i][0], xBox[nextIndex][0], yBox[nextIndex][0], colorBox[i]);

			// update frames in array
			for (int j = 2; j > 0; j--) {
				xBox[i][j] = xBox[i][j - 1];
				yBox[i][j] = yBox[i][j - 1];
			}
			
			// check boundaries
			if (xBox[i][0] == 0) {
				dx[i] = 1;
			} else if (xBox[i][0] == 319) {
				dx[i] = -1;
			}
			
			if (yBox[i][0] == 0) {
				dy[i] = 1;
			} else if (yBox[i][0] == 239) {
				dy[i] = -1;
			}
			
			xBox[i][0] += dx[i];
			yBox[i][0] += dy[i];
		}

        vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

void clear_screen()
{
	// loop to set every pixel on the screen to white
	for (int x = 0; x < 320; x++) {
		for (int y = 0; y < 240; y++) {
			plot_pixel(x, y, 0x00);
		}
	}
}

void draw_line(int x0, int y0, int x1, int y1, short int line_color)
{
	bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	
	if (is_steep) {
        swap(&x0, &y0);
        swap(&x1, &y1);
    }
    if (x0 > x1) {
        swap(&x0, &x1);
        swap(&y0, &y1);
    }
	
	int deltax = x1 - x0;
	int deltay = abs(y1 - y0);
	int error = -(deltax / 2);
	int y = y0;
	int y_step;
	if (y0 < y1) {
		y_step = 1;
	} else {
		y_step = -1;
	}
	
	for (int x = x0; x < x1; x++) {
		if (is_steep) {
			plot_pixel(y, x, line_color);
		} else {
			plot_pixel(x, y, line_color);
		}
		error = error + deltay;
		if (error > 0) { 
			y = y + y_step; 
			error = error - deltax;
		}
	}
}

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;
    one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);
    *one_pixel_address = line_color;
}

void vsync()
{
	volatile int * pixel_ctrl_ptr = (int *) 0xff203020; // base address
	int status;
	*pixel_ctrl_ptr = 1; // start the synchronization process
	// - write 1 into front buffer address register
	status = *(pixel_ctrl_ptr + 3); // read the status register
	while ((status & 0x01) != 0) // polling loop waiting for S bit to go to 0
	{
		status = *(pixel_ctrl_ptr + 3);
	}
}

void square(int i, bool draw) {
	// use set color if drawing square; use 0x00 if erasing square
    short int color = draw ? colorBox[i] : 0x00;
	// nested loop to iterate over 2x2 area
    for (int dx = 0; dx < 2; dx++) {
        for (int dy = 0; dy < 2; dy++) {
			// go back to 2 frames ago for double buffering; stay at current for drawing
			// plot pixel draws/erases at the specified location
            plot_pixel(xBox[i][draw ? 0 : 2] + dx, yBox[i][draw ? 0 : 2] + dy, color);
        }
    }
}

void initializesquare(int i) {
    dx[i] = (( rand() %2) *2) - 1;
	dy[i] = (( rand() %2) *2) - 1;
	
	xBox[i][0] = rand() % 319;
    yBox[i][0] = rand() % 239;
	
    colorBox[i] = color[rand() % 10]; // random color
}