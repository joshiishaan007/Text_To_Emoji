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

/* Buffer to accumulate multi-word expressions */
char word_buffer[1024] = "";
int intensity_modifier = 0;

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

/* Helper function to check for intensity modifiers */
int get_intensity_value(const char* word) {
    if (strcmp(word, "very") == 0 || 
        strcmp(word, "really") == 0 ||
        strcmp(word, "so") == 0) {
        return 1;
    } else if (strcmp(word, "extremely") == 0 || 
               strcmp(word, "super") == 0 ||
               strcmp(word, "incredibly") == 0 ||
               strcmp(word, "extreme") == 0) {
        return 2;
    }
    return 0;
}

/* Helper function to check for emoji words */
int get_emoji_code(const char* word) {
    if (strcmp(word, "smile") == 0 || 
        strcmp(word, "happy") == 0 || 
        strcmp(word, "joy") == 0) {
        return HAPPY_EMOJI;
    }
    else if (strcmp(word, "grin") == 0 || 
             strcmp(word, "laugh") == 0 || 
             strcmp(word, "lol") == 0 || 
             strcmp(word, "haha") == 0) {
        return LAUGH_EMOJI;
    }
    else if (strcmp(word, "sad") == 0 || 
             strcmp(word, "unhappy") == 0 || 
             strcmp(word, "frown") == 0) {
        return SAD_EMOJI;
    }
    else if (strcmp(word, "cry") == 0 || 
             strcmp(word, "tears") == 0 || 
             strcmp(word, "sob") == 0) {
        return CRY_EMOJI;
    }
    else if (strcmp(word, "love") == 0 || 
             strcmp(word, "heart") == 0 || 
             strcmp(word, "adore") == 0) {
        return LOVE_EMOJI;
    }
    else if (strcmp(word, "angry") == 0 || 
             strcmp(word, "mad") == 0 || 
             strcmp(word, "rage") == 0) {
        return ANGRY_EMOJI;
    }
    else if (strcmp(word, "shocked") == 0 || 
             strcmp(word, "surprise") == 0 || 
             strcmp(word, "wow") == 0) {
        return SURPRISE_EMOJI;
    }
    else if (strcmp(word, "think") == 0 || 
             strcmp(word, "ponder") == 0 || 
             strcmp(word, "wonder") == 0) {
        return THINK_EMOJI;
    }
    return 0;
}

/* Reset the buffer for the next multi-word expression */
void reset_buffer() {
    word_buffer[0] = '\0';
    intensity_modifier = 0;
}
%}

%option noyywrap
%x IN_MULTIWORD

%%

"very "             { 
                      strcpy(word_buffer, "very");
                      intensity_modifier = 1;
                      BEGIN(IN_MULTIWORD);
                    }

"really "           { 
                      strcpy(word_buffer, "really");
                      intensity_modifier = 1;
                      BEGIN(IN_MULTIWORD);
                    }

"so "               { 
                      strcpy(word_buffer, "so");
                      intensity_modifier = 1;
                      BEGIN(IN_MULTIWORD);
                    }

"extremely "        { 
                      strcpy(word_buffer, "extremely");
                      intensity_modifier = 2;
                      BEGIN(IN_MULTIWORD);
                    }

"super "            { 
                      strcpy(word_buffer, "super");
                      intensity_modifier = 2;
                      BEGIN(IN_MULTIWORD);
                    }

"incredibly "       { 
                      strcpy(word_buffer, "incredibly");
                      intensity_modifier = 2;
                      BEGIN(IN_MULTIWORD);
                    }

"extreme "          { 
                      strcpy(word_buffer, "extreme");
                      intensity_modifier = 2;
                      BEGIN(IN_MULTIWORD);
                    }

