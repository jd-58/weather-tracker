TITLE Program Weather Tracker     (Proj3_deatonja.asm)

; Author: Jacob Deaton
; A weather tracker that calculates weather information based on temperature readings (in Celsius)
; that the user provides. Information includes minimum, maximum, and average temperatures.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; Constants
minTemp			= -30
maxColdTemp		= -1
minCoolTemp		= 0
maxCoolTemp		= 15
minWarmTemp		= 16
maxWarmTemp		= 30
minHotTemp		= 31
maxTemp			= 50


.data

intro					BYTE	"Welcome to the Temperature Tool by Jacob Deaton",0
numOfReadingsPrompt		BYTE	"How many temperature readings would you like to enter? (Must be greater than 0): ",0
instructions1			BYTE	"To start, enter daily temperature readings, in celsius, in the specified range. ",0
instructions2			BYTE	"The program will display statistics of the input values including the minimum, maximum, and average values, ",0
instructions3			BYTE	"and provide a count of Cold (Less than 0 C), Cool (0-15 C), Warm (16-30 C), and Hot (more than 30 C) days.",0
namePrompt				BYTE	"What is your name? ",0
nameDisplay				BYTE	"Hello there, ",0
tempPrompt1				BYTE	"Please enter ",0
tempPrompt2				BYTE	" temperature readings in the range [-30, 50] Celsius.",0
invalidCold				BYTE	"No... too cold! That can't be right! (Invalid Input)",0
invalidHot				BYTE	"Yikes! That's way too hot! (Invalid Input)",0
dailyTemp				BYTE	"Daily Temperature: ",0
thanksPrompt			BYTE	"Thanks! Lets work some stats:",0
maxTempPrompt			BYTE	"The maximum valid temp reading was ",0
degCelsius				BYTE	" degrees Celsius.",0
minTempPrompt			BYTE	"The minimum valid temp reading was ",0
avgTempIntPrompt		BYTE	"The average integer temperature reading was ",0
avgTempDecimalPrompt	BYTE	"The average temperature reading rounded to 2 decimal places was ",0
decimal					BYTE	".",0
coldPrompt				BYTE	"Number of Cold days: ",0
coolPrompt				BYTE	"Number of Cool days: ",0
warmPrompt				BYTE	"Number of Warm days: ",0
hotPrompt				BYTE	"Number of  Hot days: ",0
farewell				BYTE	"Farewell, ",0
username				BYTE	31	DUP(0)	; Username be entered by the user
usernameByteCount		DWORD	?			; Holds counter for username size
numColdDays				DWORD	0			; To be calculated, number of cold days
tempReadingDiv2			DWORD	?			; To be calculated, the number of temp readings divided by 2 to determine whether to round up or down
tempReadingDiv2Rem		SDWORD	?			; To be calculated, the remainder for the number of temp readings divided by 2	
numCoolDays				DWORD	0			; To be calculated, number of cool days
numWarmDays				DWORD	0			; To be calculated, number of warm days
numHotDays				DWORD	0			; To be calculated, number of hot days
userTemp				SDWORD	?			; To be calculated, the most recent user temperature reading
avgTempInt				SDWORD	0			; To be calculated, the average (integer) temperature
avgTempIntRound			SDWORD	?			; To be calculated, average integer temperature if it needs to be rounded up
avgTempRemainder		DWORD	0			; To be calcualted, the remainder of integer division of average temperature
avgTempDecimal			DWORD	?			; To be calculated, the decimal portion of the avg temp
lowestTemp				SDWORD	?			; To be calculated, the lowest of the user temperature readings
highestTemp				SDWORD	?			; To be calcualted, the highest of the user temperature readings
loopCounter				DWORD	0			; Sets the loop counter at zero
numOfTempReadings		DWORD	?			; To be entered by the user, the number of temperature readings they would like to enter.


.code
main PROC

