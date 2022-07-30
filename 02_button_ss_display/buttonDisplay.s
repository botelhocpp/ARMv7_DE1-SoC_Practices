/*
 * @author Pedro Botelho
 * @brief  Control the LEDs, Seven-segment display,
 * 		   switches and buttons of simulator!
 * @date   2022-07-30
 * @note   Run here: https://cpulator.01xz.net/?sys=arm-de1soc
 */ 

// Devices 
.EQU LEDS,  		0xFF200000
.EQU SWITCHES, 		0xFF200040
.EQU BUTTONS, 		0xFF200050
.EQU SS_DISPLAY, 	0xFF200020

// Seven-segment Display Numbers
.EQU SS_DISPLAY_0,	0b00111111
.EQU SS_DISPLAY_1,	0b00000110
.EQU SS_DISPLAY_2,	0b01011011
.EQU SS_DISPLAY_3,	0b01001111
.EQU SS_DISPLAY_4,	0b01100110
.EQU SS_DISPLAY_5,	0b01101101
.EQU SS_DISPLAY_6,	0b01111101
.EQU SS_DISPLAY_7,	0b00000111
.EQU SS_DISPLAY_8,	0b01111111
.EQU SS_DISPLAY_9,	0b01101111
.EQU SS_DISPLAY_A,	0b01110111
.EQU SS_DISPLAY_B,	0b01111100
.EQU SS_DISPLAY_C,	0b00111001
.EQU SS_DISPLAY_D,	0b01011110
.EQU SS_DISPLAY_E,	0b01111001
.EQU SS_DISPLAY_F,	0b01110001

.TEXT
.GLOBAL _start
_start:
		BL _getButtons
		BL _setLeds	

		PUSH {R0}
		BL _getSwitches
		MOV R1, R0
		POP {R0}

		CMP R1, #0
		Beq _start

		BL _setDisplay

        B  _start

.GLOBAL _getSwitches
_getSwitches:
		MOV R12, SP
		
		LDR R1, =SWITCHES
		LDR R0, [R1]
		AND R0, R0, #0xF

		MOV SP, R12
		MOV PC, LR

.GLOBAL _getButtons
_getButtons:
		MOV R12, SP
		
		LDR R1, =BUTTONS
		LDR R0, [R1]
		
		MOV SP, R12
		MOV PC, LR

.GLOBAL _setLeds
_setLeds:
		MOV R12, SP
		
		LDR R1, =LEDS
		STR R0, [R1]
		
		MOV SP, R12
		MOV PC, LR

/*
 * Set the display with the given index with the given
 * value.
 *  
 * Prototype: void _setDisplay(int value, int display);
 * Parameter: R0 (value)
 * Parameter: R1 (display)
 *
 */
.GLOBAL _setDisplay
_setDisplay:
		PUSH {LR}
		MOV R12, SP
		
		BL _getDisplayNumber

		MOV R2, R1

		ANDs R3, R2, #0x1
		MOV R1, #0
		BLne _setOneDisplay
		
		ANDs R3, R2, #0x2
		MOV R1, #1
		BLne _setOneDisplay
		
		ANDs R3, R2, #0x4
		MOV R1, #2
		BLne _setOneDisplay
		
		ANDs R3, R2, #0x8
		MOV R1, #3
		BLne _setOneDisplay

		MOV SP, R12
		POP {PC}

.GLOBAL _setOneDisplay
_setOneDisplay:
		MOV R12, SP
		STMFD SP!, {R4, R5, R6}

		// Obtains the display bit-field
		LSL R1, R1, #3

		LDR R4, =SS_DISPLAY
		LDR R3, [R4]
		
		// Obtains the bit-field mask
		LDR R5, =0xFF
		LSL R5, R1
		
		// Clears the display bit-field
		BIC R3, R3, R5
		
		// Shift the Display Value to the bit-field
		LSL R6, R0, R1
		
		// Set the display value
		ORR R5, R3, R6
		STR R5, [R4]
		
		LDMFD SP!, {R4, R5, R6}
		MOV SP, R12
		MOV PC, LR

.GLOBAL _getDisplayNumber
_getDisplayNumber:
		MOV R12, SP

		// Stay at range 0 - 15
		AND R0, R0, #0xF
		
		// Obtains the offset of the Table
		MOV R2, #4
		MUL R0, R0, R2
		
		// Get the correct case to branch to
		LDR R2, =TABLE
		ADD R0, R0, R2
		LDR R2, [R0]
		MOV PC, R2
		
		CASE_00:
			MOV R0, #SS_DISPLAY_0
			B _getDisplayNumber_END
		
		CASE_01:
			MOV R0, #SS_DISPLAY_1
			B _getDisplayNumber_END
			
		CASE_02:
			MOV R0, #SS_DISPLAY_2
			B _getDisplayNumber_END
			
		CASE_03:
			MOV R0, #SS_DISPLAY_3
			B _getDisplayNumber_END
			
		CASE_04:
			MOV R0, #SS_DISPLAY_4
			B _getDisplayNumber_END
			
		CASE_05:
			MOV R0, #SS_DISPLAY_5
			B _getDisplayNumber_END
			
		CASE_06:
			MOV R0, #SS_DISPLAY_6
			B _getDisplayNumber_END
			
		CASE_07:
			MOV R0, #SS_DISPLAY_7
			B _getDisplayNumber_END
			
		CASE_08:
			MOV R0, #SS_DISPLAY_8
			B _getDisplayNumber_END
			
		CASE_09:
			MOV R0, #SS_DISPLAY_9
			B _getDisplayNumber_END
			
		CASE_10:
			MOV R0, #SS_DISPLAY_A
			B _getDisplayNumber_END
			
		CASE_11:
			MOV R0, #SS_DISPLAY_B
			B _getDisplayNumber_END
			
		CASE_12:
			MOV R0, #SS_DISPLAY_C
			B _getDisplayNumber_END
			
		CASE_13:
			MOV R0, #SS_DISPLAY_D
			B _getDisplayNumber_END
			
		CASE_14:
			MOV R0, #SS_DISPLAY_E
			B _getDisplayNumber_END
			
		CASE_15:
			MOV R0, #SS_DISPLAY_F
			B _getDisplayNumber_END
		
		_getDisplayNumber_END:
		MOV SP, R12
		MOV PC, LR		

.DATA
TABLE:	.WORD CASE_00, CASE_01, CASE_02, CASE_03
		.WORD CASE_04, CASE_05, CASE_06, CASE_07
		.WORD CASE_08, CASE_09, CASE_10, CASE_11
		.WORD CASE_12, CASE_13, CASE_14, CASE_15 


