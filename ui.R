fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #f4f6f9; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
      
      /* Panel boczny jako główny kontener Flexbox o stałej proporcji wysokości ekranu */
      .sidebar-panel { background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); padding: 20px; height: 82vh; display: flex; flex-direction: column; }
      
      /* Wymuszenie, by panele warunkowe (conditionalPanel) zachowywały się jak elastyczne kolumny */
      .sidebar-panel > div { display: flex; flex-direction: column; height: 100%; flex-grow: 1; min-height: 0; }
      
      /* Ta klasa idzie bezpośrednio na uiOutput – przejmuje resztę wolnego miejsca i aktywuje przewijanie */
      .dynamic-scroll-area { flex-grow: 1; overflow-y: auto; overflow-x: hidden; padding-right: 5px; min-height: 0; }
      
      .error-box { color: #721c24; background-color: #f8d7da; border-left: 5px solid #dc3545; padding: 12px; margin-top: 15px; border-radius: 4px; font-weight: 500; }
      .btn-custom { margin: 4px 0; width: 100%; border-radius: 4px; font-weight: 500; transition: all 0.2s; text-align: left; }
      .btn-selected { background-color: #2c3e50 !important; color: white !important; border-color: #2c3e50 !important; font-weight: bold; }
      .story-text { font-size: 13px; line-height: 1.5; color: #5a626a; margin-bottom: 12px; }
      .tab-title { color: #2c3e50; font-weight: bold; margin-bottom: 15px; border-bottom: 2px solid #ecf0f1; padding-bottom: 8px; }
      .step-header-container { display: flex; justify-content: space-between; align-items: center; margin-top: 15px; }
    "))
  ),
  
  titlePanel(div(style="font-weight: bold; color: #2c3e50; padding: 10px 0;", 
                 "Data Storytelling: Czy Big Pharma bogaci się na pandemiach?")),
  
  sidebarLayout(
    sidebarPanel(
      class = "sidebar-panel",
      width = 3,
      
      # AKT 1 Panel
      conditionalPanel(
        condition = "input.story_tabs == 'tab1'",
        
        div(class = "dynamic-scroll-area", style = "padding-right: 5px;",
            h4(style="color: #2c3e50; font-weight: bold;", "Akt 1: Scena i Aktorzy"),
            p(class = "story-text", "Zanim przyjrzymy się epidemiom oraz innym plagom, musimy poznać strukturę sił w tym sektorze gospodarki, które walczą z nimi."),
            
            tags$ul(class = "story-text", style = "padding-left: 20px; list-style-type: square;",
                    tags$li(style = "margin-bottom: 10px;", 
                            tags$b("Big Pharma (Dystrybucja i kapitał): "), 
                            "Potoczne określenie największych globalnych koncernów farmaceutycznych, które posiadają dominujący wpływ na rynek leków, politykę zdrowotną i finansowanie badań naukowych (np. Pfizer, Johnson & Johnson)."
                    ),
                    tags$li(style = "margin-bottom: 10px;", 
                            tags$b("Biotechnologia (Innowacja i Spekulacja): "), 
                            "To z reguły mniejsze, bardzo zwinne firmy i spółki czysto naukowe naukowe. Nie mają fabryk na całym świecie, ale posiadają patenty. Żyją one z dotacji i obietnic (np. technologia mRNA), które mogą tworzyć bańki spekulacyjne."
                    ),
                    tags$li(style = "margin-bottom: 10px;", 
                            tags$b("Diagnostyka (Wykrywanie chorób i profilowanie pacjentów): "), 
                            "Firmy produkujące np. testy immunologiczne, genetyczne, systemy analizy krwi. Ich biznes eksploduje jako pierwszy, zanim w ogóle powstanie jakakolwiek szczepionka, ponieważ rządy natychmiach potrzebują narzędzi do masowej kontroli populacji. Zarabiają na czystej liczbie przeprowadzonych testów (np. Abbott)."
                    ),
                    tags$li(style = "margin-bottom: 10px;", 
                            tags$b("Technologie i Sprzęt (Narzędzia i infrastruktura badawcza): "), 
                            "Producenci maszyn laboratoryjnych, wirówek, probówek i odczynników. To absolutnie najbezpieczniejszy biznes: niezależnie od tego, która firma z sektora Biotech wygra wyścig po szczepionkę, każda z nich musi kupić sprzęt badawczy od tych dostawców. Zarabiają na samym fakcie, że wyścig trwa (np. Thermo Fisher, Danaher)."
                    )
            ),
            
            hr(),
            
            div(style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;",
                h5(style="font-weight: bold; color: #2c3e50; margin: 0;", "Szczegóły wybranych podmiotów:"),
                actionButton("btn_clear_all", "Wyczyść wszystko", icon = icon("trash-alt"), class = "btn btn-default btn-xs", style = "font-size: 11px; padding: 3px 8px; border-radius: 4px;")
            ),
            
            uiOutput("company_click_info_container")
        )
      ),
      
      # AKT 2 Panel
      conditionalPanel(
        condition = "input.story_tabs == 'tab2'",
        h4(style="color: #2c3e50; font-weight: bold;", "Akt 2: Wybuch i Szok"),
        p(class = "story-text", "Moment wybuchu globalnej paniki to dla jednych paraliż, a dla innych bezprecedensowa okazja biznesowa. Wybierz kryzys oraz podmiot, aby zobaczyć, jak w dniu ogłoszenia zagrożenia (Dzień Zero) sektor medyczny drastycznie odrywa się od tracącej na wartości szerokiej gospodarki."),
        
        h5(style="font-weight: bold; margin-top: 15px;", "Krok 1: Wybierz Kryzys:"),
        uiOutput("event_buttons_ui"),
        
        hr(),
        div(class = "step-header-container",
            h5(style="font-weight: bold; margin: 0;", "Krok 2: Wybierz Podmiot:"),
            actionButton(inputId = "btn_toggle_sort", label = "Sortuj A-Z", icon = icon("sort-alpha-down"), 
                         class = "btn btn-default btn-xs", style = "padding: 2px 6px; font-size: 11px;")
        ),
        br(),
        uiOutput("ticker_buttons_ui_tab2", class = "dynamic-scroll-area"),
        
        uiOutput("error_ui_tab2")
      ),
      
      # AKT 3 Panel
      conditionalPanel(
        condition = "input.story_tabs == 'tab3'",
        h4(style="color: #2c3e50; font-weight: bold;", "Akt 3: Pokłosie i Rozliczenie"),
        p(class = "story-text", "Kiedy gasną kamery, a strach przed chorobą mija, produkty medyczne tracą status pilnej potrzeby, a spekulacyjna gorączka złota dobiega końca."),
        p(class = "story-text", "Wybierz podmiot, aby zweryfikować brutalne zderzenie z rzeczywistością: sprawdź głębokość utraty kapitału od historycznego szczytu (Drawdown) i zobacz, kto zatrzymał gotówkę na stałe, a czyj wykres okazał się tylko pękniętą bańką."),
        
        div(class = "step-header-container",
            h5(style="font-weight: bold; margin: 0;", "Wybierz Podmiot do weryfikacji:"),
            actionButton(inputId = "btn_toggle_sort_tab3", label = "Sortuj A-Z", icon = icon("sort-alpha-down"), 
                         class = "btn btn-default btn-xs", style = "padding: 2px 6px; font-size: 11px;")
        ),
        br(),
        uiOutput("ticker_buttons_ui_tab3", class = "dynamic-scroll-area"),
        
        uiOutput("error_ui_tab3")
      )
    ),
    
    mainPanel(
      width = 9,
      tabsetPanel(
        id = "story_tabs",
        
        tabPanel(
          title = "Akt 1: Wielkość Rynku (Ogół)",
          value = "tab1",
          br(),
          h3(class = "tab-title", "Rozkład sił branży medycznej"),
          div(style = "height: 65vh; min-height: 400px;", 
              plotOutput("treemap_plot", height = "100%", click = "treemap_click")
          )
        ),
        
        tabPanel(
          title = "Akt 2: Punkt Zapalny & Porównania (Wydarzenie)",
          value = "tab2",
          br(),
          h3(class = "tab-title", "Oderwanie od rzeczywistości: Sektor zdrowia vs szeroki rynek (S&P 500)"),
          div(style = "height: 38vh; position: relative;",
              plotOutput("price_bench_plot", height = "100%", fill = TRUE)
          ),
          br(),
          fluidRow(
            column(6, 
                   div(style = "height: 28vh; position: relative;",
                       plotOutput("volume_shock_plot", height = "100%", fill = TRUE)
                   )
            ),
            column(6, 
                   div(style = "height: 28vh; position: relative;",
                       plotOutput("heatmap_returns_plot", height = "100%", fill = TRUE)
                   )
            )
          )
        ),
        
        tabPanel(
          title = "Akt 3: Pokłosie & Drawdown (Szczegół)",
          value = "tab3",
          br(),
          h3(class = "tab-title", "Koniec gorączki złota: Maksymalne obsunięcie kapitału od szczytu"),
          div(style = "height: 38vh; position: relative;",
              plotOutput("drawdown_plot", height = "100%", fill = TRUE)
          ),
          br(),
          div(style = "height: 28vh; position: relative;",
              plotOutput("hangover_plot", height = "100%", fill = TRUE)
          )
        )
      )
    )
  )
)