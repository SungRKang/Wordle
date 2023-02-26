TITLE final.asm
; Program Description: This program will allow users to play either 1 player wordle or 2 player wordle
; Author: Sungwoo Kang
; Student ID; 107609094
; May 6 2022

INCLUDE C:\Irvine\Irvine32.inc; //Path to your Irvine
includelib C:\Irvine\irvine32.lib

;//Symbolic Constants
MaxStrLen = 51d
newline EQU <0Ah, 0Dh>


;// Description: Plays game in two player
;// Receives: nothing
;// Returns: nothing
;// Requires: nothign
;// main menu/driver taken from hw5 given

.data
theAnswer byte maxStrLen dup (0h)
userInput byte 6 dup (0h)
          byte 6 dup (0h)
          byte 6 dup (0h)
          byte 6 dup (0h)
          byte 6 dup (0h)
          byte 6 dup (0h)
          byte 5 dup (0h), 3
RealStrLen byte maxstrLen
userOption byte 0h
errormsg byte "You have selected an invalid option.", newline, "Please try again.", newline, 0h
semiEqualArray byte 5 dup(0), 3d ;//delimitted to 3d for seperation between 0
guesses byte 0h
rounds byte 0h
user1Wins byte 0h
user2Wins byte 0h
gameOver byte 0h
tempString byte 7 dup (0h)


.code
main PROC
;// Description:  
;// Receives: 
;// Returns: 
;// Requires: 
mov eax, 15 ;// reset formatting
call setTextColor
call clearRegs

starthere:

call clrscr
;// Display menu and get option
mov ebx, offset userOption
push ebx

call DisplayMenu

;// is option legal
cmp UserOption, 1d  ;// if below 1, invalid input
jb invalid
cmp UserOption, 3d  ;// if above 3, invalid input
ja invalid
cmp userOption, 3d  ;// if below or equal, valid input
jb driver
cmp userOption, 3d
jmp done

invalid:
;// display error message
push edx ;// save current value of edx
mov edx, offset errormsg
call writeString
call waitMsg
pop edx  ;// restore edx
jmp starthere

driver:
;// set up for the call
mov ebx, offset tempString
push ebx
mov ebx, offset gameOver
push ebx
mov ebx, offset guesses
push ebx
mov ebx, offset rounds
push ebx
mov ebx, offset user1wins
push ebx
mov ebx, offset user2wins
push ebx
mov edx, offset theAnswer
push edx
mov ebp, offset userInput
push ebp
mov ebx, offset semiEqualArray
push ebx

call PickaProc

jmp starthere

done:
exit
main ENDP

;// Procedures

pickaProc proc
;// Description:  Selects correct procedure to execute based on user option.
;// Receives:
 ;offset userinput
 ;offset theAnswer
 ; as stack
;// Returns: Nothing, but correct procedure is selected
;// Requires: EBX , ESI, all equal to zero

push ebp

;// is it 1
cmp al, 2    
jb option1

;// is it 2
cmp al, 3    
jb option2

;// must be 3
call opt3
jmp quitit

option1:
call opt1
jmp quitit

option2:
call opt2
jmp quitit

quitit:
pop ebp
ret
pickaProc ENDP
;//--------------------------------------------------------------------
DisplayMenu PROC
;// Description:  Clears all registers
;// Receives: Nothing
;// Returns: UserOption updated with userChoice
;// Requires: Offset of UserOption on top of stack

.data
MainMenu byte "Main Menu", newline,
"1.  Enter 1 for one player ", newline,
"2.  Enter 2 for two players ", newline,
"3.  Enter 3 to quit out" , newline,
"        Please make a selection ==>  ", 0h

.code
push ebp
mov ebp, esp
push edx
push ebx
mov edx, offset mainmenu
call writeString
call readDec
mov ebx, [ebp+8] ;//&userOption
mov byte ptr [ebx], al
pop ebx
pop edx
pop ebp
ret
DisplayMenu ENDP

