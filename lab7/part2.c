#include <stdlib.h>
#include <stdbool.h>

void swap(int *, int *);
void plot_pixel(int, int, short int);
void clear_screen();
void draw_line(int, int, int, int, short int);
void vsync();

int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
	
	int xCoord0 = 0;
	int xCoord1 = 319;
	int yCoord = 120; 
    draw_line(xCoord0, yCoord, xCoord1, yCoord, 0x07E0); // this line is green

	int increment = -1;
    while (1) {
        vsync();
		// clear_screen();
        draw_line(xCoord0, yCoord, xCoord1, yCoord, 0x0000); 
        if (yCoord == 0) {
            increment = 1;
        } else if (yCoord == 239) {
            increment = -1;
        }
        yCoord += increment;
        draw_line(xCoord0, yCoord, xCoord1, yCoord, 0x07E0);
    }
}

// code not shown for clear_screen() and draw_line() subroutines
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
			plot_pixel(x, y, 0x0000);
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
	volatile int * pixel_ctrl_ptr = (int *) 0xff203030; // base address
	int status;
	*pixel_ctrl_ptr = 1; // start the synchronization process
	// - write 1 into front buffer address register
	status = *(pixel_ctrl_ptr + 3); // read the status register
	while ((status & 0x01) != 0) // polling loop waiting for S bit to go to 0
	{
		status = *(pixel_ctrl_ptr + 3);
	}
}