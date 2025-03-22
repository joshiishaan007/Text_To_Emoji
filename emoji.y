%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function declarations */
void yyerror(const char *s);
extern int yylex();
extern FILE *yyin;

/* Emoji code definitions */
#define HAPPY_EMOJI 1
#define LAUGH_EMOJI 2
#define SAD_EMOJI 3
#define CRY_EMOJI 4
#define LOVE_EMOJI 5
#define ANGRY_EMOJI 6
#define SURPRISE_EMOJI 7
#define THINK_EMOJI 8

/* Emoji strings */
#define HAPPY_BASE_EMOJI "😊"
#define HAPPY_MEDIUM_EMOJI "😃"
#define HAPPY_INTENSE_EMOJI "🤩"

#define LAUGH_BASE_EMOJI "😄"
#define LAUGH_MEDIUM_EMOJI "😂"
#define LAUGH_INTENSE_EMOJI "🤣"

#define SAD_BASE_EMOJI "🙁"
#define SAD_MEDIUM_EMOJI "😔"
#define SAD_INTENSE_EMOJI "😞"

#define CRY_BASE_EMOJI "😢"
#define CRY_MEDIUM_EMOJI "😭"
#define CRY_INTENSE_EMOJI "😿"

#define LOVE_BASE_EMOJI "❤️"
#define LOVE_MEDIUM_EMOJI "💖"
#define LOVE_INTENSE_EMOJI "💝"

#define ANGRY_BASE_EMOJI "😠"
#define ANGRY_MEDIUM_EMOJI "😡"
#define ANGRY_INTENSE_EMOJI "🤬"

#define SURPRISE_BASE_EMOJI "😮"
#define SURPRISE_MEDIUM_EMOJI "😲"
#define SURPRISE_INTENSE_EMOJI "😱"

#define THINK_BASE_EMOJI "🤔"

/* Function to get the emoji based on type and intensity */
const char* get_emoji(int emoji_code, int intensity);
%}

%union {
    char *text;              /* For regular text and whitespace */
    int emoji_code;          /* Enum identifying which emoji to use */
    int intensity;           /* Intensity level (number of ! or ?) */
    struct {
        int code;
        int intensity;
    } emoji_info;            /* Combined emoji code and intensity */
}

/* Token declarations */
%token <emoji_info> EMOJI_WORD  /* Changed to use the struct type */
%token <text> REGULAR_WORD WHITESPACE NEWLINE PUNCTUATION OTHER_CHAR
%token <intensity> EXCLAMATION QUESTION

%%

document:
    /* Empty document */
    | document text_element
    ;

text_element:
    EMOJI_WORD {
        /* Use the intensity that comes directly from the lexer */
        printf("%s", get_emoji($1.code, $1.intensity));
    }
    | EMOJI_WORD EXCLAMATION {
        /* Combine the intensity from modifiers and exclamation marks */
        int combined_intensity = $1.intensity + $2;
        if (combined_intensity > 3) combined_intensity = 3; /* Cap at 3 */
        printf("%s", get_emoji($1.code, combined_intensity));
    }
    | EMOJI_WORD QUESTION {
        if ($1.code == THINK_EMOJI) {
            printf("%s", THINK_BASE_EMOJI);
        } else {
            /* Use the intensity from modifiers */
            printf("%s", get_emoji($1.code, $1.intensity));
            printf("❓");
        }
    }
    | REGULAR_WORD {
        printf("%s", $1);
        free($1);
    }
    | WHITESPACE {
        printf("%s", $1);
        free($1);
    }
    | NEWLINE {
        printf("%s", $1);
        free($1);
    }
    | PUNCTUATION {
        printf("%s", $1);
        free($1);
    }
    | OTHER_CHAR {
        printf("%s", $1);
        free($1);
    }
    ;

%%

/* Function to get the appropriate emoji based on type and intensity */
const char* get_emoji(int emoji_code, int intensity) {
    switch (emoji_code) {
        case HAPPY_EMOJI:
            if (intensity == 1) return HAPPY_BASE_EMOJI;
            else if (intensity == 2) return HAPPY_MEDIUM_EMOJI;
            else return HAPPY_INTENSE_EMOJI;
        
        case LAUGH_EMOJI:
            if (intensity == 1) return LAUGH_BASE_EMOJI;
            else if (intensity == 2) return LAUGH_MEDIUM_EMOJI;
            else return LAUGH_INTENSE_EMOJI;
        
        case SAD_EMOJI:
            if (intensity == 1) return SAD_BASE_EMOJI;
            else if (intensity == 2) return SAD_MEDIUM_EMOJI;
            else return SAD_INTENSE_EMOJI;
        
        case CRY_EMOJI:
            if (intensity == 1) return CRY_BASE_EMOJI;
            else if (intensity == 2) return CRY_MEDIUM_EMOJI;
            else return CRY_INTENSE_EMOJI;
        
        case LOVE_EMOJI:
            if (intensity == 1) return LOVE_BASE_EMOJI;
            else if (intensity == 2) return LOVE_MEDIUM_EMOJI;
            else return LOVE_INTENSE_EMOJI;
        
        case ANGRY_EMOJI:
            if (intensity == 1) return ANGRY_BASE_EMOJI;
            else if (intensity == 2) return ANGRY_MEDIUM_EMOJI;
            else return ANGRY_INTENSE_EMOJI;
        
        case SURPRISE_EMOJI:
            if (intensity == 1) return SURPRISE_BASE_EMOJI;
            else if (intensity == 2) return SURPRISE_MEDIUM_EMOJI;
            else return SURPRISE_INTENSE_EMOJI;
        
        case THINK_EMOJI:
            return THINK_BASE_EMOJI;
        
        default:
            return "😅"; /* Unknown emoji type */
    }
}

/* Error handler */
void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

/* Main function */
int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            printf("Could not open file: %s\n", argv[1]);
            return 1;
        }
    }
    
    yyparse();
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return 0;
}