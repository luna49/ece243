#define AUDIO_BASE 0xFF203040
#define SW_BASE	0xFF200040

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

// Pointer to the audio port structure and switch
volatile int *swp = (int*) SW_BASE;
struct audio_t *audiop = (struct audio_t *) AUDIO_BASE;

int main(void) {
	// Initialize current switch value and frequency (period)
	int curr_val, freq;
	while(1) {
		// Update current switch value
		curr_val = *swp;
		// Set default to 100Hz
        if (curr_val == 0) {
			// 8kHz is the sampling speed; 80 = 100Hz
            freq = 80;
		}
		else if (freq <= 4) {
			// Reset to 100Hz if 2kHz is reached
			freq = 80;
		}
        else {
			// Increase frequency in intervals
            freq = 80 - 8*curr_val;

			// Store samples to output channels
			for (int i = 0; i < freq / 2; i++) {
				audiop->ldata = 0x00ffffff;
				audiop->rdata = 0x00ffffff;
			}

			for (int i = 0; i < freq / 2; i++) {
				audiop->ldata = 0;
				audiop->rdata = 0;
			}
    	}
	}
}
