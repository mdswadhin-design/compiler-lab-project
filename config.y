%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Extern functions from main.c
extern void store_config_entry(char *section, char *key, char *value_type, char *value);
extern char *current_section;
extern int yylex(); 

void yyerror(const char *s); 
%}

// Semantic Value Union
%union {
    char *str_val;    
    double num_val;   
}

// Token Definitions
%token <str_val> IDENTIFIER STRING_VALUE
%token <num_val> NUMBER_VALUE
%token EQUAL NEWLINE SECTION_START SECTION_END

// Non-terminal Type Definitions - FIX: value_token type is removed.
%type <str_val> config_file statements statement section_header 
%type <str_val> assignment_line 

%start config_file

%%
 /* GRAMMAR RULES */
 
config_file:
    statements
;

// FIX: Statements rule (empty warning is harmless but fixed here)
statements:
    /* empty */ { $$ = NULL; } 
    | statements statement
;

statement:
    assignment_line 
    | section_header NEWLINE
;

// --- Key=Value Assignment: Separated Rules (FINAL FIX) ---
assignment_line:
    IDENTIFIER EQUAL STRING_VALUE NEWLINE
    {
        // $3 is directly STRING_VALUE's semantic value (char*)
        store_config_entry(current_section, $1, "STRING", $3);
        free($3); // Free the string value
        free($1); // Free the key identifier
    }
    | IDENTIFIER EQUAL NUMBER_VALUE NEWLINE
    {
        // $3 is directly NUMBER_VALUE's semantic value (double)
        char num_str[50];
        snprintf(num_str, 50, "%f", $3);
        store_config_entry(current_section, $1, "NUMBER", num_str);
        free($1); // Free the key identifier
    }
;

// Section Header
section_header:
    SECTION_START IDENTIFIER SECTION_END
    {
        if (current_section) {
            free(current_section); 
        }
        current_section = $2; 
    }
;
// NOTE: The 'value_token' rule is fully removed.

%%

// yyerror function is defined in main.c