; --------------------------
; Displays a welcome message, including the programmer name. 
; Asks user how many temperature readings they want to enter, and saves that to a variable.
; Instructions for the user to enter temperatures, and an explanation of the 
; temperature catagories is displayed.
; --------------------------
	; Welcome message
	MOV		EDX, OFFSET intro
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf				; Having a blank line between the welcome message and the instructions

	; Display instructions
	MOV		EDX, OFFSET instructions1
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET instructions2
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET instructions3
	CALL	WriteString
	CALL	CrLf


; --------------------------
; Asks the user their name, gets the user input, stores it in a variable
; and then greets the user using their name. 
; For EC: Asks user how many temperatures they want to enter, and saves that number as a variable.
; --------------------------
	; Ask user their name
	MOV		EDX, OFFSET namePrompt
	CALL	WriteString

	; Read user input
	MOV		EDX, OFFSET username
	MOV		ECX, 32
	CALL	ReadString					; Preconditions of ReadString: (1) Max length saved in ECX, (2) EDX holds ptr to string

	; Greet user with their name
	MOV		EDX, OFFSET nameDisplay
	CALL	WriteString
	MOV		EDX, OFFSET username
	CALL	WriteString
	CALL	CrLf

	; Prompt: How many temps does user want to enter
	MOV		EDX, OFFSET numOfReadingsPrompt
	CALL	WriteString
	CALL	ReadInt					; Postconditions of ReadInt: Value is saved in EAX
	MOV		numOfTempReadings, EAX
	CALL	CrLf
	CALL	CrLf

; --------------------------
; Prompts the user to enter temperature readings in the correct range.
; Reads the user input, stores it in a variable, and loops the determined number of times.
; Adds the user temperature to the running total (to determine the average).
; Checks if this value is lower than the previous lowest value, or higher than the previous highest value. Updates the min and max if needed.
; Will give an error if a temperature is too hot or too cold, and prompt the user to enter a new temperature. 
; --------------------------
	; Prompt the user to enter temperature readings
	MOV		EDX, OFFSET tempPrompt1
	CALL	WriteString
	MOV		EAX, numOfTempReadings
	CALL	WriteDec
	MOV		EDX, OFFSET tempPrompt2
	CALL	WriteString
	CALL	CrLf


	; Checks if the loop is finished. If not, reads user temperature readings.
	_tempLoopStart:						; Start the loop here
	MOV		EDX, loopCounter
	CMP		EDX, numOfTempReadings
	JGE		_tempCalculations
	MOV		EDX, OFFSET dailyTemp
	CALL	WriteString
	CALL	ReadInt					; Postconditions of ReadInt: Value is saved in EAX
	MOV		userTemp, EAX
	
	; Checks if user temperature is in the correct range
	MOV		EDX, userTemp
	CMP		EDX, minTemp
	JL		_tooCold
	MOV		EDX, userTemp
	CMP		EDX, maxTemp	
	JG		_tooHot

	; Determines whether the user temperature was a cold, cool, warm, or hot day
	MOV		EDX, userTemp
	CMP		EDX, maxColdTemp
	JLE		_coldDay
	MOV		EDX, userTemp
	CMP		EDX, maxCoolTemp
	JLE		_coolDay
	MOV		EDX, userTemp
	CMP		EDX, maxWarmTemp
	JLE		_warmDay
	JMP		_hotDay

	_coldDay:
	INC		numColdDays
	JMP		_validTemp

	_coolDay:
	INC		numCoolDays
	JMP		_validTemp

	_warmDay:
	INC		numWarmDays
	JMP		_validTemp

	_hotDay:
	INC		numHotDays
	JMP		_validTemp

	;  Adds valid user temp to running total, checks if it is the first valid temp
	_validTemp:
	MOV		EDX, userTemp
	ADD		avgTempInt, EDX
	CMP		loopCounter, 0			; Checks if it is the first valid user temp
	JZ		_firstValidTemp

	; Checks if this is a new lowest or highest entered temp. If not, increments loop and jumps to start
	MOV		EDX, userTemp
	CMP		EDX, lowestTemp
	JL		_newLowestTemp
	MOV		EDX, userTemp
	CMP		EDX, highestTemp
	JG		_newHighestTemp
	INC		loopCounter
	JMP		_tempLoopStart
	


	; Updates highest temperature, increments and goes back to start
	; of loop if the user needs to enter more temperatures
	_firstValidTemp:				
	MOV		EDX, userTemp
	MOV		lowestTemp, EDX
	MOV		highestTemp, EDX
	INC		loopCounter
	JMP		_tempLoopStart


	; Updates the lowest entered temperature, increments loop, and goes back to start of loop if user
	; needs to enter more loops
	_newLowestTemp:				
	MOV		EDX, userTemp		
	MOV		lowestTemp, EDX
	INC		loopCounter
	JMP		_tempLoopstart

	_newHighestTemp:
	MOV		EDX, userTemp		
	MOV		highestTemp, EDX
	INC		loopCounter
	JMP		_tempLoopstart


	; Displays the error if the user enters a temperature above the range
	_tooHot:
	CALL	CrLf
	MOV		EDX, OFFSET invalidHot
	CALL	WriteString
	CALL	CrLf
	JMP		_tempLoopStart

	; Displays an error if the user enteres a temperature below the range
	_tooCold:
	CALL	CrLf
	MOV		EDX, OFFSET invalidCold
	CALL	WriteString
	CALL	CrLf
	JMP		_tempLoopStart


