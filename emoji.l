%{
#include "emoji.tab.h"
#include <string.h>
#include <ctype.h>

/* Use the same emoji code definitions from emoji.y */
#define HAPPY_EMOJI 1
#define LAUGH_EMOJI 2
#define SAD_EMOJI 3
#define CRY_EMOJI 4
#define LOVE_EMOJI 5
#define ANGRY_EMOJI 6
#define SURPRISE_EMOJI 7
#define THINK_EMOJI 8

/* Helper function to check if a character is part of a word */
int is_word_char(char c) {
    return isalnum(c) || c == '\'' || c == '-';
}

/* Helper function to convert string to lowercase */
char* to_lowercase(char* s) {
    char* p = s;
    while (*p) {
        *p = tolower(*p);
        p++;
    }
    return s;
}
%}

%option noyywrap
%x IN_WORD

%%
                    /* Start in the default state, looking for words */
[a-zA-Z]+           { 
                      /* Keep original case for output if not an emoji word */
                      char* original = strdup(yytext);
                      char* lowercase = strdup(yytext);
                      to_lowercase(lowercase);
                      
                      if (strcmp(lowercase, "smile") == 0 || 
                          strcmp(lowercase, "happy") == 0 || 
                          strcmp(lowercase, "joy") == 0) {
                          yylval.emoji_code = HAPPY_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "grin") == 0 || 
                               strcmp(lowercase, "laugh") == 0 || 
                               strcmp(lowercase, "lol") == 0 || 
                               strcmp(lowercase, "haha") == 0) {
                          yylval.emoji_code = LAUGH_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "sad") == 0 || 
                               strcmp(lowercase, "unhappy") == 0 || 
                               strcmp(lowercase, "frown") == 0) {
                          yylval.emoji_code = SAD_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "cry") == 0 || 
                               strcmp(lowercase, "tears") == 0 || 
                               strcmp(lowercase, "sob") == 0) {
                          yylval.emoji_code = CRY_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "love") == 0 || 
                               strcmp(lowercase, "heart") == 0 || 
                               strcmp(lowercase, "adore") == 0) {
                          yylval.emoji_code = LOVE_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "angry") == 0 || 
                               strcmp(lowercase, "mad") == 0 || 
                               strcmp(lowercase, "rage") == 0) {
                          yylval.emoji_code = ANGRY_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "shocked") == 0 || 
                               strcmp(lowercase, "surprise") == 0 || 
                               strcmp(lowercase, "wow") == 0) {
                          yylval.emoji_code = SURPRISE_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else if (strcmp(lowercase, "think") == 0 || 
                               strcmp(lowercase, "ponder") == 0 || 
                               strcmp(lowercase, "wonder") == 0) {
                          yylval.emoji_code = THINK_EMOJI;
                          free(original);
                          free(lowercase);
                          return EMOJI_WORD;
                      }
                      else {
                          /* Not a special word, just regular text */
                          yylval.text = original;
                          free(lowercase);
                          return REGULAR_WORD;
                      }
                    }

[!][!]*              { yylval.intensity = strlen(yytext); return EXCLAMATION; }
[?][?]*              { yylval.intensity = strlen(yytext); return QUESTION; }

[ \t]+               { yylval.text = strdup(yytext); return WHITESPACE; }
[\n]+                { yylval.text = strdup(yytext); return NEWLINE; }
[.,;:()]             { yylval.text = strdup(yytext); return PUNCTUATION; }
.                    { yylval.text = strdup(yytext); return OTHER_CHAR; }

%%