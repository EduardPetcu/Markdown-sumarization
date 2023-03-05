Eduard Petcu - 334CC

==========================================================================

Titluri ATX

Pentru a sumariza titlurile ATX, am facut match pe siruri dupa regula [#]+ 
am retinut in variabila *count* nivelul de identare si am trecut
intr-o noua stare ce accepta cuvintele titlului. Dupa ce sunt acceptate toate
cuvintele titlului, se intra intr-o stare care ignora toate '#'-urile (de la 
final de rand). Dupa ce se intalneste '\r\n' se considera finalul titlului 
si se intra inapoi in starea INITIAL.

==========================================================================

Titluri STX

Pentru sumarizarea titlurilor STX, am retinut in variabila STXTitle
randurile care contin caractere alfa-numerice, spatii si alte caractere
speciale si am intrat in starea 'CHECK-TITLE', stare in care verific daca 
urmatorul rand are numai egaluri sau linii (face match pe regula [=]+ sau
[-]+) caz in care verific daca numarul de astfel de caractere este egal
cu strlen(STXTitle). In caz afirmativ, acesta va fi interpretat ca un titlu
de nivel 1 sau 2 iar in caz contrar este interpretat ca paragraf.

==========================================================================

Elemente de accentuare

Elementele de accentuare se pot gasi si interpreta in paragrafe si liste.
Se da match pe "**"[a-zA-Z0-9 ]+"**" (si celelalte tipuri de elemente de 
accentuare si se afiseaza sirul match-uit fara primul/primele 2 si 
ultimul/ultimele 2 caracter/caractere.

==========================================================================

Linkuri si imagini

Pentru a sumariza un link, se face match pe regula
'['[a-zA-Z0-9 ]+'](', se afiseaza '[@' si se da REJECT pentru a putea mai apoi
fi afisate cuvintele din link (si inlocui '\n' cu spatii).
Dupa afisarea intregului link, se intra intr-o stare separata prin care se trece
peste '('[a-zA-Z0-9 ]+')'. La final se revine in starea initiala (din care s-a
facut match pe inceputul linkului).
Imaginile sunt sumarizate dupa acelasi algoritm.

==========================================================================

Liste (numerotate si nenumerotate)

Pentru a detecta o lista se verifica daca randul incepe cu *,+,- sau orice
sir format din numere urmate de '.'
Se initializeaza variabila wordListCounter cu 3 si se afiseaza fiecare cuvant
din lista cat timp wordListCounter > 0. 
Dupa ce wordListCounter devine 0 se vor afisa doar linkuri, imagini, blocuri
de cod si alte elemente de accentuare.
Lista se termina atunci cand dupa introducerea a 2 newline-uri (\r\n\r\n)
nu se gaseste un alt element de inceput pt liste sau un bloc de cod.

==========================================================================

Citate (blockquotes)

Daca se face match pe "> " atunci de intra in starea de QUOTE. La fel ca pentru
liste, se initializeaza o variabila blockquote cu 5 si se afiseaza fiecare
cuvant cat timp aceasta este mai mare ca 0. Acestea se pot regasi atat in
regasi atat in paragrafe cat si in liste. 
Citatele se termina atunci cand se gasesc 2 newline-uri caz in care 
se revine fie in starea INITIAL (daca citatul a fost intr-un paragraf)
fie in starea LIST (daca inainte de citat au fost mai putin 3 cuvinte
scrise in lista) fie in starea LIST_IMPORTANT (daca in lista se mai puteau
scrie doar elemente de accentuare, blocuri de cod, linkuri, imagini sau
citate).

==========================================================================

Bloc de cod

Pentru a se face match pe un bloc de cod am creat regula 
[ \t]{4,}[a-zA-Z0-9 ]+\r\n (aceeasi regula este folosita si pentru blocurile de 
cod din lista cu precizarea cu numarul de spatii/taburi este 8 in loc de 4).
Astfel, un bloc de cod se poate termina doar daca dupa un newLine, urmatorul
rand nu este identat la numarul de spatii necesare.
Cand un astfel de match are loc, se afiseaza la stdout '[code]'.

==========================================================================
