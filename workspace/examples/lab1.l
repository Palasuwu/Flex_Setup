%{
#include <stdio.h>
/* Lab 1 - Scanner
   Aquí definimos las reglas para "masticar" el código fuente.
*/
%}

%option noyywrap

/* --- ZONA DE DEFINICIONES (REGEX) --- */
/* Definimos los ladrillos básicos. La gramática léxica usa esto para armar tokens. */
DIGITO      [0-9]
LETRA       [a-zA-Z]

/* Identificadores: La gramática de Java (y C++) dice que pueden llevar letras,
   guiones bajos y números, pero NUNCA pueden empezar con un número. */
ID          [a-zA-Z_][a-zA-Z0-9_]*

/* Definiciones para números complejos */
HEX         0[xX][0-9a-fA-F]+
FLOAT       {DIGITO}+\.{DIGITO}+
/* Notación científica: Soporta cosas locas como 1.5e-10 (muy usado en física) */
CIENTIFICO  ({DIGITO}+|{FLOAT})[eE][+-]?{DIGITO}+

/* Estado exclusivo ("Start Condition") para manejar bloques de comentarios.
   Es necesario porque las expresiones regulares puras sufren con estructuras anidadas. */
%x COMENTARIO_BLOQUE

%%

    /* --- REGLAS DE RECONOCIMIENTO --- */

    /* 1. Comentarios de una línea: Al estilo C++ o Java.
       Si vemos //, ignoramos todo hasta el enter. */
"//".* { /* Ignorar comentario de línea */ }

    /* 2. Comentarios Multilínea: Aquí cambiamos de estado.
       Entramos en modo "túnel" hasta encontrar el cierre. */
"/*"                    { BEGIN(COMENTARIO_BLOQUE); }
<COMENTARIO_BLOQUE>"*/" { BEGIN(INITIAL); /* Volvemos a la normalidad */ }
<COMENTARIO_BLOQUE>(.|\n) { /* Mientras estemos en el túnel, ignoramos todo */ }

    /* 3. Strings: La gramática permite comillas escapadas (\") dentro del texto.
       La regex se ve fea, pero es para que no truene si escriben "Hola \"Mundo\"". */
\"([^\\"]|\.)*\"      { printf("STRING LITERAL: %s\n", yytext); }

    /* 4. Números: El orden importa. Ponemos primero los más complejos (Hex/Científico)
       para que el analizador no los confunda con enteros simples (Precedencia). */
{HEX}                   { printf("HEXADECIMAL: %s\n", yytext); }
{CIENTIFICO}            { printf("NOTACION_CIENTIFICA: %s\n", yytext); }
{FLOAT}                 { printf("FLOAT: %s\n", yytext); }
{DIGITO}+               { printf("ENTERO: %s\n", yytext); }

    /* 5. Operadores: Los verbos matemáticos y lógicos definidos en la gramática. */
"+"|"-"|"*"|"/"         { printf("OP_ARITMETICO: %s\n", yytext); }
"=="|"!="|"<"|">"|"<="|">=" { printf("OP_RELACIONAL: %s\n", yytext); }
"&&"|"||"|"!"           { printf("OP_LOGICO: %s\n", yytext); }

    /* 6. Puntuación y Asignación:
       Agregamos esto para que el scanner no llore con código real de Java/C. */
"="                     { printf("ASIGNACION: %s\n", yytext); }
";"|"("|")"|"{"|"}"|"," { printf("SIGNO_PUNTUACION: %s\n", yytext); }

    /* 7. Identificadores (Variables, Nombres de funciones) */
{ID}                    { printf("IDENTIFIER: %s\n", yytext); }

    /* Espacios en blanco:
       A diferencia de Python (donde la indentación es gramática),
       en Java/C los espacios y saltos de línea se ignoran. */
[ \t\n]+                { /* Nada que ver aquí, circulando... */ }

    /* Catch-all: Si llegamos aquí, es que escribieron un carácter ilegal
       que no pertenece al alfabeto del lenguaje. */
.                       { printf("ERROR_LEXICO: %s\n", yytext); }

%%

int main() {
    /* Arranca el motor de análisis léxico */
    yylex();
    return 0;
}
