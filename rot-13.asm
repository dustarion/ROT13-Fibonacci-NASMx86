; Assembler = x86 (NASM)
;
; Rot13 Cipher
; ROT13 is a special case of the Caesar cipher, developed in ancient Rome. 
;
; Class:        DISM/FT/1b/22
; Student ID:   P1804317
; Name:         Ng Wen Jie Dalton Ng
;
; Assignment Number : Practical 5, Ca1, Question 2
; Date Written : 11 May 2018
;
; PROBLEM STATEMENT
; 
;   +-----------------+
;   | MAIN ALGORITHIM | >> PROGRAM FLOWS FROM 1 --> 2
;   +-----------------+   
;   |
;   |   +---------------+---+
;   +-->| INPUT PORTION | 1 |
;       +---------------+---+-------------------------------------------------------------------------------+
;       | Print 'Enter a string (Max=64 characters) : '                                                     |
;       | Obtain user input, store in string_in for reference.                                              |
;   +---| Set index to 0. ebx used for index so we xor ebx.                                                 |
;   |   +---------------------------------------------------------------------------------------------------+
;   |
;   |   +--------------------------------+---+
;   +-->| ROTATION LOOP + OUTPUT PORTION | 2 |
;       +--------------------------------+---+--------------------------------------------------------------+
;       | Read the character in string_in at the index(ebx). Move and extend this into ax. ( char = 8 bit,  |
;       | ax = 16 bit register ).                                                                           |
;       | Check if char is null. If null continue to next portion. ( End of string )                        |
;       | By using the ASCII value,                                                                         |
;       | Check if the char is uppercase alphabet, if it is, set the character shift to 65.                 |
;       | Next, check if the char is lowercase alphabet, if it is, set the character shift to 97.           |
;       | Else, the char is not one we need to rotate, and we should not touch the char.                    |
;       |   Print the char untouched. Loop Again.                                                           |
;       |                                                                                                   |
;       | Character is at this point either lowercase or uppercase alphabet.                                |
;       | CharacterShift is either 65 or 97.                                                                |
;       | Using the ASCII value of the char,                                                                |
;       | Char = Char - CharacterShift ( A=0, B=1, C=2... )                                                 |
;       | Char = (Char - 13) % 26                                                                           |
;       | Char = Char + CharacterShift                                                                      |
;       | Print the Rotated Char.                                                                           |
;       | Loop Again!!                                                                                      |
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
;       | string_msg        | Contains our initial prompt message. Will run on first run only.              |
;       |                   | Value : "Enter a string (Max=64 characters) : "                               |
;       +-------------------+-------------------------------------------------------------------------------+
;       | string_in         | Store the user-inputted string for us to reference and iterate through.       |
;       |                   | We will rotate every alphabetical character in string_in using the rot-13.    |
;       +-------------------+-------------------------------------------------------------------------------+
;
;
;
;   +---------------------+
;   | PROGRAM LIMITATIONS |
;   +---------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | We can only accept an input string of up to 64 characters, however this can easily be changed     |
;       | Where x is the number of characters we want to accept,                                            |
;       | x = x + 1                                                                                         |
;       | string_in:  times x db 0h                                                                         |
;       | GET_STRING string_in, x                                                                           |
;       +---------------------------------------------------------------------------------------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | We do not need to catch any overflows since we know the maximum dec will not overflow as we       |
;       | control the input. The biggest char we allow through, 122/lowercase z, will not cause an overflow |
;       +---------------------------------------------------------------------------------------------------+
;
;       +---------------------------------------------------------------------------------------------------+
;       | If the user just presses enter without entering anything in an attempt to enter a null value,     |
;       | the cursor will shift to the next line, user cannot enter a null input in command prompt.         |
;       | The [Enter] key will only have an effect after a char is entered. Entering 0 however is valid.    |
;       | Entering 0 will get caught by the checkIfUpperCase, checkIfLowerCase part of the rotLoop          |
;       +---------------------------------------------------------------------------------------------------+


%include "io.inc" ; Import the library for our input and output operations



; Section to Store Variables
; +----------------------------------------------------------------------------------+
section .data
     string_msg: db "Enter a string (Max=64 characters) : ", 0h ; Initial User Prompt Message
      string_in:  times 65 db 0h ; max = 64 char, last ch=null