;//---------------------------------------------------------------------
opt1 PROC
;// Description: Plays game in one player
;// Receives: stack frame
;// Returns: nothign
;// Requires: nothing
.data
singleWinMsg byte "Congratulations! You win!", 0h
singleLoseMsg byte "Sorry! You lose!", 0h
singleReportWin1 byte "You won in ", 0h
singleReportWin2 byte " guesses!", 0h
singleReport1 byte "Here are the list of words you tried.", 0h
singleReportLose1 byte "The correct word was ", 0h
singleReportLose2 byte " !", 0h
.code
;// Implement the concept of round here
;// Round > 7 = loss
call resetVec
call clrscr
push ebp
mov ebp, esp
mov eax, [ebp+40] ;// eax = &guesses
mov ecx, 0 ;// will be used to put values into guesses
mov ebx, [ebp+44] ;// ebx = &gameOver
mov edx, 0
mov [eax], edx ;// clear out guesses everytime
call chooseAnswer ;// theAnswer is populated with one of the options
singleRoundsLoop:
    call takeInput
    call push_back
    call compareStrings
    call print_color
    call crlf   
    call game_over
    mov dl, [ebx]
    cmp dl, 1
    je singleWin
    mov dl, [eax]
    cmp dl, 6
    je singleLoss
    inc ecx
    mov [eax], ecx
    jmp singleRoundsLoop
singleWin:
call crlf
call clrscr
mov edx, offset singleWinMsg
call writestring
mov edx, offset singleReportWin1
call writestring
mov ebx, eax
mov eax, 0
mov al, [ebx]
inc al
call writeDec
mov edx, offset singleReportWin2
call writestring
call crlf
mov edx, offset singleReport1
call writestring
call crlf
call printVec
call crlf
call waitmsg
jmp endSingle

singleLoss:
call crlf
call clrscr
mov edx, offset singleLoseMsg
call writestring
call crlf
mov edx, offset singleReport1
call writeString
call crlf
mov edx, offset singleReportLose1
call writestring
mov edx, [ebp+24] ;// &theAnswer
call writeString
mov edx, offset singleReportLose2
call writeString

call crlf
call printVec
call crlf
call waitmsg
jmp endSingle

endSingle:
pop ebp
ret
opt1 ENDP
;//--------------------------------------------------------------------------
opt2 PROC
;// Description: Plays game in two player
;// Receives: stackframe
;// Returns: nothing
;// Requires: nothing
;// https://www.youtube.com/watch?v=q59wap1ELQ4&ab_channel=sentdex I got the motivation here, check submitted pdf for rough psuedocode


.data
player1AnswerPrompt byte "Player 1, set the answer: ", 0h
versusLostRoundPrompt byte "Sorry You couldn't guesss the answer! The opponent gains a point. The score is now: ", 0h
colon byte " : ", 0h
player2AnswerPrompt byte "Player 2, set the answer: ", 0h
player1 byte "player1 ", 0h
player2 byte "player2 ", 0h
doubleRoundWinMsg byte "You got it right! +1 points for you.", 0h
doubleReportWin1 byte "You guessed it correctly in ", 0h
doubleReportWin2 byte " tries.", 0h
doubleRoundLoseMsg byte "You didn't get it. +1 points for the other player.", 0h
finalScoreMsg1 byte "The final score is ", 0h
finalScoreMsg2 byte "So ", 0h
finalScoreMsg3 byte "Wins!", 0h
randomTieMsg1 byte "The random number was ", 0h
.code
call resetVec
push ebp
mov ebp, esp
mov ecx, 0
mov esi, 0 ;// follows guesses
mov edx, [ebp+40] ;// &guesses
mov [edx], ecx
;mov cl, [edx]
mov ebx, [ebp+36] ;// &rounds
mov [ebx], ecx
;mov ch, [edx]
mov ecx, [ebp+44] ;// &gameover
mov [ecx], esi
;mov dl, [edx]
call clrscr


roundsLoop:
    mov edx, [ebp+40] ;//&guesses
    mov ch, 0
    mov [edx], ch
    call resetVec
    mov ebx, [ebp+36] ;// rounds
    mov ch, [ebx] 
    cmp ch, 4
    je judgement
    cmp ch, 0
    je player1Loop
    cmp ch, 2
    je player1Loop
    jmp player2Loop ;// rounds must be 1/3

