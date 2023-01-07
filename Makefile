build:
	flex fisierTest.l
	g++ lex.yy.c -o flex_program
run:
	./flex_program fisIntrare