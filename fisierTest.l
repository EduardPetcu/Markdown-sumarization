%{
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

int count = 0;
int wordListCounter = 3, blockquote = 5;
char STXTitle[101];
%}

%option noyywrap
titleStart      [#]+
titleChars      [a-zA-Z0-9, ]+
titleSTX        [a-zA-Z0-9 ]+
quoteChars        [a-zA-Z0-9#]+
punctuationMark [;!:?\.]
markedWord      "**"[a-zA-Z0-9]+"**"|"__"[a-zA-Z0-9]+"__"
markedWordSingle "*"[a-zA-Z0-9]+"*"|"_"[a-zA-Z0-9]+"_"
paragraphChars  [a-zA-Z0-9,() ]+
ATX_titleL1     [=]+
ATX_titleL2     [-]+
SEPARATE        [ ]*[-]+[ ]*[-]+[ ]*[-]+[ ]*|[ ]*[*]+[ ]*[*]+[ ]*[*]+[ ]*
LIST_STARTER    [ ]*[0-9]+\.[ ]+|[ ]*[*][ ]+|[ ]*[-][ ]+|[ ]*[+][ ]+
LIST_ELEMENT    [a-zA-Z0-9,]
%s IDENTATION PARAGRAPH IMPORTANT QUOTE
%s NOT_FIRST_WORD CHECK_TITLE LIST LIST_IMPORTANT
%%
<INITIAL>{titleStart} {
     count = min(yyleng, 3);
     BEGIN (IDENTATION);
}
<INITIAL>[ ]*>[ ]* {
    for (int i = 1; i <= 3 * (count + 1); i++) {
        cout << " ";
    }
    cout << "\"";
    blockquote = 5;
    BEGIN (QUOTE);
} 
<INITIAL>{titleSTX}\r\n {
    strcpy(STXTitle, yytext);
    STXTitle[yyleng - 2] = '\0';
    BEGIN (CHECK_TITLE);
}
<QUOTE>{quoteChars} {
    if (blockquote > 0) {
        if (blockquote < 5) {
            cout << " ";
        }
        ECHO;
        blockquote--;
    }
}
<CHECK_TITLE>{ATX_titleL1} {
    if (strlen(STXTitle) == yyleng) {
        count = 1;
        for (int i = 1; i <= 3 * count; ++i) {
            cout << " ";
        }
        cout << "+ ";
        cout << STXTitle;
        cout << "\n";
        BEGIN (INITIAL);
    } else {
        for (int i = 1; i <= 3 * count; ++i) {
                cout << " ";
        }
        cout << ":" << STXTitle << " ";
        BEGIN (PARAGRAPH);
    }
}
<CHECK_TITLE>{ATX_titleL2} {
    if (strlen(STXTitle) == yyleng) {
        count = 2;
        for (int i = 1; i <= 3 * count; ++i) {
            cout << " ";
        }
        cout << "+ ";
        cout << STXTitle;
        cout << "\n";
        BEGIN (INITIAL);
    } else {
        for (int i = 1; i <= 3 * count; ++i) {
                cout << " ";
        }
        cout << ":" << STXTitle << " ";
        BEGIN (PARAGRAPH);
    }
}
<CHECK_TITLE>\r\n {
    //ECHO;
    for (int i = 1; i <= 3 * count; ++i) {
         cout << " ";
    }
    cout << ":" << STXTitle << ":\n";
    BEGIN (INITIAL);
}
<CHECK_TITLE>[^-=] {
    for (int i = 1; i <= 3 * count; ++i) {
         cout << " ";
    }
    cout << ":" << STXTitle << " ";
    unput(yytext[yyleng - 1]);
    BEGIN (PARAGRAPH);
}
<QUOTE>\r\n[^>] {
    cout << "\"\n";
    BEGIN (INITIAL);
} 
<INITIAL>{LIST_STARTER} {
    for (int i = 1; i <= 3 * (count + 1); i++) {
        cout << " ";
    }
    cout << "[";
    wordListCounter = 3;
    BEGIN (LIST);
}
<PARAGRAPH,IMPORTANT>{markedWord} {
    string word = yytext;
    cout << "<" << word.substr(2, word.length() - 4) << ">";
}
<PARAGRAPH,IMPORTANT>{markedWordSingle} {
    string word = yytext;
    cout << "<" << word.substr(1, word.length() - 2) << ">";
}
<LIST,LIST_IMPORTANT>{markedWord} {
    string word = yytext;
    cout << " <" << word.substr(2, word.length() - 4) << ">";
}
<LIST,LIST_IMPORTANT>{markedWordSingle} {
    string word = yytext;
    cout << " <" << word.substr(1, word.length() - 2) << ">";
}
<LIST>{LIST_ELEMENT}+ {
    if (wordListCounter < 3) {
        cout << " ";
    }
    ECHO;
    wordListCounter--;
    if (wordListCounter == 0)
        BEGIN(LIST_IMPORTANT);
}
<LIST,LIST_IMPORTANT>{LIST_STARTER} {
    cout << "; ";
    wordListCounter = 3;
    BEGIN (LIST);
}
<LIST,LIST_IMPORTANT>\r\n\r\n[^0-9 \t\*-\+] {
    cout << "]\n";
    unput(yytext[yyleng - 1]);
    BEGIN(INITIAL);
}

<INITIAL>{SEPARATE} {
    for (int i = 1; i <= 3 * count; i++) {
        cout << " ";
    }
    cout << "////////////\n";
}
<INITIAL>{paragraphChars} {
    for (int i = 1; i <= 3 * count; ++i) {
         cout << " ";
    }
    cout << ":";
    ECHO;
    BEGIN (PARAGRAPH);
}
<IDENTATION>{titleChars} {
    for (int i = 1; i <= 3 * count; ++i) {
         cout << " ";
    }
    cout << "+";
    ECHO;
    cout << "\n";
    BEGIN (INITIAL);
}
<PARAGRAPH>"\r\n" {
    cout << " ";
}
<PARAGRAPH>"\r\n\r\n" {
    cout << ":\n";
    BEGIN (INITIAL);
}
<PARAGRAPH>{punctuationMark} {
    BEGIN (IMPORTANT);
}
<PARAGRAPH>{paragraphChars} {
    ECHO;
}
<IMPORTANT>"\r\n" {
    cout << ":\n";
    BEGIN (INITIAL);
}
.|\n {
    ;
}
%%

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Error: missing input file" << endl;
        return 1;
    }
    FILE *infile = fopen(argv[1], "r");
    yyin = infile;
    yylex();
    fclose(infile);
    return 0;
}