player1Loop:
    call clrscr
    mov edx, offset player1AnswerPrompt
    call writeString
    call crlf
    call takeInput
    call copyAnswer
    call clrscr
    mov edx, offset player2
    call writestring
    mov edx, [ebp+28]
    jmp sharedLoop
    
player2Loop:
    call clrscr
    mov edx, offset player2AnswerPrompt
    call writeString
    call crlf
    call takeInput
    call copyAnswer
    call clrscr
    mov edx, offset player1
    call writestring
    mov edx, [ebp+32]
    jmp sharedLoop

sharedLoop:
    call takeInput
    call push_back
    call compareStrings
    call print_color
    call crlf   
    call game_over
    mov ecx, [ebp+44]; ;// &gameOver
    mov cl, [ecx]
    cmp cl, 1
    je whichPlayerWon
    mov ecx, [ebp+40] ;// &guesses
    mov cl, [ecx] 
    cmp cl, 6
    je whichPlayerLost
    mov ecx, 0
    mov ecx, [ebp+40] ;// &guesses
    mov bl, [ecx]
    inc bl
    mov [ecx], bl ;// guesses++
    jmp sharedLoop

whichPlayerWon:
    cmp edx, [ebp+32]
    je player1Win
    jmp player2Win
player1Win:
    mov edx, [ebp+32]
    mov al, [edx]
    inc al
    mov [edx], al
    jmp doubleWin
player2Win:
    mov edx, [ebp+28]
    mov al, [edx]
    inc al
    mov [edx], al
    jmp doubleWin
    
doubleWin:
    call crlf
    call clrscr
    mov edx, offset doubleRoundWinMsg
    call writestring
    mov edx, offset doubleReportWin1
    call writestring
    mov ecx, [ebp+40]
    mov al, [ecx]
    inc al
    call writeDec
    mov edx, offset doubleReportWin2
    call writestring
    call crlf
    mov edx, offset singleReport1
    call writestring
    call crlf
    call printVec
    call crlf
    call waitmsg
    mov edx, [ebp+36] ;//&rounds
    mov eax, 0
    mov al, [edx]
    inc al
    mov [edx], al ;//rounds++
    jmp roundsLoop

whichPlayerLost:
    cmp edx, [ebp+32] ;// is p1 playing?
    je player1Loss
    jmp player2Loss ;// then p2 must have lost
player1Loss:
    mov edx, [ebp+28] ;//user2Wins
    mov al, [edx]
    inc al
    mov [edx], al ;// user2Wins++
    jmp doubleLoss
player2Loss:
    mov edx, [ebp+32] ;//user1Wins
    mov al, [edx]
    inc al
    mov [edx], al ;// user1Wins++
    jmp doubleLoss

doubleLoss: 
    call crlf
    call clrscr
    mov edx, offset doubleRoundLoseMsg
    call writestring
    call crlf
    mov edx, offset singleReport1
    call writeString
    call crlf
    mov edx, offset singleReportLose1
    call writestring
    mov edx, [ebp+24] ;// &theAnswer
    call writeString
    mov edx, offset singleReportLose2
    call writeString
    call crlf
    call printVec
    call crlf
    call waitmsg
    mov edx, [ebp+36] ;// &rounds
    mov eax, 0
    mov al, [edx]
    inc al
    mov [edx], al ;//rounds++
    jmp roundsLoop

judgement:
    mov eax, [ebp+32] ;// &user1Wins
    mov cl, [eax]
    mov ebx, [ebp+28] ;// &user2Wins
    mov bl, [ebx]
    call clrscr
    mov edx, offset finalScoreMsg1
    call writeString
    mov eax, 0
    mov al, cl
    call writeDec
    mov edx, offset colon
    call writestring
    mov al, bl
    call writeDec
    call crlf
    cmp cl, bl
    je Tie ;// Most likely case 6/16 gamestates
    ja player1Wins ;// p1>p2
    jmp player2Wins ;// Must be p2>p1

