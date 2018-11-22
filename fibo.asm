; Assembler = x86 (NASM)
; Program Name : Fibonacci Sequence
;
; Class:        DISM/FT/1b/22
; Student ID:   P1804317
; Name:         Ng Wen Jie Dalton Ng
;
; Assignment Number : Practical 5, Ca1, Question 1
; Date Written : 11 May 2018
;
; PROBLEM STATEMENT
; 
;   +-----------------+
;   | MAIN ALGORITHIM | >> PROGRAM FLOWS FROM 1 --> 2 --> 3
;   +-----------------+   
;   |
;   |   +---------------+---+
;   +-->| INPUT PORTION | 1 |
;       +---------------+---+-------------------------------------------------------------------------------+
;       | Print 'Enter a value between 3 and 25 (inclusive):'                                               |
;       | Obtain user input, store in loopCount for reference, store in eax for immediate usage.            |
;       | If the number input is out of range, recursively prompt the user to enter a number in range.      |
;   +---| Continues when Input is within the range of 3-25 (inclusive)                                      |
;   |   +---------------------------------------------------------------------------------------------------+
;   |
;   |   +--------------------------+---+
;   +-->| FIBO CALCULATION PORTION | 2 |
;       +--------------------------+---+--------------------------------------------------------------------+
;       | >>> Note: so we don't run out of registers, the 16bit register bx is used for most calculations.  |
;       | >>> We use jmp to loop here, we have the value of the INDEX and the remainingLoops                |
;       | sum = fibo(INDEX - 2) + fibo(INDEX - 4)                                                           |
;       | fibo(INDEX) = sum                                                                                 |
;       | If remainingLoops == 0 --> Continue                                                               |
;   +---| Else --> Index + 1, remainingLoops - 1, Loop!                                                     |
;   |   +---------------------------------------------------------------------------------------------------+
;   |
;   |   +-------------------------+---+
;   +-->| PRINTING OUTPUT PORTION | 3 |
;       +-------------------------+---+---------------------------------------------------------------------+
;       | Print 'Fibonacci sequence for LOOPCOUNT(e.g 20) values is:'                                       |
;       | Loop Through the Array fibo                                                                       |
;       | --> And Print on a new line every number in the array fibo                                        |
;       | END PROGRAM                                                                                       |
;       +---------------------------------------------------------------------------------------------------+
;
;
;
;   +-----------------+
;   | MAJOR VARIABLES |
;   +-----------------+
;       
;       +-------------------+---+---------------------------------------------------------------------------+
;       | NAME              | DESCRIPTION                                                                   |
;       +-------------------+-------------------------------------------------------------------------------+
;       | string_prompt_msg | Contains our initial prompt message. Will run on first and for reentry.       |
;       |                   | Value : "Enter a value between 3 and 25 (inclusive): "                        |
;       +-------------------+-------------------------------------------------------------------------------+
;       | string_error_msg  | Contains a prompt to tell the user that the input is out of range.            |
;       |                   | Value : "Your value was not within the range. Reenter!"                       |
;       +-------------------+-------------------------------------------------------------------------------+
;       | string_fibo1_msg  | Contains the first half of the message to display to the user when displaying |
;       |                   | the fibonacci sequence. Fully formatted message would look like, 'Fibonacci   |
;       |                   | sequence for X values is: '.                                                  |
;       |                   | Value : "Fibonacci sequence for "                                             |
;       +-------------------+-------------------------------------------------------------------------------+
;       | string_fibo2_msg  | Contains the second half of the message to display to the user when           |
;       |                   | displaying the fibonacci sequence. Fully formatted message would look like,   |
;       |                   | 'Fibonacci sequence for X values is: '.                                       |
;       |                   | Value : " values is:"
;       +-------------------+-------------------------------------------------------------------------------+
;       | loopCount         | Store the user-inputted variable for how many times to perform the fibo       |
;       |                   | calculation.                                                                  |
;       +-------------------+-------------------------------------------------------------------------------+
;
;
;
;   +---------------------+
;   | PROGRAM LIMITATIONS |
;   +---------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | Since fibo is an array of 25 words. We are only able to display the first 25 sequences of the     |
;       | fibonacci sequence. (ie. 0 --> 46368). However as the program requirements require for the range  |
;       | of 3 --> 25 for user input, this program limitation is fine.                                      |
;       +---------------------------------------------------------------------------------------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | This program will not work in the built in SASM ide testing if the number is out of range.        |
;       | Since SASM uses the same input for each iteration. In order to use the checkInputRange subroutine |
;       | the program must be exported as an executable (.exe) and run from command prompt.                 |
;       +---------------------------------------------------------------------------------------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | We do not need to catch any overflows since we know the maximum fibonacci sequence will be 46368, |
;       | since a word can store a value up too 65535, the maximum fibonacci sequence is within range.      |
;       +---------------------------------------------------------------------------------------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | GET_DEC behaves very wierdly if you enter a character(e.g A)instead of a number, the program goes |
;       | into an infinite loop in the checkInputRange subroutine. checkInputRange subroutine is able       |
;       | to handle a value of 0. I was unable to find documentation on GET_DEC beyond the help menu        |
;       | in SASM. I suspect that the issue is along the lines of the char being stuck inside the           |
;       | input buffer, so when we run GET_DEC again, it immediately uses the value inside the buffer, thus |
;       | causing an infinite loop. However, that is nothing more than a baseless theory.                   |
;       +---------------------------------------------------------------------------------------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | If the user just presses enter without entering anything in an attempt to enter a null value,     |
;       | the cursor will shift to the next line, user cannot enter a null input in command prompt.         |
;       | The [Enter] key will only have an effect after a number is entered. Entering 0 however is valid.  |
;       | Entering 0 will get caught by the checkInputRange subroutine.                                     |
;       +---------------------------------------------------------------------------------------------------+



