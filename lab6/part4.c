#define AUDIO_BASE 0xFF203040
#define DAMPING 0.5

int main(void) {
    // Audio port structure
    struct audio_t {
        volatile unsigned int control; // The control/status register
        volatile unsigned char rarc; // the 8 bit RARC register
        volatile unsigned char ralc; // the 8 bit RALC register
        volatile unsigned char wsrc; // the 8 bit WSRC register
        volatile unsigned char wslc; // the 8 bit WSLC register
        volatile unsigned int ldata; // the 32 bit (really 24) left data register
        volatile unsigned int rdata; // the 32 bit (really 24) right data register
    };

    // Pointer to the audio port structure
    struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);

    // Variables to hold values of samples
    int left, right;

    // Infinite loop checking the RARC to see if there is at least a single
    // entry in the input fifos. If there is, just copy it over to the output fifo.
    // The timing of the input fifo controls the timing of the output.
    while (1) {
        if (audiop->rarc > 0) { // Check RARC to see if there is data to read
            // Load both input microphone channels - just get one sample from each
            left = audiop->ldata; // Load the left input FIFO
            right = audiop->rdata; // Load the right input FIFO

            // Apply echo effect with damping
            left += DAMPING * left;
            right += DAMPING * right;

            // Store to the left and right output FIFOs
            audiop->ldata = left; // Store to the left output FIFO
            audiop->rdata = right; // Store to the right output FIFO
        }
    }
    return 0; // This line will never be reached
}