player1Wins:
    mov edx, offset finalScoreMsg2
    call writeString
    mov edx, offset player1
    call writeString
    mov edx, offset finalScoreMsg3
    call writeString
    call crlf
    call waitmsg
    jmp endDouble

player2Wins:
    mov edx, offset finalScoreMsg2
    call writeString
    mov edx, offset player2
    call writeString
    mov edx, offset finalScoreMsg3
    call writeString
    call crlf
    call waitmsg
    jmp endDouble

Tie:
    mov eax, 10000d
    call randomize
    call randomRange
    mov ebx, 2
    mov edx, 0
    div ebx
    mov edx, offset randomTieMsg1
    call writeString
    call writeDec
    test al, 1
    jnz player1Wins ;//p1 wins if odd
    jz player2Wins ;//p2 wins if even

endDouble:
pop ebp
ret

opt2 ENDP



;//-----------------------------------------------------------------------------
opt3 PROC ;// Just here in case of an exit screen
;// Description:  
;// Receives:
;// Returns:
;// Requires:

ret
opt3 ENDP
;//-------------------------------------------------------------------------------


ClearRegs PROC
;// Description:  Clears all registers
;// Receives: Nothing
;// Returns: Nothing
;// Requires: Nothing

mov eax, 0
mov ebx, 0
mov ecx, 0
mov edx, 0
mov esi, 0
mov edi, 0
Ret
ClearRegs ENDP

;// ===================================================

TakeInput PROC
;// Description: Prompts user for a 5 letter word
.data
enterWordPrompt byte "Please Enter a word", newline, "   ==>  ", 0h
invalidInputPrompt byte "Invalid input, please try again", 0h

.code
push ebp
mov ebp, esp
push edx
push eax
push ecx
push ebx
mov eax, [ebp+48] ;//eax = offset guesses

;//I need to offset userInput based on number of guesses
;//=> index = guesses*6
mov al, [eax]
mov ebx, 0
mov bl, al ;// bl holds guesses
mov eax, 6 ;//
mul ebx ;// eax = guesses*6


alphaCheck:
mov edx, offset enterWordPrompt
call writeString ;//prompt user
mov edx, [ebp+56] ;//&tempString
mov ecx, 7
call readString
call CheckAlpha ; Checks if tempString is valid
cmp eax, 0
je nonAlpha
jmp allAlpha

nonAlpha:
mov edx, offset invalidInputPrompt
call writeString
call crlf
jmp alphaCheck

allAlpha:

pop ebx
pop ecx
pop eax
pop edx
pop ebp ;// Restore old base pointer
Ret
TakeInput ENDP

CheckCount PROC
;// Description: Checks userInput for 5 letters in the string. 
push ebp
push esi
mov ebp, esp
mov esi, [ebp+96];//offset tempstring
push ebx
push ecx
mov eax, 0
checkCountLoop:
    cmp eax, 5
    je goodCount
    mov bl, [esi]
    cmp bl, 0
    je badCount
    inc eax
    inc esi
    jmp checkCountLoop
goodCount: ;//reaches here if stringentered>=5
    ;// => we have to peek into next element to make sure its zero
    inc esi
    mov bl, [esi]
    cmp bl, 0
    je badCount ;//boots everything greater than size 5 to badcount

    mov eax, 1
    jmp endCount
badCount:
    mov eax, 0
    jmp endCount
endCount:
pop ecx
pop ebx
pop esi
pop ebp
ret
CheckCount ENDP

CheckAlpha PROC
;// Description: Checks userInput for non-alpha characters in the string
push ebp
push edx
mov ebp, esp
mov eax, [ebp+76] ;//offset guesses
mov edx, [ebp+84] ;// tempstring

call CheckCount
cmp eax, 0
je invalid
call convertLower
mov eax, 0
jmp whileLoop

whileLoop:
mov al, [edx]
cmp al, 0
je final

;check if current char is a-z or A-Z
cmp al, 'A' ; is the char below A
jb invalid
cmp al, 'Z' ; is it between A-Z?
jbe valid

;// reaches here when above Z in ascii
cmp al, 'a' ; is the char below a
jb invalid
cmp al, 'z' ; is the char below or equal to z
jbe valid
jmp invalid ; only case that reaches here is greater than z, => invalid

