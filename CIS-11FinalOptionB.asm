; CIS-11 Final Project
; Option B: Test Score Calculator 
; Nunez, Ashley
; 06/11/26

; Project Purpose: Input 5 test scores, store them in array, calculate
; the minimum, maximum, and average, then display results with letter grade.

; Test Values: 52, 87, 96, 79, 61



.ORIG x3000

; Main 

MAIN 
	LD R6, STACK_TOP	; initialize stack pointer
	LEA R0, TITLE
	PUTS
	
	LEA  R4, SCORES
	AND R5, R5, #0
	ADD R5, R5, #5		; 5 scores
	
INPUT_LOOP
	LEA R0, PROMPT
	PUTS

	JSR GET_SCORE		; will return score in R0

	STR R0, R4, #0		; store the score into array
	ADD R4, R4, #1		; pointer moved into next array slot

	ADD R5, R5, #-1
	BRp INPUT_LOOP

	LEA R0, SCORES
	JSR FIND_STATS		; R0= min, R1=max, and R2=average
	
	ST R0, MIN_SCORE
	ST R1, MAX_SCORE
	ST R2, AVG_SCORE

	LEA R0, RESULT_HEADER
	PUTS

	LEA R0, RESULT_HEADER
	PUTS

; MIN

	LEA R0, MIN_MSG
	PUTS
	LD R0, MIN_SCORE
	JSR PRINT_NUMBER
	LEA R0, GRADE_MSG
	PUTS
	LD R0, MIN_SCORE
	JSR PRINT_GRADE
	JSR PRINT_NEWLINE

; MAX

	LEA R0, MAX_MSG
	PUTS
	LD R0, MAX_SCORE
	JSR PRINT_NUMBER
	LEA R0, GRADE_MSG
	PUTS
	LD R0, MAX_SCORE
	JSR PRINT_GRADE
	JSR PRINT_NEWLINE

; average

	LEA R0, AVG_MSG
	PUTS
	LD R0, AVG_SCORE
	JSR PRINT_NUMBER
	LEA R0, GRADE_MSG
	PUTS
	LD R0, AVG_SCORE
	JSR PRINT_GRADE
	JSR PRINT_NEWLINE

	HALT

; strings, storage, cosnt

TITLE		.STRINGZ "Test Score Calculator\n"
PROMPT		.STRINGZ "Enter test score: "
RESULT_HEADER	.STRINGZ "\nResults\n"
MIN_MSG 	.STRINGZ "Minimum score: "
MAX_MSG 	.STRINGZ "Maximum score: "
AVG_MSG		.STRINGZ "Average score: "
GRADE_MSG	.STRINGZ " Grade: "


SCORES 		.BLKW #5
MIN_SCORE 	.FILL #0
MAX_SCORE	.FILL #0
AVG_SCORE 	.FILL #0


STACK_TOP 	.FILL xFDFF


; getting the score


GET_SCORE
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R6, R6, #-1
	STR R1, R6, #0
	ADD R6, R6, #-1
	STR R2, R6, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	ADD R6, R6, #-1
	STR R4, R6, #0

	AND R2, R2, #0

READ_DIGIT
	GETC		; read one character
	OUT		; echo character

	LD R1, NEG_ENTER
	ADD R1, R0, R1
	BRz INPUT_DONE

	LD R1, NEG_ASCII_ZERO
	ADD R3, R0, R1			;R3 digit convereted to number

	BRn READ_DIGIT			; if below '0' , ignore
	
	ADD R4, R3, #-9
	BRp READ_DIGIT			; if above '9', ignore

; R2= R2 * 10 + R3
	ADD R4, R2, #0
	ADD R2, R2, R2		; 2x
	ADD R2, R2, R2		; 4x
	ADD R2, R2, R4		; 5x
	ADD R2, R2, R2		; 10x
	ADD R2, R2, R3		; add digit

; input limit
	LD R1, NEG_100
	ADD R4, R2, R1
	BRp SET_TO_100
	
	BR READ_DIGIT

SET_TO_100
	LD R2, CONST_100
	BR READ_DIGIT

INPUT_DONE
	JSR PRINT_NEWLINE
	ADD R0, R2, #0		; return score in R0

	LDR R4, R6, #0
	ADD R6, R6, #1
	LDR R3, R6, #0
	ADD R6, R6, #1
	LDR R2, R6, #0
	ADD R6, R6, #1
	LDR R1, R6, #0
	ADD R6, R6, #1
	LDR R7, R6, #0
	ADD R6, R6, #1

	RET

GS_NEG_ENTER		.FILL #-10
GS_NEG_CR		.FILL #-13
GS_NEG_ASCII_ZERO	.FILL #-48
GS_NEG_100		.FILL #-100
GS_CONST_100		.FILL #100                  

; calculating the min, max, sum, and average
; R0 = min, R1 = maximum, R2 = average


; finds the min, max, and sum of the five scores 

FIND_STATS
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	ADD R6, R6, #-1
	STR R4, R6, #0
	ADD R6, R6, #-1
	STR R5, R6, #0

	ADD R4, R0, #0		; array pointer

	LDR R0, R4, #0
	ADD R1, R0, #0	; max = first score
	ADD R2, R0, #0	; sum = first score
	ADD R5, R0, #0	; min = first score

	ADD R4, R4, #1  ; move pointer to second score
	AND R3, R3, #0
	ADD R3, R3, #4	; remaining scores to process

STAT_LOOP
	LDR R0, R4, #0	; load current score

	ADD R2, R2, R0  ; sum is plus or equal score
	 
