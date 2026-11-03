function(input, output, session) {
  
  # --- 1. Zarządzanie stanem (Reactive State) ---
  selected_ticker   <- reactiveVal("PFE")
  selected_event    <- reactiveVal("COVID")
  sort_alphabetical <- reactiveVal(FALSE) 
  
  error_msg_tab2    <- reactiveVal("")
  error_msg_tab3    <- reactiveVal("")
  
  # --- 2. Obsługa przycisków przełączania sortowania (Zsynchronizowana) ---
  observeEvent(input$btn_toggle_sort, {
    sort_alphabetical(!sort_alphabetical())
  })
  
  observeEvent(input$btn_toggle_sort_tab3, {
    sort_alphabetical(!sort_alphabetical())
  })
  
  observe({
    is_alt <- sort_alphabetical()
    if (is_alt) {
      updateActionButton(session, "btn_toggle_sort", label = "Domyślnie", icon = icon("sort-numeric-down"))
      updateActionButton(session, "btn_toggle_sort_tab3", label = "Domyślnie", icon = icon("sort-numeric-down"))
    } else {
      updateActionButton(session, "btn_toggle_sort", label = "Sortuj A-Z", icon = icon("sort-alpha-down"))
      updateActionButton(session, "btn_toggle_sort_tab3", label = "Sortuj A-Z", icon = icon("sort-alpha-down"))
    }
  })
  
  # --- 3. Dynamiczne przyciski ---
  output$event_buttons_ui <- renderUI({
    btns <- lapply(1:nrow(events_df), function(i) {
      ev_id  <- events_df$EventID[i]
      ev_lbl <- events_df$Label[i]
      is_sel <- if(selected_event() == ev_id) "btn-selected" else ""
      actionButton(inputId = paste0("evt_", ev_id), label = ev_lbl, 
                   class = paste("btn btn-default btn-custom btn-block", is_sel))
    })
    do.call(tagList, btns)
  })
  
  output$ticker_buttons_ui_tab2 <- renderUI({
    display_df <- companies_df
    if (sort_alphabetical()) {
      display_df <- display_df %>% arrange(Name)
    }
    
    btns <- lapply(display_df$Ticker, function(tk) {
      c_name <- display_df %>% filter(Ticker == tk) %>% pull(Name)
      is_sel <- if(selected_ticker() == tk) "btn-selected" else ""
      actionButton(inputId = paste0("tk2_", tk), label = paste0(c_name, " (", tk, ")"), 
                   class = paste("btn btn-default btn-custom btn-block", is_sel))
    })
    do.call(tagList, btns)
  })
  
  output$ticker_buttons_ui_tab3 <- renderUI({
    display_df <- companies_df
    if (sort_alphabetical()) {
      display_df <- display_df %>% arrange(Name)
    }
    
    btns <- lapply(display_df$Ticker, function(tk) {
      c_name <- display_df %>% filter(Ticker == tk) %>% pull(Name)
      is_sel <- if(selected_ticker() == tk) "btn-selected" else ""
      actionButton(inputId = paste0("tk3_", tk), label = paste0(c_name, " (", tk, ")"), 
                   class = paste("btn btn-default btn-custom btn-block", is_sel))
    })
    do.call(tagList, btns)
  })
  
  # --- 4. Obserwatory zdarzeń wejściowych ---
  lapply(events_df$EventID, function(ev_id) {
    observeEvent(input[[paste0("evt_", ev_id)]], {
      selected_event(ev_id)
      error_msg_tab2("") 
    })
  })
  
  lapply(unique(companies_df$Ticker), function(tk) {
    observeEvent(input[[paste0("tk2_", tk)]], {
      selected_ticker(tk)
      error_msg_tab2("")
      error_msg_tab3("")
    })
  })
  
  lapply(unique(companies_df$Ticker), function(tk) {
    observeEvent(input[[paste0("tk3_", tk)]], {
      selected_ticker(tk)
      error_msg_tab2("")
      error_msg_tab3("")
    })
  })
  
  output$error_ui_tab2 <- renderUI({
    req(error_msg_tab2())
    div(class="error-box", error_msg_tab2())
  })
  
  output$error_ui_tab3 <- renderUI({
    req(error_msg_tab3())
    div(class="error-box", error_msg_tab3())
  })

  # --- 5. Akt 1: Scena i aktorzy --- 
  selected_treemap_tickers <- reactiveVal(character(0))
  
  observeEvent(input$treemap_click, {
    click <- input$treemap_click
    req(click)
    
    matched_row <- layout_lookup %>%
      filter(click$x >= xmin, click$x <= xmax, 
             click$y >= ymin, click$y <= ymax)
    
    if (nrow(matched_row) > 0) {
      target_ticker <- matched_row$Ticker[1]
      current_selected <- selected_treemap_tickers()
      
      if (target_ticker %in% current_selected) {
        selected_treemap_tickers(setdiff(current_selected, target_ticker))
      } else {
        selected_treemap_tickers(c(current_selected, target_ticker))
      }
    }
  })
  
  lapply(unique(companies_df$Ticker), function(tk) {
    observeEvent(input[[paste0("remove_box_", tk)]], {
      current_selected <- selected_treemap_tickers()
      selected_treemap_tickers(setdiff(current_selected, tk))
    })
    observeEvent(input$btn_clear_all, {
      selected_treemap_tickers(character(0))
    })
  })
  
  output$company_click_info_container <- renderUI({
    tickers <- selected_treemap_tickers()
    
    if (length(tickers) == 0) {
      return(div(style = "color: #7f8c8d; font-style: italic; font-size: 13px; margin-top: 10px;", 
                 "Kliknij na konkretne spółki, aby dowiedzieć się o nich więcej."))
    }
    
    boxes_ui <- lapply(tickers, function(tk) {
      comp <- companies_df %>% filter(Ticker == tk) %>% slice(1)
      req(nrow(comp) > 0)
      
      sector_color <- kolory_dynamiczne[comp$Sector]
      if (is.na(sector_color)) sector_color <- "#2c3e50"
      
      rgb_components <- col2rgb(sector_color)
      bg_rgba <- paste0("rgba(", rgb_components[1], ",", rgb_components[2], ",", rgb_components[3], ", 0.15)")
      
      latest_stock_info <- stock_data %>% filter(symbol == tk)
      price_text <- "Brak notowań"
      if (nrow(latest_stock_info) > 0) {
        latest_price <- latest_stock_info %>% filter(date == max(date)) %>% pull(close)
        if (length(latest_price) > 0) price_text <- paste0(round(latest_price[1], 2), " USD")
      }
      
      div(
        style = paste0("margin-top: 10px; padding: 12px; background-color: ", bg_rgba, 
                       "; border-left: 5px solid ", sector_color, 
                       "; border-radius: 4px; position: relative; box-shadow: 0 1px 3px rgba(0,0,0,0.05);"),
        
        actionLink(
          inputId = paste0("remove_box_", tk),
          label = icon("times-circle"),
          style = "position: absolute; top: 8px; right: 10px; color: #7f8c8d; font-size: 16px; text-decoration: none; transition: color 0.2s;"
        ),
        
        h5(style = "font-weight: bold; margin-top: 0; color: #2c3e50; margin-bottom: 6px; padding-right: 20px;", 
           paste0(comp$Name, " (", tk, ")")),
        
        div(style = "display: flex; align-items: center; margin-bottom: 4px; font-size: 12px; color: #333;",
            tags$b("Kraj pochodzenia: ", style = "margin-right: 4px;"),
            tags$img(src = paste0("https://flagcdn.com/16x12/", comp$CountryCode, ".png"), 
                     style = "margin-right: 5px; border-radius: 2px; box-shadow: 0 0 1px rgba(0,0,0,0.5);", 
                     width = "16", height = "12"),
            comp$Country
        ),
        
        p(style = "margin-bottom: 4px; font-size: 12px; color: #333;", tags$b("Sektor: "), comp$Sector),
        p(style = "margin-bottom: 6px; font-size: 12px; color: #27ae60; font-weight: bold;", tags$b("Cena aktualna: "), price_text),
        p(style = "margin-bottom: 0; font-size: 12px; line-height: 1.4; color: #5a626a; border-top: 1px solid rgba(0,0,0,0.08); padding-top: 6px;", 
          tags$b("Informacje: "), comp$Context)
      )
    })
    
    do.call(tagList, boxes_ui)
  })
  # --- 6. Rysowanie Akt 1: Treemapa ---
  output$treemap_plot <- renderPlot({
    companies_df %>%
      ggplot(aes(area = ApproxSize, fill = Sector, subgroup = Sector,
                 label = paste0(Name, "\n(", Ticker, ")"))) +
      geom_treemap(color = "white", linewidth = 2) +
      geom_treemap_subgroup_border(color = "#2c3e50", linewidth = 4) +
      geom_treemap_text(colour = "white", place = "center", reflow = TRUE, fontface = "bold") +
      scale_fill_manual(values = kolory_dynamiczne) +
      coord_cartesian(expand = FALSE) + # KLUCZOWE: Usuwa sztuczny padding (5%), który przesuwa siatkę kliknięć
      theme_minimal(base_size = 15) +
      theme(plot.title = element_text(face="bold"), 
            legend.position = "bottom",
            legend.title = element_text(face = "bold"),
            legend.key.size = unit(1.5, "lines"), 
            legend.spacing.x = unit(0.03, "npc"), 
            legend.spacing.y = unit(0.02, "npc") ) +
      guides(fill = guide_legend(byrow = TRUE)) +
      labs(fill = "Podsektor branżowy: ", title = "Struktura wartości rynkowej z podziałem na specjalizacje")
  })
  
  # --- 7. Rysowanie Akt 2: Logika i Benchmarking ---
  reactive_tab2_data <- reactive({
    req(selected_ticker(), selected_event())
    
    ev_info <- events_df %>% filter(EventID == selected_event())
    ev_date <- ev_info$Date
    
    start_date <- ev_date - years(1)
    end_date   <- ev_date + years(2)
    
    df_raw <- stock_data %>%
      filter(symbol %in% c(selected_ticker(), "^GSPC"),
             date >= start_date, date <= end_date)
    
    if (nrow(df_raw %>% filter(symbol == selected_ticker())) == 0) {
      error_msg_tab2(paste0("Brak notowań rynkowych: Podmiot ", selected_ticker(), 
                            " nie był jeszcze publicznie notowany w okresie kryzysu: ", ev_info$Label))
      req(FALSE)
    }
    
    base_prices <- df_raw %>%
      group_by(symbol) %>%
      filter(date >= ev_date) %>%
      slice_min(date, n = 1) %>%
      select(symbol, base_close = close)
    
    df_normalized <- df_raw %>%
      left_join(base_prices, by = "symbol") %>%
      group_by(symbol) %>%
      mutate(norm_close = (close / base_close) * 100) %>%
      ungroup()
    
    list(df = df_normalized, ev_date = ev_date, label = ev_info$Label)
  })
  
  output$price_bench_plot <- renderPlot({
    data_ctx <- reactive_tab2_data()
    
    comp_sector <- companies_df %>% filter(Ticker == selected_ticker()) %>% pull(Sector)
    
    ticker_label    <- paste0(selected_ticker(), " (Wybrana spółka z sektora ", comp_sector, ")")
    benchmark_label = "S&P 500"
    
    comp_sector <- companies_df %>% filter(Ticker == selected_ticker()) %>% pull(Sector)
    company_color <- if(length(comp_sector) > 0) kolory_dynamiczne[comp_sector] else "#2c3e50"
    
    color_mapping     <- setNames(c(company_color, "#7f8c8d"), c(ticker_label, benchmark_label))
    linewidth_mapping <- setNames(c(1.3, 0.8), c(ticker_label, benchmark_label))
    
    data_ctx$df %>%
      mutate(Legenda = if_else(symbol == "^GSPC", benchmark_label, ticker_label)) %>%
      ggplot(aes(x = date, y = norm_close, color = Legenda, linewidth = Legenda)) +
      geom_line() +
      geom_vline(xintercept = as.numeric(data_ctx$ev_date), linetype = "dashed", color = "#c0392b", linewidth = 1.2) +
      scale_color_manual(values = color_mapping) +
      scale_linewidth_manual(values = linewidth_mapping) +
      theme_minimal(base_size = 15) +
      labs(x = "", y = "Skalowana Wycena (Początek kryzysu = 100)", 
           title = "Porównanie dynamiki zwrotu: Spółka medyczna vs Reszta Świata (Główny Indeks Giełdowy)",
           color = NULL, linewidth = NULL) +
      theme(legend.position = "top", plot.title = element_text(face="bold"))
  })
  
  output$volume_shock_plot <- renderPlot({
    data_ctx <- reactive_tab2_data()
    
    data_ctx$df %>%
      filter(symbol == selected_ticker()) %>%
      ggplot(aes(x = date, y = volume)) +
      geom_col(fill = "#34495e", width = 3) +
      geom_vline(xintercept = as.numeric(data_ctx$ev_date), linetype = "dashed", color = "#c0392b", linewidth = 1) +
      scale_y_continuous(labels = label_number(suffix = " mln", scale = 1e-6)) +
      theme_minimal(base_size = 14) +
      labs(x = "Oś czasu", y = "Liczba obróconych akcji dziennie", title = "Skok wolumenu: Napływ kapitału spekulacyjnego na wieść o chorobie") +
      theme(plot.title = element_text(face="bold"))
  })
  
  output$heatmap_returns_plot <- renderPlot({
    data_ctx <- reactive_tab2_data()
    
    monthly_data <- data_ctx$df %>%
      filter(symbol == selected_ticker()) %>%
      tq_transmute(select = close, mutate_fun = periodReturn, period = "monthly", col_rename = "monthly_ret") %>%
      mutate(
        Rok = factor(year(date)),
        Miesiac = factor(month(date), levels = 1:12, labels = polskie_miesiace)
      )
    
    monthly_data %>%
      ggplot(aes(x = Miesiac, y =  Rok, fill = monthly_ret)) +
      geom_tile(color = "white") +
      scale_fill_gradient2(low = "#8B0000", mid = "#DDE4EA", high = "#437EB4", midpoint = 0, labels = percent) +
      theme_minimal(base_size = 14) +
      labs(x = "Miesiąc roku", y = "Rok kalendarzowy", fill = "Stopa zwrotu", title = "Mapa cieplna zysków/strat w ujęciu miesięcznym") + 
      theme(panel.grid = element_blank(), plot.title = element_text(face="bold")) + 
      scale_y_discrete(limits = rev) 
  })
  
  # --- 8. Rysowanie Akt 3: Rozliczenie (Drawdown) ---
  reactive_tab3_data <- reactive({
    req(selected_ticker())
    
    df_ticker <- stock_data %>% filter(symbol == selected_ticker())
    
    if (nrow(df_ticker) == 0) {
      error_msg_tab3("Brak danych dla wybranej spółki.")
      req(FALSE)
    }
    
    df_drawdown <- df_ticker %>%
      arrange(date) %>%
      mutate(max_historic_close = cummax(close),
             drawdown_pct = (close / max_historic_close) - 1)
    
    peak_record    <- df_drawdown %>% slice_max(close, n = 1) %>% select(price = close, date)
    current_record <- df_drawdown %>% slice_max(date, n = 1) %>% select(price = close, date)
    
    list(df = df_drawdown, peak = peak_record, current = current_record)
  })
  
  output$drawdown_plot <- renderPlot({
    data_ctx <- reactive_tab3_data()
    
    data_ctx$df %>%
      ggplot(aes(x = date, y = drawdown_pct)) +
      geom_area(fill = "#e74c3c", alpha = 0.3, color = "#c0392b") +
      scale_y_continuous(labels = percent) +
      scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
      theme_minimal(base_size = 14) +
      labs(x = "Lata analizy", y = "Spadek od historycznego szczytu wszech czasów", 
           title = "Głębokość tąpnięcia: Co dzieje się z kursem, gdy temat choroby znika z mediów?") +
      theme(plot.title = element_text(face="bold"))
  })
  
  output$hangover_plot <- renderPlot({
    data_ctx <- reactive_tab3_data()
    
    summary_df <- tibble(
      Okres = c("Szczyt Bańki (Maksimum)", "Wycena Obecna (Aktualna)"),
      Cena = c(data_ctx$peak$price, data_ctx$current$price)
    )
    
    summary_df %>%
      ggplot(aes(x = Okres, y = Cena, fill = Okres)) +
      geom_bar(stat = "identity", width = 0.35) +
      geom_text(aes(label = paste0(round(Cena, 2), " USD")), vjust = -0.5, size = 4.5) +
      scale_fill_manual(values = c("Szczyt Bańki (Maksimum)" = "#c0392b", "Wycena Obecna (Aktualna)" = "#27ae60")) +
      theme_minimal(base_size = 14) +
      expand_limits(y = max(summary_df$Cena) * 1.15) +
      labs(x = "", y = "Wartość rynkowa jednej akcji", title = "Wskaźnik retencji zysku: Kto zatrzymał kapitał, a kto stracił?") +
      theme(legend.position = "none", plot.title = element_text(face="bold"), panel.grid.major.x = element_blank())
  })
}