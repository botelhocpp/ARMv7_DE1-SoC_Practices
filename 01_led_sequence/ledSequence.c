/*
 * @author Pedro Botelho
 * @brief  Blinks every one of the 10 LEDs of 
 *         the ARMv7 DE1-SoC simulator devices.
 * @date   2022-07-30
 * @note   Run here: https://cpulator.01xz.net/?sys=arm-de1soc
 */

/* Obtains the Register in the given Address */
#define	HWREG(add)				(*((volatile unsigned long *) 	(add)))
	
/* Devices Register Addresses */
#define DEVICES_BASE 			(0xFF200000)
#define DEVICES_LEDS 			(DEVICES_BASE + 0x0000)
#define DEVICES_SS_DISPLAY_01 	(DEVICES_BASE + 0x0020)
#define DEVICES_SS_DISPLAY_02 	(DEVICES_BASE + 0x0030)
#define DEVICES_SWITCHES 		(DEVICES_BASE + 0x0040)
#define DEVICES_BUTTONS 		(DEVICES_BASE + 0x0050)

/* Private Timer Register Addresses */
#define TIMER_BASE				(0xFFFEC600)
#define TIMER_LOAD				(TIMER_BASE + 0x0000)
#define TIMER_COUNTER			(TIMER_BASE + 0x0004)
#define TIMER_CONTROL			(TIMER_BASE + 0x0008)
#define TIMER_STATUS			(TIMER_BASE + 0x000C)
	
/* Count Signal Cycles for 1ms (W/ Divide-by-200 PS) */
#define TIMER_1MS				(1000)	

/* Timer Registers Masks */
#define TIMER_ENABLE			(1U << 0)
#define TIMER_AUTO_RELOAD		(1U << 1)
#define TIMER_INTERRUPT_ENABLE	(1U << 2)
#define TIMER_INTERRUPT_FLAG	(1U << 0)
#define TIMER_PRESCALER_2		(0b00000001 << 8)
#define TIMER_PRESCALER_200		(0b11000111 << 8)

/* Quantity of LEDs been used (10, 32, etc...) */
#define LED_NUMBER 10	

/* Period of the LED Blinking */
#define PULSE_WIDTH 500

/*
 * Blinks the LED at PULSE_WIDTH milliseconds.
 */
int main(void);

/*
 * Initialize the Cortex-A9 Private Timer with
 * a divide-by-200 prescaler, a 1MHz count signal,
 * no interrupt generation and no auto-reload.
 */
void timerSetup(void);

/*
 * Delay the CPU in the given milliseconds quantity.
 */
void delay(int ms);

int _start(void) {
	timerSetup();
	main();
	return 0;
}

int main(void) {
	int led = 0;
	while(1) {
		HWREG(DEVICES_LEDS) |= (1 << led);
		delay(PULSE_WIDTH);
		HWREG(DEVICES_LEDS) &= ~(1 << led);
		delay(PULSE_WIDTH);
		led = (led + 1) % LED_NUMBER;
	}
}

void timerSetup(void) {
	HWREG(TIMER_CONTROL) &= ~TIMER_AUTO_RELOAD & ~TIMER_INTERRUPT_ENABLE;
	HWREG(TIMER_CONTROL) |= TIMER_PRESCALER_200;
	HWREG(TIMER_STATUS) |= TIMER_INTERRUPT_FLAG;
}

void delay(int ms) {
	HWREG(TIMER_LOAD) = ms*TIMER_1MS;
	HWREG(TIMER_CONTROL) |= TIMER_ENABLE;
	while(!(HWREG(TIMER_STATUS) & TIMER_INTERRUPT_FLAG));
	HWREG(TIMER_STATUS) |= TIMER_INTERRUPT_FLAG;
}