invalid:
; pass 0 to eax
mov eax, 0
pop edx
pop ebp
ret

valid:
; process next char
inc edx
jmp WhileLoop

final:
mov eax, 1
pop edx
pop ebp
ret
CheckAlpha ENDP

convertLower PROC
;// Description: converts tempString to lowercase
;// Requires: called within checkAlpha after nonalpha is accounted for
;// Returns: nothing
push ebp
push esi
push ebx
mov ebp, esp
mov eax, 0
mov ebx, 0

;//First find tempstring
mov esi, [ebp+100] ;// &tempString
lowerLoop:
    mov al, [esi]
    cmp al, 0
    je allLower
    OR al, 32 
    mov [esi], al
    inc esi
    jmp lowerLoop
allLower:
pop ebx
pop esi
pop ebp
ret
convertLower ENDP


ChooseAnswer PROC
;// Description: Picks a random word from a list
.data
index byte 0h
possibleWords byte "eager", 0h
              byte "apple", 0h
              byte "timer", 0h
              byte "eight", 0h
              byte "seven", 0h
              byte "jazzy", 0h
              byte "fixer", 0h
              byte "about", 0h
              byte "actor", 0h
              byte "doggy", 0h
              byte "acute", 0h
              byte "panic", 0h
              byte "grade", 0h
              byte "adult", 0h
              byte "basis", 0h
              byte "beach", 0h
              byte "argue", 0h
              byte "begin", 0h
              byte "event", 0h
              byte "error", 0h
              byte "brave", 0h
              byte "there", 0h
              byte "court", 0h
              byte "cream", 0h
              byte "steam", 0h
              byte "dance", 0h
              byte "doubt", 0h
              byte "final", 0h
              byte "floor", 0h
              byte "hotel", 0h
              byte "image", 0h
              byte "music", 0h
              byte "panel", 0h
              byte "phase", 0h
              byte "rugby", 0h
              byte "shirt", 0h
              byte "shift", 0h
              byte "sight", 0h
              byte "night", 0h
              byte "might", 0h
              byte "smile", 0h
              byte "smith", 0h
              byte "voice", 0h
              byte "whole", 0h

.code

push ebp
mov ebp, esp
mov esi, [ebp+32] ;// esi is now &theAnswer
push eax
push ebx
push ecx
push edx

call RandomNumber
mov ebx, 6
mul ebx ;// 6*eax
mov index, al
mov ebx, 0
mov edx, [ebp+32] ;//edx contains offset theAnswer
;// first loop through string chosen
movzx edi, index
possibleWordsLoop:
mov eax, 0
mov al, possibleWords[edi]
cmp al, 0
je finished
jmp notFinished
notFinished:
call replaceLetter
inc ebx
inc edi
jmp possibleWordsLoop

finished:
pop edx
pop ecx
pop ebx
pop eax
pop ebp
Ret
ChooseAnswer ENDP

replaceLetter PROC
;// Description: Takes letter in eax
;takes place in ebx
;replaces letter in spot
push edx
add edx, ebx
mov [edx], al
pop edx
ret
replaceLetter ENDP

RandomNumber PROC
;// Description: Picks a random number and stores it in eax
.code
call randomize
mov eax, 23d
call RandomRange
Ret
RandomNumber ENDP


compareStrings PROC
;// Description: Populates semiEqualArray with 0 = char doesnt exist, 1 = char exists, wrong place, 2 = char exists, right place 
;// Returns: 
.code


push ebp
mov ebp, esp
push eax
push ebx
push ecx
push edx

mov edi, [ebp+32] ;//offset theAnswer
mov esi, [ebp+56] ;//offset tempstring
mov edx, [ebp+24] ;//offset semiEqualArray
mov eax, [ebp+48] ;//offset guesses
mov ebx, 0 ;//holder for each char of semiEqualArray
mov ecx, 5
push edx
;// first reset semiEqualArray to 0's for repeat use
zeroLoop:
    mov bl, 0
    mov [edx], bl
    inc edx
    loop zeroLoop ;// will loop through zeroLoop 5 times
