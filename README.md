# Flutter Order Analyzer

Aplikacja mobilna Flutter, która pobiera listę produktów z API, a następnie wykorzystuje zewnętrzny model językowy (AI) do parsowania tekstu zamówienia, dopasowywania produktów i obliczania sum.

## 🚀 Funkcjonalności

* **Lista produktów**: Pobiera i wyświetla listę 50 produktów z `dummyjson.com`.
* **Wyszukiwanie produktów**: (Bonus) Umożliwia filtrowanie listy produktów.
* **Analiza AI**: Pozwala na wklejenie dowolnego tekstu (np. e-maila) i wysłanie go do modelu AI w celu ekstrakcji pozycji zamówienia (nazwa, ilość).
* **Dopasowanie**: Automatycznie dopasowuje pozycje zwrócone przez AI do pobranej listy produktów (używając fuzzy string matching).
* **Kalkulacja**: Oblicza sumę dla każdej dopasowanej pozycji (`ilość x cena`) oraz sumę całkowitą zamówienia.
* **Raport**: Prezentuje wynik w tabeli, wyraźnie oznaczając pozycje **dopasowane** i **niedopasowane**.
* **Eksport**: (Bonus) Umożliwia eksport wyniku analizy do pliku JSON.

## 🏛️ Architektura

Aplikacja jest zbudowana zgodnie z zasadami **Clean Architecture** oraz wykorzystuje wzorzec **BLoC** do zarządzania stanem.

* **Domain Layer**: Zawiera czystą logikę biznesową (encje, repozytoria, use case'y). Nie ma żadnych zależności od Fluttera ani zewnętrznych pakietów.
* **Data Layer**: Implementuje repozytoria z warstwy Domain. Odpowiada za pobieranie danych z zewnętrznych źródeł (API produktów, API modelu AI) oraz obsługę błędów.
* **Presentation Layer**: Zawiera UI (Widgety) oraz logikę prezentacji (BLoC).

## 🛠️ Konfiguracja i Uruchomienie

### 1. Wymagania wstępne

* Zainstalowane [Flutter SDK](https://flutter.dev/docs/get-started/install).
* Klucz API do zewnętrznego modelu językowego (np. OpenAI, Google Gemini).

### 2. Konfiguracja klucza AI

Aplikacja wczytuje klucz API z pliku konfiguracyjnego, który **nie jest** śledzony przez Git, aby zapewnić bezpieczeństwo.

1.  W katalogu głównym projektu przejdź do `assets/config/`.
2.  Znajdziesz tam plik `app_config.example.json`.
3.  Utwórz kopię tego pliku w tym samym katalogu i nazwij ją `app_config.json`.
4.  Otwórz `app_config.json` i wklej swój klucz API:

    ```json
    {
      "aiApiKey": "TWOJ_PRAWDZIWY_KLUCZ_API_TUTAJ"
    }
    ```

5.  Plik `app_config.json` jest już dodany do `.gitignore` i nie zostanie przypadkowo wysłany do repozytorium.

**Ważne**: Aplikacja nie uruchomi analizy AI, jeśli klucz będzie brakujący lub niepoprawny (zgodnie z wymaganiami).

### 3. Implementacja AI

Logika wywołania API modelu AI znajduje się w pliku:
`lib/features/order/data/datasources/order_ai_datasource.dart`

W metodzie `parseOrderText` należy dostosować:
* `_aiApiUrl`: Endpoint Twojego dostawcy AI.
* `prompt`: Treść prompta systemowego wysyłanego do AI.
* `data`: Body żądania (np. model, format odpowiedzi).
* Logikę parsowania odpowiedzi: Domyślnie oczekiwana jest odpowiedź JSON w formacie `[{"name": "...", "quantity": 0}]`.

### 4. Uruchomienie

1.  Pobierz zależności:
    ```bash
    flutter pub get
    ```
2.  Wygeneruj pliki (dla `json_serializable`):
    ```bash
    flutter pub run build_runner build
    ```
3.  Uruchom aplikację:
    ```bash
    flutter run
    ```