#define LEDR_BASE        0xFF200000        // LED base address
#define KEY_BASE         0xFF200050        // Key base address

volatile int *LEDR_ptr = (volatile int *)LEDR_BASE;
volatile int *KEY_ptr = (volatile int *)KEY_BASE;
volatile int *KEY_edge_capture = (volatile int *)(KEY_BASE + (3 * sizeof(int)));

int main(void) {
    int edge_capture;

    // Initialize LEDs to off
    *LEDR_ptr = 0;

    while (1) {
        edge_capture = *KEY_edge_capture; // Read the edge capture register

        if (edge_capture & 0x01) { // Check if KEY0 was pressed
            *LEDR_ptr = 0xFFF; // Turn on all LEDs
        } else if (edge_capture & 0x02) { // Check if KEY1 was pressed
            *LEDR_ptr = 0; // Turn off all LEDs
        }

        // Clear the edge capture register by writing back the read value
        *KEY_edge_capture = edge_capture;
    }

    return 0; // This line will never be reached
}