pop edx
;// Tested in c++
;// for(int i=0; i <5; i++)
    ;{
     ; for(int j =0; j <5; j++)
       ; {
       ;   if (userInput[i] == theAnswer[j])
        ;  {
        ;    if (i==j)
         ;   {
         ;     newString[i] = 2;
         ;   }
         ;   else
         ;     newString[i] = 1;
        ;  }
        ;}
   ; }
mov eax, 0
mov ebx, 0 ;//will be used as i
mov ecx, 0 ;//will be used as j
forLoopOut:
    push edi ;// have to store edi
    mov ecx, 0
    mov ah, [esi]
    cmp ah, 0
    je endproc
forLoopIn:
    mov al, [edi]
    cmp al, 0
    je endForLoopOut
    inc edi
    cmp al,ah
    je equalChar
    inc ecx
    jmp forLoopIn
    endforLoopOut:
    pop edi ;// restore edi
    inc esi
    inc ebx
    jmp forLoopOut

EqualChar: ;//(if(userInput[i] == theAnswer[j]))
    mov al, [edx+ecx]
    cmp al, 2
    je alreadyHappen
EqualCharJump:
    cmp ebx, ecx ;//if i==j
    je rightSpot
    ;//else
    mov al, 1
    mov [edx+ebx], al
    pop edi ;// restore edi
    inc esi
    inc ebx
    jmp forLoopOut
alreadyHappen:
    inc ecx
    jmp forLoopIn
rightSpot: ;//if i==j
   
    mov al, 2
    mov [edx+ebx], al
    pop edi ;// restore edi
    inc esi
    inc ebx
    jmp forLoopOut
endproc:
pop edi ;// have to balance  last edi push
pop edx
pop ecx
pop ebx
pop eax
pop ebp
RET
compareStrings ENDP

push_back PROC
;// Description: This function will take a string push it into array
push eax
push ebx
push ecx
push edx
push ebp
push esi
mov ebp, esp
mov esi, [ebp+48] ;// offset userInput
mov ebx, [ebp+68] ;// offset guesses
mov bl, [ebx] ;// ebx = guesses
mov eax, 6
mul bl ;// eax = 6*guesses
mov edx, [ebp+76] ;// offset tempstring
mov ecx, eax

incrementer:
    cmp ecx, 0
    je pushBackLoop
    inc esi
    dec ecx
    jmp incrementer
    

pushBackLoop:
    ;// Loop through tempstring
    mov bl, [edx] 
    cmp bl, 0
    je doneBackLoop
    mov [esi], bl
    inc esi
    inc edx
    jmp pushBackLoop
doneBackLoop:
pop esi
pop ebp
pop edx
pop ecx
pop ebx
pop eax
ret
push_back ENDP

resetVec PROC
;// Description: This function will clear out the vector of strings
push eax
push ebx
push ecx
push edx
push ebp
push esi
mov ebp, esp
mov esi, offset userInput ;// offset userInput

resetLoop:
    mov bl, [esi]
    cmp bl, 3
    je doneResetLoop
    mov bl, 0
    mov [esi], bl
    inc esi
    jmp resetLoop
doneResetLoop:
pop esi
pop ebp
pop edx
pop ecx
pop ebx
pop eax
ret
resetVec ENDP

print_color PROC
;//Prints the sequence of underscores and colors
.data
colors byte " | | | | ", 3d ;//i set 3 as the delimitter to loop through it easier
.code
;// first recieve the semiEqualArray from the stack

push ebp
mov ebp, esp
push eax
push ebx
push ecx
push edx
mov ebx, [ebp+24] ;// ebx = offset semiEqualArray
mov ecx, 0
mov edx, 0
mov esi, 0 ;// esi=i
mov edi, 0 ;// edi =j
outerLoop:
    mov cl, colors[esi] ;// cl now contains colors[i]
    cmp cl, 3d ;//delimitter for colors
    je allDone
    cmp cl, '|'
    je isBar ;// | = no formatting
    mov dl, [ebx+edi] ;// bl = semiEqualArray[j]
    cmp dl, 1
    jb blackBackGround ;// 0 = doesn't exist in answer
    je yellowBackGround ;// 1 = exists but wrong place
    ja blueBackground ;// 2 = exists and is write place
    ;// it HAS to be 0,1,2,3 => no need for exception case