%include "io.inc" ; Import the library for our input and output operations



; Section to Store Variables
; +----------------------------------------------------------------------------------+
section .data ; Variables

 string_prompt_msg: DB "Enter a value between 3 and 25 (inclusive): ", 0h ; Store our initial prompt message
  string_error_msg: DB "Your value was not within the range. Reenter!", 0h ; Store a reenter prompt message
  string_fibo1_msg: DB "Fibonacci sequence for ", 0h ; Store the first half of the message to display during the sequence print
  string_fibo2_msg: DB " values is:", 0h ; Store the second half of the message to display during the sequence print
         loopCount: DW 0 ; Store the user-inputted variable for how many times to perform the fibo calculation
              fibo: times 25 DW 0 ; Fibo Array, to store the fibonacci sequence
              zero: equ 0 ; Zero = 0, for readability
; +----------------------------------------------------------------------------------+



; Start of program
; +----------------------------------------------------------------------------------+
section .text ; Actual Code
global _main ; Main Program
_main:
; +----------------------------------------------------------------------------------+
    PRINT_STRING string_prompt_msg ; Prompt the user to enter between 3 and 25.
    
    xor eax, eax ; reset eax to all 0's
    ; eax will be used as the loop counter. Our max is only 25 here, so a 16 bit register is more than enough.
    
    xor edx, edx ; reset dx to all 0's
    add edx, 2 ; edx will be used as the index
    
    GET_DEC 2, loopCount ; This determines the number of times we need to loop.
    movzx eax, word[loopCount] ; Store it in loopCount, so we can reference the orignal value later
    
    call checkInputRange ; Check if the number is within range. Number to be tested is in eax!
    
    sub eax, 2 ; Set index to 2 ( By right index 3, but array starts from index 0 )
    ; This makes us loop as if we are starting from the starting index.

    xor bx, bx ; reset bx to all 0'
    ; bx will be used to calculate the sum, this is needed for us to calculate the fibonacci sequence later.
    ; bx is a 16 bit register, as the maximum number we need to calculate up to is 46368, 16 bit register is enough.

    ; Inserting the first 2 values into the fibo array
    mov word[fibo], 0 ; fibo(0) = 0
    mov word[fibo + 2], 1 ; fibo(1) = 1

    fiboLoop:
    ; +----------------------------------------------------------------------------------+
        ; Main Fibonacci addition portion. bx acts as an intermediate register for us to perform the calculation.
        xor bx, bx ; reset bx to all 0's
        add bx, word[fibo - 4 + edx * 2] ; Add the value in numberOne(number at index - 2) to bx, on first loop this is 0.
        add bx, word[fibo - 2 + edx * 2] ; Add the value in numberTwo(number at index - 1) to bx, on first loop this is 0.
        add word[fibo + edx * 2], bx ; Add the value to the array fibo.
        
        cmp eax, zero ; < If eax = null >
            je print ; goto to print:
        dec eax ; ensure we loop the correct number of times so --eax so we'll eventually hit 0
        inc edx ; point to next index by ++edx
        jmp fiboLoop ; Loop again!!
        
    print: ; Initial Print of message 'Fibonacci sequence for 25 values is: '
    ; +----------------------------------------------------------------------------------+
        ; Print Message
        NEWLINE ; Move the cursor to a new line
        PRINT_STRING string_fibo1_msg ; Print 'Fibonacci sequence for '
        PRINT_DEC 2, loopCount ; Print the value the user input at the start
        PRINT_STRING string_fibo2_msg ; Print ' values is:'
        NEWLINE
        
        ; Prep the registers for the PRINTLOOP
        movzx ecx, word[loopCount] ; ECX will be our loop counter, copy the value in loopCount to ecx
        xor edx, edx ; reset edx to all 0's
        
        printLoop:
        ; +----------------------------------------------------------------------------------+
            PRINT_UDEC 2, [fibo + edx * 2] ; Print the fibo sequence for the specified index. x2 as a word is 2 bytes.
            NEWLINE ; Move the cursor to a new line
            cmp ecx, 1 ; < If eax = 1 >
                je end ; goto to END:
            inc edx ; point to next index by ++edx
            dec ecx ; ensure we loop the correct number of times so --ecx so we'll eventually hit 0
            jmp printLoop ; Loop again!! 
            
end:
; +----------------------------------------------------------------------------------+
    ; Reset the registers
    xor eax, eax ; Reset to all 0's
    ret ; End Program                           
                                                
; +----------------------------------------------------------------------------------+



; Subroutine to ensure the user enters a number that's within range.
checkInputRange: ; Check if loopCount is 3 >= x >= 25
; +----------------------------------------------------------------------------------+
   
        ; if userInput < 3
        cmp eax, 3 ; Compare the user input number against 3
            jl inputOutOfRange ; Jump to inputOutOfRange if userInput < 3
        ; else if userInput > 25
        cmp eax, 25 ; Compare the user input number against 25
            jg inputOutOfRange ; Jump to inputOutOfRange if userInput > 25
        ; else
            jmp inputInRange   ; Jump to inputinRange
        
        inputOutOfRange:
            NEWLINE ; Move cursor to a new line
            PRINT_STRING string_error_msg ; Print that the value is out of range and ask user to reenter.
            NEWLINE ; Move cursor to a new line
            PRINT_STRING string_prompt_msg ; Prompt the user to enter between 3 and 25.
            
            GET_DEC 2, loopCount ; This determines the number of times we need to loop.
            movzx eax, word[loopCount] ; Store it in loopCount, so we can reference the orignal value later.
            jmp checkInputRange ; jmp to the start of the function.  
            
        inputInRange:
ret ; Return!!
; +----------------------------------------------------------------------------------+