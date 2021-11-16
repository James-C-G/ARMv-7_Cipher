@	Authors : 		Jamie G & Callum A
@	Version : 		1.4
@	Title : 		cipher.s
@	Last Updated : 	02/11/19
@	Description : 	One-Time Pad cipher program. Takes from stdin and strips to lowercase, alphabet characters
@				  	and encrypts/decrypts them as specified by the command line args in the following order:
@
@						cat textFile.txt | cipher opMode keyOne keyTwo | cipher opMode keyOne keyTwo
@
@					where opMode = 0 || 1  -- (encrypt || decrypt), keyOne is the first key and keyTwo is the
@					second.
@
@					The keys must also be co-prime in lengths, this is accomplished by using gcd and having
@					accomplished a product of 1.
@
@					Finally the cipher/plain text is outputted through stdout.

.data
.balign 4
errorMessage: .asciz "Key lengths are not co-prime." @ Error message assigned
.text
.global main

@ int main(int argc, char** argv)
main:
	PUSH {r12,lr} @ preserve link register (and keep stack 8bit aligned)

	LDR r0, [r1, #4] @ r0 = mode pointer

	LDR r4, [r1, #8] @ r4 = key1 pointer
	LDR r5, [r1, #12] @ r5 = key2 pointer

	MOV r6, #0 @ r6 = 0 // r6 = key1 index
	MOV r7, #0 @ r7 = 0 // r7 = key2 index

	LDRB r8, [r0], #1 @ r8 = 48 || 49 // r8 = encrypt/decrypt

	MOV r0, r4 @ r0 = r4 // r0 = key1 pointer
	BL keyLength @ keyLength(r0)
	MOV r9, r0 @ r9 = r0 // r9 = key1 length

	MOV r0, r5 @ r0 = r5 // r0 = key2 pointer
	BL keyLength @ keyLength(r0)
	MOV r10, r0 @ r10 = r0 // r10 = key2 length

	MOV r1, r9 @ r1 = r9 // r1 = key1 length

	BL gcd @ gcd(r0, r1)
	CMP r0, #1 @ compares gcd output to 1
	BNE notCoprime @ if r0 != 1

	mainLoop:
		BL getchar @ get char from stdin
		CMP r0, #-1 @ check if EOF reached
		BEQ endMain @ if EOF reached end

		BL stripToAlpha @ stripToAlpha(r0)
		CMP r0, #0
		BEQ mainLoop @ if return 0, next char

		CMP r6, r9 @ r6 = key1 index, r9 = key1 length
		BNE keyCheckOne @ if r6 != r9
		MOV r6, #0 @ r6 = 0 // reset key1 index
		keyCheckOne:
		LDRB r1, [r4, r6] @ r1 = key1 char at index

		CMP r8, #49 @ if encrypt/decrypt
		BNE opOne @ if encrypt then branch
		BL decrypt @ else decrypt(r0, r1)
		B opOneEnd @ jump to end
		opOne:
		BL encrypt @ encrypt(r0, r1)
		opOneEnd:

		CMP r7, r10 @ r7 = key2 index, r10 = key2 length
		BNE keyCheckTwo @ if r7 != r10
		MOV r7, #0 @ r7 = 0 // reset key2 index
		keyCheckTwo:
		LDRB r1, [r5, r7] @ r1 = key2 char at index

		CMP r8, #49 @ if encrypt/decrypt
		BNE opTwo @ if encrypth then branch
		BL decrypt @ else decrypt(r0, r1)
		B opTwoEnd @ jump to end
		opTwo:
		BL encrypt @ encrypt(r0, r1)
		opTwoEnd:

		BL putchar @ putchar(r0) // puts ciphered char to stdout

		ADD r6, r6, #1 @ r6 ++
		ADD r7, r7, #1 @ r7 ++

		B mainLoop @ continue

	notCoprime:
	LDR r0, =errorMessage @ r0 = errorMessage
	BL printf @ printf("%s", errorMessage)
	endMain:
	MOV r0, #10 @ r0 = 10 // r0 = new line char
	BL putchar @ putchar(r0)
	POP {r12,lr} @ restore link register
	BX lr @ exit

@ 	mainLoop.c
@	void mainLoop(char* keyOne, char* keyTwo, int keyOneLen, int keyTwoLen, int opMode)
@	{
@		char temp;
@ 		char keyChar;
@ 		int keyOneIndex = 0;
@		int keyTwoIndex = 0;
@		do
@		{
@			temp = getchar();
@			temp = stripToAlpha(temp);
@			if (temp == 0) continue;
@			if (keyOneIndex == keyOneLen)
@			{
@				keyOneIndex = 0;
@			}
@			else
@			{
@    			keyChar = keyOne[keyOneIndex];
@			}
@			if (opMode == 0)
@			{
@				temp = encrypt(temp, keyChar);
@			}
@			else
@			{
@				temp = decrypt(temp, keyChar);
@			}
@
@			if (keyTwoIndex == keyTwoLen)
@			{
@				keyTwoIndex = 0;
@			}
@			else
@			{
@    			keyChar = keyTwo[keyTwoIndex];
@			}
@			if (opMode == 0)
@			{
@				temp = encrypt(temp, keyChar);
@			}
@			else
@			{
@				temp = decrypt(temp, keyChar);
@			}
@			putchar(temp);
@			keyOneIndex ++;
@			keyTwoIndex ++;
@		}while (temp != EOF);
@	}



@	Calculates the length of a given key by its pointer
@	param r0 - key pointer
@ 	return r0 - length of key
keyLength:
	MOV r1, #0 @ r1 = 0 // set counter
	keyLenLoop:
		LDRB r2, [r0, r1] @ r2 = r0[r1] // r2 = char in arg pointer
		CMP r2, #0 @ if null pointer then end
		BEQ keyLenEnd
		ADD r1, r1, #1 @ r1++ // incremen counter
		B keyLenLoop @ continue
	keyLenEnd:
		MOV r0, r1 @ r0 = r1 // r0 = counter
		BX lr @ return r0

@	keyLength.c
@	int keyLength(char* key)
@	{
@		int counter = 0;
@		char temp = key[counter]
@		while (temp != NULL)
@		{
@			temp = key[++counter];
@		}
@		return counter;
@	}



@	Calculates gcd of two given integers
@	param r0 - integer one
@	param r1 - integer two
@	return r0 - gcd of the two integers
gcd:
	CMP r0, r1
	SUBGT r0, r0, r1
	SUBLT r1, r1, r0
	BNE gcd
	BX lr

@	gcd.c
@	int gcd(int a, int b)
@	{
@		if (a == 0)
@		{
@			return b
@		}
@		while (b != 0)
@		{
@			if (a > b)
@			{
@				a -= b;
@			}
@			else
@			{
@				b -= a;
@			}
@		}
@		return a;
@	}



@	Takes char input and if uppercase, converted to lowercase. If non alphabet
@	char return 0.
@ 	param r0 - input char
@	return r0 - stripped char or 0
stripToAlpha:
	@ if between 65 & 90 add 32
	@ if not between 65 - 90 & 97 - 122 return 0
	CMP r0, #65
	BLT endZero

	CMP r0, #91
	BLT toLower

	CMP r0, #96
	BGT inRange

	B endZero

	inRange:
		CMP r0, #122
		BGT endZero
		B end

	toLower:
		ADD r0, r0, #32
		B end

	endZero:
		MOV r0, #0
		B end
	end:
		BX lr

@	stripToAlpha.c
@	char stripToAlpha(char input)
@	{
@		if (input > 64 && input < 91 || input > 96 && input < 123)
@		{
@			if (input > 64 && input < 91)
@			{
@				input += 32;
@			}
@		}
@		else
@		{
@			input = 0;
@		}
@		return input;
@	}



@	Encrypts input char by input key char using specified algorithm. If encrypted
@	char is out of alphabetic range, brought back into range.
@	param r0 - input char to encrypt
@ 	param r1 - input key char
@	return r0 - encrypted char
encrypt:
	SUB r0, r0, #96 @ bring char into alphabet range
	SUB r1, r1, #96 @ bring key into alphabet range

	SUB r0, r0, r1 @ encrypt with key
	ADD r0, r0, #2

	rangeLoopEnc:
		CMP r0, #1
		BGE endEnc
		ADD r0, r0, #26 @ add 26 until the char is within the range 1-26
		B rangeLoopEnc

	endEnc:
		ADD r0, r0, #96 @ bring character back to ascii range
		BX lr

@	encrypt.c
@	char encrypt(char text, char key)
@	{
@		char out;
@		out = ((text - 96) - (key - 96)) + 2;
@		while (out < 1)
@		{
@			out += 26;
@		}
@		out += 96;
@		return out;
@	}


@	Decrypts input char by input key char using specified algorithm. If decrypted
@	char is out of alphabetic range, brought back into range.
@	param r0 - input char to decrypt
@ 	param r1 - input key char
@	return r0 - decrypted char
decrypt:
	SUB r0, r0, #96 @ bring char into alphabet range
	SUB r1, r1, #96 @ bring key into alphabet range

	ADD r0, r0, r1 @ decrypt with key
	SUB r0, r0, #2

	rangeLoopDec:
		CMP r0, #27
		BLT endDec
		SUB r0, r0, #26 @ minus 26 until the char is in the range 1 - 26
		B rangeLoopDec

	endDec:
		ADD r0, r0, #96 @ bring back into ascii range
		BX lr

@	decrypt.c
@	char decrypt(char text, char key)
@	{
@		char out;
@		out = ((text - 96) + (key - 96)) - 2;
@		while (out > 26)
@		{
@			out -= 26;
@		}
@		out += 96;
@		return out;
@	}