[a-zA-Z]+           { 
                      /* Keep original case for output if not an emoji word */
                      char* original = strdup(yytext);
                      char* lowercase = strdup(yytext);
                      to_lowercase(lowercase);
                      
                      int emoji_code = get_emoji_code(lowercase);
                      if (emoji_code > 0) {
                          yylval.emoji_info.code = emoji_code;    /* Updated for struct */
                          yylval.emoji_info.intensity = 1;        /* Default intensity */
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

<IN_MULTIWORD>"very "     {
                      strcat(word_buffer, " very");
                      intensity_modifier += 1;
                    }

<IN_MULTIWORD>"really "   {
                      strcat(word_buffer, " really");
                      intensity_modifier += 1;
                    }

<IN_MULTIWORD>"so "       {
                      strcat(word_buffer, " so");
                      intensity_modifier += 1;
                    }

<IN_MULTIWORD>"extremely " {
                      strcat(word_buffer, " extremely");
                      intensity_modifier += 2;
                    }

<IN_MULTIWORD>"super "    {
                      strcat(word_buffer, " super");
                      intensity_modifier += 2;
                    }

<IN_MULTIWORD>"incredibly " {
                      strcat(word_buffer, " incredibly");
                      intensity_modifier += 2;
                    }

<IN_MULTIWORD>"extreme "  {
                      strcat(word_buffer, " extreme");
                      intensity_modifier += 2;
                    }

<IN_MULTIWORD>[a-zA-Z]+ { 
                      /* Check if this word is an emoji word */
                      char* lowercase = strdup(yytext);
                      to_lowercase(lowercase);
                      
                      int emoji_code = get_emoji_code(lowercase);
                      if (emoji_code > 0) {
                          /* We found a complete multi-word emoji expression */
                          yylval.emoji_info.code = emoji_code;    /* Updated for struct */
                          
                          /* Calculate intensity based on modifiers */
                          int final_intensity = 1 + (intensity_modifier > 3 ? 3 : intensity_modifier);
                          yylval.emoji_info.intensity = final_intensity;  /* Updated for struct */
                          
                          free(lowercase);
                          reset_buffer();
                          BEGIN(INITIAL);
                          return EMOJI_WORD;
                      } else {
                          /* Not an emoji word, output the whole buffer as regular text */
                          char full_text[2048] = "";
                          strcpy(full_text, word_buffer);
                          strcat(full_text, " ");
                          strcat(full_text, yytext);
                          
                          yylval.text = strdup(full_text);
                          free(lowercase);
                          reset_buffer();
                          BEGIN(INITIAL);
                          return REGULAR_WORD;
                      }
                    }

[!][!]*              { yylval.intensity = strlen(yytext); return EXCLAMATION; }
[?][?]*              { yylval.intensity = strlen(yytext); return QUESTION; }

[ \t]+               { 
                      if (YYSTATE == IN_MULTIWORD) {
                          /* Ignore extra spaces in multi-word mode */
                      } else {
                          yylval.text = strdup(yytext); 
                          return WHITESPACE; 
                      }
                    }

[\n]+                { 
                      /* Reset multi-word state at newlines */
                      if (YYSTATE == IN_MULTIWORD) {
                          /* Output accumulated buffer as regular text */
                          if (word_buffer[0] != '\0') {
                              yylval.text = strdup(word_buffer);
                              reset_buffer();
                              BEGIN(INITIAL);
                              return REGULAR_WORD;
                          }
                      }
                      yylval.text = strdup(yytext); 
                      return NEWLINE; 
                    }

[.,;:()]             { 
                      /* Reset multi-word state at punctuation */
                      if (YYSTATE == IN_MULTIWORD) {
                          /* Output accumulated buffer as regular text */
                          if (word_buffer[0] != '\0') {
                              yylval.text = strdup(word_buffer);
                              reset_buffer();
                              BEGIN(INITIAL);
                              return REGULAR_WORD;
                          }
                      }
                      yylval.text = strdup(yytext); 
                      return PUNCTUATION; 
                    }

.                    { 
                      /* Reset multi-word state for other characters */
                      if (YYSTATE == IN_MULTIWORD) {
                          /* Output accumulated buffer as regular text */
                          if (word_buffer[0] != '\0') {
                              yylval.text = strdup(word_buffer);
                              reset_buffer();
                              BEGIN(INITIAL);
                              return REGULAR_WORD;
                          }
                      }
                      yylval.text = strdup(yytext); 
                      return OTHER_CHAR; 
                    }

%%