; check if score < min
	NOT R7, R5
	ADD  R7, R7, #1
	ADD R7, R0, R7
	BRn UPDATE_MIN

CHECK_MAX

; check if score > max
	NOT R7, R1
	ADD R7, R7, #1
	ADD R7, R0, R7
	BRp UPDATE_MAX


NEXT_SCORE
	ADD R4, R4, #1
	ADD R3, R3, #-1
	BRp STAT_LOOP

; calculate avg = sum/5
	ADD R0, R2, #0
	JSR DIVIDE_BY_5
	
	ADD R2, R0, #0	; avg
	ADD R0, R5, #0	; min
	; R1 already has maximum 
 
	LDR R5, R6, #0
	ADD R6, R6, #1
	LDR R4, R6, #0
	ADD R6, R6, #1
	LDR R3, R6, #0
	ADD R6, R6, #1
	LDR R7, R6, #0
	ADD R6, R6, #1

	RET

UPDATE_MIN
	ADD R5, R0, #0
	BR CHECK_MAX

UPDATE_MAX
	ADD R1, R0, #0
	BR NEXT_SCORE

; divides the sum by 5 using repeated subtraction, returns the quotient in R0
DIVIDE_BY_5
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R6, R6, #-1
	STR R1, R6, #0
	ADD R6, R6, #-1
	STR R2, R6, #0

	AND R1, R1, #0
	ADD R2, R0, #0

DIV_LOOP
	ADD R2, R2, #-5
	BRn DIV_DONE
	ADD R1, R1, #1
	BR DIV_LOOP

DIV_DONE
	ADD R0, R1, #0

	LDR R2, R6, #0
	ADD R6, R6, #1
	LDR R1, R6, #0
	ADD R6, R6, #1
	LDR R7, R6, #0
	ADD R6, R6, #1

	RET

; print number

PRINT_NUMBER
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R6, R6, #-1
	STR R1, R6, #0
	ADD R6, R6, #-1
	STR R2, R6, #0
	ADD R6, R6, #-1
	STR R3, R6, #0
	ADD R6, R6, #-1
	STR R4, R6, #0

	ADD R2, R0, #0
	AND R4, R4, #0
	
	LD R1, NEG_100 
	ADD R1, R2, R1
	BRn PRINT_TENS

	LD R0, ASCII_ONE
	OUT
	ADD R2, R1, #0
	ADD R4, R4, #1

PRINT_TENS
	AND R3, R3, #0	; tens digit

TENS_LOOP
	ADD R1, R2, #-10
	BRn PRINT_ONES
	ADD R2, R1, #0
	ADD R3, R3, #1
	BR TENS_LOOP

PRINT_ONES
	ADD R1, R4, R3
	BRz SKIP_TENS_PRINT

	LD R0, ASCII_ZERO
	ADD R0, R0, R3
	OUT

SKIP_TENS_PRINT
	LD R0, ASCII_ZERO
	ADD R0, R0, R2
	OUT

	LDR R4, R6, #0
	ADD R6, R6, #1
	LDR R3, R6, #0
	ADD R6, R6, #1
	LDR R2, R6, #0
	ADD R6, R6, #1
	LDR R1, R6, #0
	ADD R6, R6, #1
	LDR R7, R6, #0
	ADD R6, R6, #1

	RET

PN_NEG_100	.FILL #-100
PN_ASCII_ZERO	.FILL x0030
PN_ASCII_ONE	.FILL x0031                           


; display letter grade
; checks from highest grade to lowest

PRINT_GRADE
	ADD R6, R6, #-1
	STR R7, R6, #0
	ADD R6, R6, #-1
	STR R1, R6, #0

	LD R1, NEG_90
	ADD R1, R0, R1
	BRzp PRINT_A


	LD R1, NEG_80
	ADD R1, R0, R1
	BRzp PRINT_B

	
	LD R1, NEG_70
	ADD R1, R0, R1
	BRzp PRINT_C

	LD R1, NEG_60
	ADD R1, R0, R1
	BRzp PRINT_D

	
	LD R0, LETTER_F
	OUT
	BR GRADE_DONE

PRINT_A
	LD R0, LETTER_A
	OUT
	BR GRADE_DONE

PRINT_B
	LD R0, LETTER_B
	OUT
	BR GRADE_DONE

PRINT_C
	LD R0, LETTER_C
	OUT
	BR GRADE_DONE

PRINT_D
	LD R0, LETTER_D
	OUT
	BR GRADE_DONE

GRADE_DONE
	LDR R1, R6, #0
	ADD R6, R6, #1
	LDR R7, R6, #0
	ADD R6, R6, #1

	RET

; prints ASCII newline character 
PRINT_NEWLINE
	ADD R6, R6, #-1
	STR R7, R6, #0
	
	LD R0, ASCII_NEWLINE
	OUT

	LDR R7, R6, #0
	ADD R6, R6, #1

	RET


CONST_100	.FILL #100

ASCII_ZERO	.FILL x0030
ASCII_ONE	.FILL x0031
ASCII_NEWLINE	.FILL x000A

LETTER_A	.FILL x0041
LETTER_B	.FILL x0042
LETTER_C	.FILL x0043
LETTER_D	.FILL x0044
LETTER_F	.FILL x0046

NEG_ENTER 	.FILL #-10
NEG_ASCII_ZERO	.FILL #-48
NEG_60		.FILL #-60
NEG_70		.FILL #-70
NEG_80		.FILL #-80
NEG_90		.FILL #-90
NEG_100		.FILL #-100

.END