isBar:
    mov eax, ecx
    call writeChar
    inc esi
    jmp outerLoop
blackBackGround:
    ;// this is regular fomatting. remember to reset other colors 
    mov eax, ecx ;// eax = colors[i]
    call writeChar
    inc esi
    inc edi
    jmp outerLoop
yellowBackGround:
    mov eax, 239 ;//white text with yellow background
    call setTextColor
    mov eax, ecx ;// eax = colors[i]
    call writeChar
    mov eax, 15 ;// reset formatting
    call setTextColor
    inc esi
    inc edi
    jmp outerLoop
blueBackGround:
    mov eax, 31 ;// white text with blue background
    call setTextColor
    mov eax, ecx ;// eax = colors[i]
    call writeChar
    mov eax, 15 ;// reset formatting
    call setTextColor
    inc esi
    inc edi
    jmp outerLoop

allDone:
pop edx
pop ecx
pop ebx
pop eax
pop ebp
ret
print_color ENDP

game_over PROC
;// description: checks that the user guessed the word
;// loop through semiEqual Array and if all 2's then set gameOver to 1
push ebp
push eax
push ebx
push ecx
push edx
mov ebp, esp
mov esi, [ebp+40] ;// &semiEqualArray
mov edx, [ebp+68] ;// &gameOver
mov edi, 0
mov ecx, 0
mov [edx], cl ;// reset gameOver to 0 everytime check is called
mov ebx, 0

isItOverLoop:
    mov bl, [esi]
    cmp bl, 2
    jb end_game
    cmp bl, 3 ;// hit delimitter
    je allTwos
    inc esi
    jmp isItOverLoop
allTwos:
    mov ecx, 1
    mov [edx], ecx
    jmp end_game
end_game:
pop edx
pop ecx
pop ebx
pop eax
pop ebp
ret
game_over ENDP

printVec PROC
;// Description: prints the array of strings to terminal

push ebp
push eax
push ebx
push edx
mov ebp, esp
mov edx, [ebp+20] ;// &UserInput
;// we know the exact size of vector at this point, 6x7
;// when reading 0 in userInput print space
;// Stop looping when reaching 3

printerLoop:
    mov eax, 0
    mov al, [edx]
    cmp al, 3
    je readThree
    cmp al, 0
    je readZero
    call writeChar
    inc edx
    jmp printerLoop


readZero:
    mov eax, 20h
    call writeChar
    inc edx
    jmp printerLoop

readThree:
pop edx
pop ebx
pop eax
pop ebp
ret
printVec ENDP

takeAnswer PROC

.code
push ebp
mov ebp, esp
push edx
push eax
push ecx
push ebx
push esi

alphaCheck:
mov edx, offset enterWordPrompt
call writeString ;//prompt user
mov edx, [ebp+56] ;//&tempString
mov ebx, [ebp+32] ;//&theAnswer

mov ecx, 7
call readString
call CheckAlpha ; Checks if tempString is valid
cmp eax, 0
je nonAlpha
jmp allAlpha

nonAlpha:
mov edx, offset invalidInputPrompt
call writeString
call crlf
jmp alphaCheck

allAlpha:
call copyAnswer
pop esi
pop ebx
pop ecx
pop eax
pop edx
pop ebp ;// Restore old base pointer
Ret

takeAnswer ENDP

copyAnswer PROC
;// Description: Takes user input in tempstring and copies into theAnswer
push ebp
push ebx
push edx
push ecx
mov ebp, esp
mov edx, [ebp+68];//&tempstring
mov ebx, [ebp+44];//&theAnswer
mov eax, 0;
copyAnswerLoop:
    mov cl, [edx]
    mov [ebx], cl
    inc edx
    inc ebx
    cmp cl, 0
    jne copyAnswerLoop
pop ecx
pop edx
pop ebx
pop ebp
ret
copyAnswer ENDP

END main