# ARMv7 Cipher
## Table of Contents
1. [General](#general)
2. [Languages Used](#languages-used)
3. [Features](#features)
4. [Usage](#usage)
5. [Status](#status)

## General
A simple one-time pad cipher written in ARMv7 assembly. The program runs through command line, takes a text file input, and offers both an encrypt and decrypt mode. Alongside this is commented out C code that represents the assembly code written making it easier to understand.

## Languages Used
* [ARMv7 Assembly](https://developer.arm.com/documentation/100076/latest/)

## Features
* Run through command line
* Text file input
* Decrypt/encrypt modes

## Usage
The program takes from `stdin` and strips to lowercase, alphabet characters and encrypts/decrypts them as specified by the command line `args` in the following order:
```
cat textFile.txt | cipher opMode keyOne keyTwo | cipher opMode keyOne keyTwo
```
where `opMode = 0 || 1`  -- (encrypt || decrypt), `keyOne` is the first key and `keyTwo` is the second.
The keys must also be co-prime in lengths, this is accomplished by using `gcd` and having accomplished a product of 1.

Finally the cipher/plain text is outputted through `stdout`.
   
## Status
Version 1.4