# 📊 Data Storytelling: Czy Big Pharma bogaci się na pandemiach?

Projekt stanowi interaktywną aplikację analityczną zbudowaną w środowisku R Shiny, której fundamentem jest koncepcja Data Storytellingu (narracji danymi). Punkt wyjścia stanowi próba wizualnego uzasadnienia pytania badawczego: „Czy firmy z sektora Big Pharma oraz biotechnologii systemowo wzbogacają się na globalnych kryzysach zdrowotnych (pandemiach)?”.

# 🎯 Narracja zamiast czystej eksploracji

W przeciwieństwie do klasycznych narzędzi Business Intelligence czy eksploracyjnej analizy danych (EDA), celem tego projektu nie było poszukiwanie obiektywnej „prawdy” ukrytej w danych, lecz zaprezentowanie danych w sposób ściśle podporządkowany założonej a priori przez autorów tezie.

Projekt został zaprojektowany jako studium przypadku pokazujące siłę perswazji wizualnej oraz tzw. efektu ramowania (framing effect):

* Podporządkowanie pod założoną tezę okien czasowych, punktów odniesienia oraz typów wizualizacji został skonstruowany tak, aby wywołać u odbiorcy konkretne wrażenie i poprowadzić go przez zaplanowaną ścieżkę argumentacji.
* Te same dane, odmienne wnioski pokazują, że operując na dokładnie tym samym zbiorze historycznych notowań giełdowych uzyskanych za pomocą Yahoo Finance, można wysnuć skrajnie różne wnioski w zależności od sposobu ich agregacji i prezentacji.
* Pierwsza część opowieści buduje obraz bezwzględnej hossy i spekulacyjnego bogacenia się na strachu, podczas gdy ostatnia część - bazując na tych samych szeregach czasowych - obala mit trwałych zysków dla większości innowacyjnych spółek.

<img width="241" height="277.5" alt="image" src="https://github.com/user-attachments/assets/ff501a9f-ec16-4330-b706-ef1774db7769" />

# 🎭 3 Akty

Zamiast tradycyjnego dashboardu, w którym wszystkie wskaźniki są widoczne jednocześnie, aplikacja adaptuje klasyczną, trzyaktową strukturę dramaturgiczną znaną z teatru, literatury i filmu. Zastosowanie takiego formatu pełni trzy kluczowe funkcje:

1. Kontrola uwagi odbiorc
2. Budowanie napięcia narracyjnego
3. Demistyfikacja na końcu i pokazanie, jak łatwo ulec iluzji analitycznej, gdy obserwuje się wycinek danych wyrwany z szerszego kontekstu historycznego.

# 📖 Struktura opowieści: Przewodnik po Aktach

## Akt 1: Scena i Aktorzy (Ekspozycja)

Pierwszy akt pełni rolę ekspozycji, wprowadzając odbiorcę w architekturę rynku medycznego zanim na osi czasu pojawi się jakikolwiek kryzys. Zamiast traktować branżę zdrowotną jako monolit, narracja dzieli 21 analizowanych podmiotów z pliku lista_firm.csv na cztery wyspecjalizowane podsektory o zupełnie innej dynamice biznesowej:

* Big Pharma (Dystrybucja i kapitał): Globalne koncerny posiadające potężne zaplecze produkcyjne, kapitałowe i dystrybucyjne, takie jak Pfizer czy Johnson & Johnson.
* Biotechnologia (Innowacja i spekulacja): Mniejsze, zwinne podmioty naukowe żyjące z patentów, dotacji i obietnic przełomowych terapii (np. technologia mRNA), co czyni je podatnymi na bańki spekulacyjne.
* Diagnostyka (Wykrywanie chorób): Spółki takie jak Abbott, których przychody eksplodują w pierwszej fazie zagrożenia dzięki masowemu zapotrzebowaniu na testy.
* Technologie i Sprzęt (Narzędzia badawcze): Dostawcy infrastruktury laboratoryjnej (np. Thermo Fisher, Danaher), którzy zarabiają na samym trwaniu wyścigu naukowego, niezależnie od tego, kto ostatecznie opracuje lek.

Mechanizm wizualny: Interaktywna mapa drzewa wygenerowana za pomocą funkcji _geom_treemap()_ prezentuje strukturę sił rynkowych. Wielkość kafelków nie jest wartością statyczną, lecz dynamicznie wyliczanym średnim dziennym obrotem giełdowym _(close * volume)_ z ostatniego roku. Kliknięcie w wybrany podmiot odsłania karty informacyjne z aktualną wyceną i kontekstem historycznym spółki.

<img width="1467" height="899" alt="image" src="https://github.com/user-attachments/assets/13bce189-3a08-497d-9029-27f5b55520d9" />


## Akt 2: Wybuch i Szok (Punkt Zapalny)

Drugi akt stanowi realizację głównej tezy o kryzysie jako katalizatorze spekulacyjnym. Narracja skupia się na tzw. „Dniu Zero” dla czterech globalnych zagrożeń epidemiologicznych: epidemii SARS (2003), Świńskiej Grypy H1N1 (2009), wirusa Ebola (2014) oraz pandemii COVID-19 (2020).

