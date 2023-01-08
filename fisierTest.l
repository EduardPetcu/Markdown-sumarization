%{
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

int count = 0, linkValue = 0;
int wordListCounter = 3, blockquote = 5;
char STXTitle[101];
%}

%option noyywrap
titleStart      [#]+
titleChars      [a-zA-Z0-9,' ]+
titleSTX        [a-zA-Z0-9' ]+
quoteChars      [a-zA-Z0-9'#-]+
punctuationMark [;!:?\.]
markedWord      "**"[a-zA-Z0-9' ]+"**"|"__"[a-zA-Z0-9' ]+"__"
markedWordSingle "*"[a-zA-Z0-9' ]+"*"|"_"[a-zA-Z0-9' ]+"_"
paragraphChars  [a-zA-Z0-9,()'" -]+
ATX_titleL1     [=]+
ATX_titleL2     [-]+
CODE_BLOCK      [ \t]{4,}[}{a-zA-Z0-9#!;:)"'(\$,%^&*|+/\. -]+\r\n
CODE_BLOCK_LIST [ ]{8,}[}{a-zA-Z0-9#!;:)"'(\$,%^&*|+/\. -]+\r\n
SEPARATE        [ ]*[-]+[ ]*[-]+[ ]*[-]+[ ]*|[ ]*[*]+[ ]*[*]+[ ]*[*]+[ ]*
LIST_STARTER    [ ]*[0-9]+\.[ ]+|[ ]*[*][ ]+|[ ]*[-][ ]+|[ ]*[+][ ]+
LIST_ELEMENT    [a-zA-Z0-9,'-]
LINK1           "["[a-zA-Z0-9,':;\.#\r\n -]+
LINK2           "!["[a-zA-Z0-9,':;\.# -]+
CONTINUE_LINK   "("[a-zA-Z0-9,#':";_/\. -]+")"
%s IDENTATION PARAGRAPH IMPORTANT QUOTE
%s NOT_FIRST_WORD CHECK_TITLE LIST LIST_IMPORTANT 
%s CHECK_LINK SKIP_ATX_ENDING 
%s LINK_PARA LINK_IMP LINK_LIST LINK_LIST_IMP LINK_INITIAL
%s SKIP_END_LINK_PARAGRAPH SKIP_END_LINK_LIST SKIP_END_LINK_IMPORTANT 
%s SKIP_END_LINK_LIST_IMPORTANT SKIP_END_LINK_INITIAL
%%
<INITIAL>{LINK2} {
    for (int i = 1; i <= 3 * count; i++) {
        cout << " ";
    }
    cout << yytext[1] << yytext[0] << yytext + 2;
    BEGIN (LINK_INITIAL);
}
<INITIAL>{LINK1}"](" {
    for (int i = 1; i <= 3 * count; i++) {
        cout << " ";
    }
    cout << yytext[0];
    cout << "@";
    BEGIN (LINK_INITIAL);
    REJECT;
}
<LINK_INITIAL>"]" {
    //cout << "459";
    ECHO;
    cout << "\n";
    BEGIN (SKIP_END_LINK_INITIAL);
}
<SKIP_END_LINK_INITIAL>{CONTINUE_LINK} {
    BEGIN(INITIAL);
}
<PARAGRAPH>{LINK2} {
    cout << yytext[1] << yytext[0] << yytext + 2;
    BEGIN (LINK_PARA);
}
<PARAGRAPH>{LINK1}"](" {
    cout << yytext[0];
    cout << "@";
    BEGIN (LINK_PARA);
    REJECT;
}
<LINK_PARA>"]" {
    ECHO;
    BEGIN (SKIP_END_LINK_PARAGRAPH);
}
<SKIP_END_LINK_PARAGRAPH>{CONTINUE_LINK} {
    BEGIN(PARAGRAPH);
}

<IMPORTANT>{LINK2} {
    cout << yytext[1] << yytext[0] << yytext + 2;
    BEGIN (LINK_IMP);
}
<IMPORTANT>{LINK1}"](" {
    cout << yytext[0];
    cout << "@";
    BEGIN (LINK_IMP);
    REJECT;
}
<LINK_IMP>"]" {
    ECHO;
    //cout << "\n";
    BEGIN (SKIP_END_LINK_IMPORTANT);
}
<SKIP_END_LINK_IMPORTANT>{CONTINUE_LINK} {
    BEGIN(IMPORTANT);
}

<LIST>{LINK2} {
    cout << yytext[1] << yytext[0] << yytext + 2;
    BEGIN (LINK_LIST);
}
<LIST>{LINK1}"](" {
    cout << yytext[0];
    cout << "@";
    BEGIN (LINK_LIST);
    REJECT;
}
<LINK_LIST>"]" {
    ECHO;
    cout << "\n";
    BEGIN (SKIP_END_LINK_LIST);
}
<SKIP_END_LINK_LIST>{CONTINUE_LINK} {
    BEGIN(LIST);
}

<LIST_IMPORTANT>{LINK2} {
    cout << yytext[1] << yytext[0] << yytext + 2;
    BEGIN (LINK_LIST_IMP);
}
<LIST_IMPORTANT>{LINK1}"](" {
    cout << yytext[0];
    cout << "@";
    BEGIN (LINK_LIST_IMP);
    REJECT;
}
<LINK_LIST_IMP>"]" {
    ECHO;
    //cout << "\n";
    BEGIN (SKIP_END_LINK_LIST_IMPORTANT);
}
<SKIP_END_LINK_LIST_IMPORTANT>{CONTINUE_LINK} {
    BEGIN(LIST_IMPORTANT);
}
<LINK_INITIAL,LINK_PARA,LINK_IMP,LINK_LIST,LINK_LIST_IMP>{paragraphChars} {
    ECHO;
}
<LINK_INITIAL,LINK_PARA,LINK_IMP,LINK_LIST,LINK_LIST_IMP>\r\n {
    //cout << "801";
    cout << " ";
}
<INITIAL>{titleStart} {
     count = min(yyleng, 3);
     BEGIN (IDENTATION);
}
<INITIAL>{CODE_BLOCK}+ {
    for (int i = 1; i <= 3 * count; i++) {
         cout << " ";
    }
    cout << "[code]\n";
}
<PARAGRAPH,IMPORTANT>{CODE_BLOCK}+ {
    cout << "[code]\n";
}
<LIST,LIST_IMPORTANT>{CODE_BLOCK_LIST}+ {
    //ECHO;
    cout << " [code]";
    unput(yytext[yyleng - 2]);
    unput(yytext[yyleng - 1]);
}
<INITIAL>[ ]*>[ ]* {
    for (int i = 1; i <= 3 * (count + 1); i++) {
        cout << " ";
    }
    cout << "\"";
    blockquote = 5;
    BEGIN (QUOTE);
} 
<PARAGRAPH>{markedWord} {
    //string word = yytext;
    //cout << "<" << word.substr(2, word.length() - 4) << ">";
    cout << "<";
    yytext[yyleng - 2] = '\0';
    cout << yytext + 2;
    cout << ">";
}
<PARAGRAPH>{markedWordSingle} {
    // string word = yytext;
    // cout << "<" << word.substr(1, word.length() - 2) << ">";
    cout << "<";
    yytext[yyleng - 1] = '\0';
    cout << yytext + 1;
    cout << ">";
}
<IMPORTANT,LIST,LIST_IMPORTANT>{markedWord} {
    // string word = yytext;
    // cout << " <" << word.substr(2, word.length() - 4) << ">";
    cout << " <";
    yytext[yyleng - 2] = '\0';
    cout << yytext + 2;
    cout << ">";
}
<IMPORTANT,LIST,LIST_IMPORTANT>{markedWordSingle} {
    // string word = yytext;
    // cout << " <" << word.substr(1, word.length() - 2) << ">";
    cout << " <";
    yytext[yyleng - 1] = '\0';
    cout << yytext + 1;
    cout << ">";
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
    BEGIN (SKIP_ATX_ENDING);
}
<SKIP_ATX_ENDING>[#]* {
    ;
}
<SKIP_ATX_ENDING>\r\n {
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
<IMPORTANT>"\r\n\r\n" {
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