; --------------------------
; Displays the min and max temperatures.
; --------------------------
	; Display max temp
	_tempCalculations:
	CALL	CrLf
	MOV		EDX, OFFSET thanksPrompt
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET maxTempPrompt
	CALL	WriteString
	MOV		EAX, highestTemp
	CALL	WriteInt
	MOV		EDX, OFFSET degCelsius
	CALL	WriteString

	; Display min temp
	CALL	CrLf
	MOV		EDX, OFFSET minTempPrompt
	CALL	WriteString
	MOV		EAX, lowestTemp
	CALL	WriteInt
	MOV		EDX, OFFSET degCelsius
	CALL	WriteString
	CALL	CrLf

; --------------------------
; Calculates the average temperature rounded to the nearest integer.
; Calculates whether to round up or down, by dividing the remainder by the number of temp readings.
; Checks if remainder is greater than half of the number of temp readings. 
; If so, rounds up or down depending on positive or negative number.
; Displays the average temp.
; --------------------------


	; Divide sum of all temp readings by number of temp readings
	MOV		EAX, avgTempInt	; Moving to EAX for IDIV
	MOV		EDX, 0				; IDIV preconditions: EDX must be cleared
	CDQ							; Sign extending EAX into EDX
	MOV		ECX, numOfTempReadings
	IDIV	ECX
	MOV		avgTempInt, EAX
	MOV		avgTempRemainder, EDX		; Remainder stored in EDX, moved to variable

	; If remainder is negative, mul by -1 to make it positive
	CMP		avgTempRemainder, 0
	JGE		_numTempReadingDiv
	MOV		EAX, avgTempRemainder
	MOV		EBX, -1
	IMUL	EBX					; Result stored in EAX
	MOV		avgTempRemainder, EAX


	; Divides number of temp readings by 2
	_numTempReadingDiv:
	MOV		EAX, numOfTempReadings
	MOV		EDX, 0
	CDQ
	MOV		ECX, 2
	IDIV	ECX
	MOV		tempReadingDiv2, EAX
	MOV		tempReadingDiv2Rem, EDX		; Remainder stored in EDX, moved to variable

	; Compare the temp reading divided by 2 to the integer divide remainder. 
	MOV		EDX, avgTempRemainder
	CMP		EDX, tempReadingDiv2
	JL		_avgTempDisplayNoRound			; If remainder is less than half of num of temps / 2, no rounding needed.
	JE		_avgTempRemainderCheck			; If the integers are equal in the division, rounding might be needed. Check remainders to ensure which number is larger. 
	JMP		_avgTempRound					; If integer is larger, then rounding is definitely needed.

	; Compare remainder of number of temp readings / 2 to see if the temp reading divided by 2 is larger or smaller than integer divide remainder.
	; If there is a remainder to the number of temp readings / 2, the number needs to be rounded.
	_avgTempRemainderCheck:
	CMP		tempReadingDiv2Rem, 0
	JE		_avgTempRound				; Number of temp readings / 2 has a remainder, and is larger than remainder of avg temp. Rounding needed.
	JMP		_avgTempDisplayNoRound



	; Temp needs to be rounded. If avg temp is positive, round up. If not, round down.
	_avgTempRound:
	MOV		EDX, avgTempInt
	MOV		avgTempIntRound, EDX
	CMP		avgTempInt, 0
	JL		_negativeNumRoundDown
	INC		avgTempIntRound
	JMP		_avgTempDisplayRounded
	_negativeNumRoundDown:
	DEC		avgTempIntRound

	; Displays the rounded up integer
	_avgTempDisplayRounded:
	MOV		EDX, OFFSET avgTempIntPrompt
	CALL	WriteString
	MOV		EAX, avgTempIntRound
	CALL	WriteInt				
	MOV		EDX, OFFSET degCelsius
	CALL	WriteString
	CALL	CrLf
	JMP		_avgTempDecimal


	; Displays avg integer temp
	_avgTempDisplayNoRound:
	MOV		EDX, avgTempRemainder
	MOV		EDX, OFFSET avgTempIntPrompt
	CALL	WriteString
	MOV		EAX, avgTempInt
	CALL	WriteInt				
	MOV		EDX, OFFSET degCelsius
	CALL	WriteString
	CALL	CrLf

