all: cipher

cipher: cipher.o
	gcc -o cipher cipher.o

cipher.o: cipher.s
	as -o cipher.o cipher.s

clean:
	rm cipher cipher.o 
