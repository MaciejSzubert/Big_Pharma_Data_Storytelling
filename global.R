library(shiny)
library(tidyquant)
library(tidyverse)
library(lubridate)
library(treemapify)
library(scales)

# 1. Definicja polskich miesięcy do użycia w wykresach
polskie_miesiace <- c("Sty", "Lut", "Mar", "Kwi", "Maj", "Cze", 
                      "Lip", "Sie", "Wrz", "Paź", "Lis", "Gru")

csv_file <- "lista_firm.csv"

companies_df <- read_delim(csv_file, delim = ";", show_col_types = FALSE)

unikalne_sektory <- unique(companies_df$Sector)
liczba_sektorow <- length(unikalne_sektory)
paleta <- hcl.colors(n = liczba_sektorow, palette = "Dark 3")
kolory_dynamiczne <- setNames(paleta, unikalne_sektory)

# -------------------------------------------------

# Wszystkie unikalne tickery + Indeks rynkowy S&P 500 do benchmarku
all_tickers <- unique(c(companies_df$Ticker, "^GSPC"))

# 2. System cache'owania danych giełdowych (raz na dobę)
cache_file <- "pharma_stock_cache.rds"
needs_fetch <- TRUE

if (file.exists(cache_file)) {
  file_date <- as.Date(file.info(cache_file)$mtime)
  if (file_date == Sys.Date()) {
    needs_fetch <- FALSE
  }
}

if (needs_fetch) {
  stock_data <- tq_get(all_tickers, get = "stock.prices", from = "2000-01-01") %>%
    drop_na(close, volume)
  saveRDS(stock_data, cache_file)
} else {
  stock_data <- readRDS(cache_file)
}

# --- DYNAMICZNE OBLICZANIE APPROXSIZE Z YAHOO FINANCE ---
# Obliczamy średni dzienny obrót (Cena * Wolumen) z ostatniego roku jako realny wskaźnik wielkości
real_sizes <- stock_data %>%
  filter(symbol != "^GSPC") %>%
  group_by(symbol) %>%
  filter(date >= max(date) - years(1)) %>%
  summarise(ApproxSize = mean(close * volume, na.rm = TRUE) / 1000000, .groups = "drop") %>%
  rename(Ticker = symbol)

companies_df <- companies_df %>%
  select(-any_of("ApproxSize")) %>%
  left_join(real_sizes, by = "Ticker") %>%
  mutate(ApproxSize = coalesce(ApproxSize, 10)) 


# 3. Wydarzenia/kryzysy
events_df <- tibble(
  EventID = c("SARS", "H1N1", "EBOLA", "COVID"),
  Label = c("SARS (2003)", "Świńska Grypa H1N1 (2009)", "Ebola (2014)", "COVID-19 (2020)"),
  Date = as.Date(c("2003-02-10", "2009-04-15", "2014-03-23", "2020-01-23"))
)

companies_df <- companies_df %>%
  arrange(Sector, desc(ApproxSize), Name)

layout_lookup <- treemapify::treemapify(
  companies_df,
  area = "ApproxSize",
  subgroup = "Sector"
)