W tym akcie dane są celowo przefiltrowane i znormalizowane tak, aby udowodnić tezę o odrywaniu się wycen sektora medycznego od reszty gospodarki:

* Okno obserwacji i indeksacja: Analiza zostaje zawężona do okresu od 1 roku przed do 2 lat po wybuchu kryzysu, a wyceny spółki oraz indeksu S&P 500 są sprowadzane do wspólnej bazy 100 w dniu ogłoszenia zagrożenia _((close / base_close) * 100)_.
* Wykres dynamiki zwrotu: Zestawienie wybranej spółki z szerokim rynkiem wizualnie uwypukla moment rozejścia się krzywych po przekroczeniu czerwonej linii oznaczającej wybuch epidemii.
* Skok wolumenu i mapa cieplna: Wykres słupkowy dziennego wolumenu obrotu oraz miesięczna mapa cieplna stóp zwrotu _(tq_transmute())_ dokumentują gwałtowny napływ kapitału spekulacyjnego na wieść o chorobie.

Gdyby opowieść zakończyła się na Akcie 2, odbiorca wyszedłby z jednoznacznym przekonaniem, że każda pandemia to dla całego sektora medycznego gwarancja ponadprzeciętnych zysków.

<img width="1469" height="901" alt="image" src="https://github.com/user-attachments/assets/35d7bfa2-f0e6-400b-a528-fbff4a356f67" />

## Akt 3: Pokłosie i Rozliczenie (Konfrontacja z rzeczywistością)

Trzeci akt dokonuje celowego zwrotu narracyjnego i rewiduje wnioski z Aktu 2, używając tych samych danych źródłowych, ale zmieniając zastosowaną miarę statystyczną oraz horyzont czasowy. Zamiast mierzyć wzrosty od „Dnia Zero”, aplikacja bada całe dostępne spektrum historyczne od 2000 roku i skupia się na wskaźniku obsunięcia kapitału od szczytu (Drawdown):

* Głębokość tąpnięcia (Drawdown): Za pomocą funkcji _cummax(close)_ wyznaczany jest historyczny szczyt notowań, od którego liczona jest procentowa utrata wartości w każdym kolejnym dniu _((close / max_historic_close) - 1)_.
* Wskaźnik retencji zysku: Wykres słupkowy zestawia ze sobą bezpośrednio wycenę na szczycie spekulacyjnej bańki z wyceną obecną.

Wniosek płynący z zmiany perspektywy: Akt 3 obnaża fakt, że gdy temat choroby znika z mediów, większość mniejszych spółek biotechnologicznych doświadcza drastycznego załamania kursu, a ich pandemiczne wyceny okazują się jedynie pękniętą bańką giełdową. Kapitał i długoterminową wartość zatrzymują głównie zdywersyfikowane korporacje z grupy Big Pharma oraz dostawcy sprzętu laboratoryjnego.

# 🛠️ Architektura i rozwiązanie techniczne

Aplikacja została zaprojektowana z podziałem na trzy główne warstwy logiczne:

* Warstwa danych i konfiguracji (global.R): Odpowiada za wczytanie metadanych z pliku lista_firm.csv, pobranie notowań historycznych przez pakiet _tidyquant (tq_get())_ oraz ich lokalne buforowanie w pliku pharma_stock_cache.rds (odświeżane raz na dobę). W tej warstwie następuje również dynamiczne przeliczenie wielkości rynkowej spółek oraz wygenerowanie siatki współrzędnych dla mapy drzewa za pomocą _treemapify()_.
* Warstwa interfejsu użytkownika (ui.R): Zbudowana w oparciu o _fluidPage()_ z niestandardowymi arkuszami stylów CSS (układ Flexbox dla panelu bocznego ze strefą przewijania). Wykorzystuje panele warunkowe (conditionalPanel), które dynamicznie podmieniają treść narracyjną i kontrolki sterujące w zależności od wybranego aktu.
* Warstwa logiki serwerowej (server.R): Zarządza reaktywnym stanem aplikacji (_reactiveVal_) i synchronizuje wybór spółki oraz tryb sortowania pomiędzy zakładkami. Obsługuje m.in. detekcję kliknięć na płótnie wykresu _ggplot2_ poprzez mapowanie współrzędnych kursora na granice prostokątów (xmin, xmax, ymin, ymax).

# 📦 Wymagane pakiety i uruchomienie

Do uruchomienia projektu w środowisku R wymagane są następujące biblioteki:
```{r}
install.packages(c(
  "shiny",
  "tidyquant",
  "tidyverse",
  "lubridate",
  "treemapify",
  "scales"
))
```

Aby uruchomić aplikację lokalnie, upewnij się, że plik lista_firm.csv znajduje się w głównym katalogu roboczym projektu, a następnie wykonaj polecenie:

```{r}
shiny::runApp()
```

Przy pierwszym uruchomieniu aplikacja pobierze historyczne dane giełdowe z serwisu Yahoo Finance i zapisze je w pamięci podręcznej (plik pharma_stock_cache.rds), co przyspieszy kolejne sesje w tym samym dniu.
