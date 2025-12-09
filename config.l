%{
#include "config.tab.h" 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno; // yylineno is now correctly declared here
int yywrap() { return 1; }
%}

Regular Expression Definitions
IDENTIFIER_CHAR [a-zA-Z0-9_-]

%%
 /* RULES */

[ \t]+          { /* Ignore space and tabs */ }

\n              { return NEWLINE; } 

\/\/.* { /* Ignore C++ style comments */ }
\#.* { /* Ignore shell style comments */ }

"["             { return SECTION_START; }
"]"             { return SECTION_END; }
"="             { return EQUAL; }


[0-9]+(\.[0-9]+)? {
    yylval.num_val = atof(yytext);
    return NUMBER_VALUE;
}


\"[^\"]*\" {
    yytext[yyleng - 1] = '\0'; 
    yylval.str_val = strdup(yytext + 1);
    return STRING_VALUE;
}


[a-zA-Z_]{IDENTIFIER_CHAR}* {
    yylval.str_val = strdup(yytext);
    return IDENTIFIER;
}

.               {
    // Error handling now works with the extern yylineno
    fprintf(stderr, "Lexical Error: Unknown character '%s' at line %d\n", yytext, yylineno);
}

%%