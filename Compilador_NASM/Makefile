CC = gcc -ansi -pedantic -D_POSIX_SOURCE
CFLAGS = -Wall -g
OBJETOS = lex.yy.o y.tab.o alfa.o tabla_sim.o nasm.o

all: $(OBJETOS)
	$(CC) $(CFLAGS) -o alfa $(OBJETOS)

#--- alfa ---#
alfa.o: alfa.c
	@echo Compilando ejecutable...	
	cp -f alfa_aux.c alfa.c
	$(CC) $(CFLAGS) -c alfa.c

#--- Tabla simbolos ---#
tabla_sim.o: tabla_sim.h tabla_sim.c
	@echo Compilando tabla simbolos...		
	$(CC) $(CFLAGS) -c tabla_sim.c

#--- Nasm ---#
nasm.o: nasm.h nasm.c
	@echo Compilando nasm...		
	$(CC) $(CFLAGS) -c nasm.c

#--- Flex ---#
lex.yy.c: alfa.l
	@echo Alfa.l...		
	$ flex alfa.l
lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CFLAGS) -c lex.yy.c


#--- Bison ---#
y.tab.o: y.tab.c
	@echo Alfa.y...		
	$(CC) $(CFLAGS) -c y.tab.c
y.tab.h: alfa.y
	$ bison -d -y -v alfa.y

#--- Ejecutar ---#
%.alf:
	@echo ejecutando alfa sobre $@
	./alfa Correccion/$@ ejemplo.asm
	@echo compilando ejemplo.asm
	#nasm -g -o ejemplo.o -f elf32 ejemplo.asm
	#gcc -m32 -o ejemplo ejemplo.o alfalib.o
	nasm -g -o ejemplo.o -f elf ejemplo.asm
	gcc -o ejemplo ejemplo.o alfalib.o
	@echo ejecutando ejemplo.
	./ejemplo || true # || true elimina el error return 1 del makefile

#--- Limpiar ---#
clean:
	@echo Limpiando...
	rm  $(OBJETOS)
	rm alfa y.tab.* lex.yy.c y.output
	@echo OK.
	
cleanej:
	@echo Limpiando...
	rm ejemplo ejemplo.*
	@echo OK.
	
cleantemp:
	@echo Limpiando...
	@rm -f $(wildcard *~)
	@echo OK.