; --------------------------
; Calculates the average temperature rounded to 2 decimal points.
; Multiply remainder by 100, divide this number by the number of temp readings. This will be the decimal.
; Ex: 35/4 = 8.75 or 8 r 3. multiply 3 by 100, and divide by 4 to get 75, for 8.75
; Displays the average temp rounded to 2 decimal points.
; --------------------------

	; Multiply remainder by 100, divide by the number of temp readings
	_avgTempDecimal:
	MOV		EAX, avgTempRemainder
	MOV		EBX, 100
	MUL		EBX					; Result stored in EAX
	MOV		EDX, 0				; IDIV preconditions: EDX must be cleared
	CDQ							; Sign extending EAX into EDX
	MOV		ECX, numOfTempReadings
	DIV		ECX
	MOV		avgTempDecimal, EAX 

	; Display the average temperature rounded to 2 decimal points
	MOV		EDX, OFFSET avgTempDecimalPrompt
	CALL	WriteString
	MOV		EAX, avgTempInt
	CALL	WriteInt
	MOV		EDX, OFFSET	decimal
	CALL	WriteString
	MOV		EAX, avgTempDecimal
	CALL	WriteDec
	CALL	CrLf
	

; --------------------------
; Displays number of cold, cool, warm, and hot days. 
; Displays farewell and ends program.
; --------------------------

	; Display number of cold days
	MOV		EDX, OFFSET coldPrompt
	CALL	WriteString
	MOV		EAX, numColdDays
	CALL	WriteDec
	CALL	CrLf

	; Display number of cool days
	MOV		EDX, OFFSET coolPrompt
	CALL	WriteString
	MOV		EAX, numCoolDays
	CALL	WriteDec
	CALL	CrLf

	; Display number of warm days
	MOV		EDX, OFFSET warmPrompt
	CALL	WriteString
	MOV		EAX, numWarmDays
	CALL	WriteDec
	CALL	CrLf

	; Display number of hot days
	MOV		EDX, OFFSET hotPrompt
	CALL	WriteString
	MOV		EAX, numHotDays
	CALL	WriteDec
	CALL	CrLf
	CALL	CrLf
	
	; Display farewell
	MOV		EDX, OFFSET farewell
	CALL	WriteString
	MOV		EDX, OFFSET username
	CALL	WriteString
	CALL	CrLf



	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