; +----------------------------------------------------------------------------------+



; Start of program
; +----------------------------------------------------------------------------------+
section .text
global _main
_main:
    PRINT_STRING string_msg  ; Prompt user to enter a string
    GET_STRING string_in, 65 ; and store in string_in
    NEWLINE ; Move the cursor to the next line

    ; init value to process input string
    xor ebx, ebx ; set ebx to all 0's
    xor eax, eax ; set eax to all 0's
    
    ; rotLoop
    ; Performs the rot13...
    ; ebx is used for the string index
    ; ax is used as the intermediate register
    rotLoop:
        movzx ax, byte[string_in + ebx] ; read each character from string_in, for the index specified by ebx
        ; movzx stores 1 byte in a 2 byte register. This is done so that the modulo can be done easily later
        ; ax now contains the byte of the character in its ascii code
        
        ; Checking of character in ax
            ; Ignore anything other than alphabet.
            
            ; IF STRING HAS ENDED >> END
            ; checkIfNull
            ; ax == 0
                cmp ax, 0 ; Check if the character is Null
                    je end ; Jump out of the loop straight to end. 
                 
            ; IF CHAR IS NOT ALPHABET >> next_char
            ; Also determine if character is uppercase or lowercase if it is an alphabet.
            checkIfUpperCase:
            ; +----------------------------------------------------------------------------------+
                cmp ax, 'A' ; compare al with "A" (upper bound)
                    jl nextChar ; jump to nextChar if less
                cmp ax, 'Z' ; compare al with "Z" (lower bound)
                    jg checkIfLowerCase ; jump to checkIfLowerCase if less
                jmp upperCaseChar ; Go to upperCaseChar, to process an uppercase character correctly.
            
            checkIfLowerCase:
            ; +----------------------------------------------------------------------------------+
                cmp ax, 'a' ; compare al with "A" (upper bound)
                    jl nextChar ; jump to next character if less
                cmp ax, 'z' ; compare al with "Z" (lower bound)
                    jg nextChar ; jump to next character if less
                jmp lowerCaseChar ; Go to lowerCaseChar, to process a lowercase character correctly.
                              
            upperCaseChar: ; If uppercase character, set characterShift to 65
            ; +----------------------------------------------------------------------------------+
                mov cx, 65 ; Move 65 into the cx Register
                jmp stayOnChar ; Else just continue on as per normal
            
            lowerCaseChar: ; If lowercase character, set characterShift to 97
            ; +----------------------------------------------------------------------------------+
                mov cx, 97 ; Move 97 into the cx Register
                jmp stayOnChar ; Else just continue on as per normal
            
        ; Issue with character, skip it and move on to the next character.
        ; Issue, not an alphabet based on standard ascii table. Could be a special character or a space.. etc.
        nextChar:
        ; +----------------------------------------------------------------------------------+
            PRINT_CHAR ax ; Print the unsubsituted letter
            inc ebx ; ebx ++
            jmp rotLoop ; Loop!! In order to encode more letters
            
; No Issue with character, continue as per normal.
stayOnChar:
; +----------------------------------------------------------------------------------+   
    sub ax, cx ; Subtract 65/97 so that A = 0, B = 1, C = 2... etc
    
    ; Caesar cipher substitution function
    ; e(al) = (al + 13) (mod 26)
    ; eg. e(22) = (22+13) (mod 26), remainder of 35/26 = 9
    add ax, 13 ; al = (al + 13)
    
    ; ah = ax % 26
    ; dl is just used here as an intermediate register
    mov dl, 26 ; bl = 26
    div dl ; Divide 26(dl) by ax. Remainder stored in ah. al contains the quotient.
    
    ; Translate the value in ah back to the ascii code of an actual character.
    add ah, cl ; ah = ah + 65/97
                
    PRINT_CHAR ah ;Print the 'rotated' letter
    
    inc ebx ; ebx ++
    jmp rotLoop ; Loop!! In order to encode more letters.		   

end:	
; +----------------------------------------------------------------------------------+

    ; Reset the registers!							
    xor eax, eax ; Reset the eax register to all 0's
    ret ; Terminate Program
; +----------------------------------------------------------------------------------+