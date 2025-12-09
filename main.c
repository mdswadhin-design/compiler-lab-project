#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "config.tab.h" 

typedef struct ConfigEntry {
    char *section;
    char *key;
    char *value;
    char *type; 
    struct ConfigEntry *next;
} ConfigEntry;

ConfigEntry *config_list = NULL; 
char *current_section = NULL; 

void store_config_entry(char *section, char *key, char *value_type, char *value) {
    ConfigEntry *new_entry = (ConfigEntry *)malloc(sizeof(ConfigEntry));

    if (!new_entry) {
        perror("Memory allocation failed");
        return;
    }

   
    new_entry->section = strdup(section ? section : "Global");
    new_entry->key = strdup(key);
    new_entry->value = strdup(value);
    new_entry->type = strdup(value_type);
    
 
    new_entry->next = config_list;
    config_list = new_entry;
    
    printf("SAVED: [%s] Key: %s, Value: %s (%s)\n", 
           new_entry->section, new_entry->key, new_entry->value, new_entry->type);
}


void print_config() {
    ConfigEntry *temp = config_list;
    printf("\n--- Final Parsed Configuration ---\n");
   
    while (temp) {
        printf("[%s] %s = %s (Type: %s)\n", temp->section, temp->key, temp->value, temp->type);
        temp = temp->next;
    }
    printf("----------------------------------\n");
}


void free_config_list() {
    ConfigEntry *current = config_list;
    ConfigEntry *next;
    while (current) {
        next = current->next;
        free(current->section);
        free(current->key);
        free(current->value);
        free(current->type);
        free(current);
        current = next;
    }
    config_list = NULL;
    if (current_section) free(current_section);
}


extern FILE *yyin; 

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            fprintf(stderr, "Error: Could not open input file '%s'\n", argv[1]);
            return 1;
        }
        yyin = fp;
    } else {

        yyin = stdin; 
    }
    
    printf("Starting parsing...\n");
    yyparse(); 
    
    print_config();
    free_config_list();
    
    
    if (argc > 1) fclose(yyin);
    
    return 0;
}


void yyerror(const char *s) {
    extern int yylineno; // Flex ???? ???? ?????
    fprintf(stderr, "Parsing Error: %s at line %d\n", s, yylineno);
}

