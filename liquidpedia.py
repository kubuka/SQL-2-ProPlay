import requests
import json 

def get_teams_from_lolesports_api_with_params():
    """
    Pobiera nazwy drużyn i tagi z LoL Esports API, używając podanego klucza API,
    endpointu i wymaganych parametrów zapytania.
    """
    api_url = "https://esports-api.lolesports.com/persisted/gw/getTeams"
    api_key = "0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z"

    # Nagłówki HTTP
    headers = {
        "x-api-key": api_key,
        "User-Agent": "TwojaAplikacjaDoLoLData/1.0 (Python)" # Dobra praktyka
    }

    # Parametry zapytania (query parameters)
    # 'hl' jest Wymagany!
    # 'id' jest Opcjonalny - możesz podać listę slugów drużyn, aby filtrować
    params = {
        "hl": "pl-PL"  # Ustawiamy język na polski
        # "id": ["t1", "fnc"] # Opcjonalnie: odkomentuj, aby pobrać tylko wybrane drużyny
    }

    all_teams = {} 

    print(f"Łączę się z API LoL Esports pod adresem: {api_url} z parametrami...")
    try:
        # Wykonujemy zapytanie GET, przekazując nagłówki i parametry
        response = requests.get(api_url, headers=headers, params=params)
        response.raise_for_status() # Sprawdza, czy zapytanie zakończyło się sukcesem

        data = response.json()

        # Sprawdzamy strukturę odpowiedzi, aby upewnić się, że dane o drużynach istnieją
        if not data or 'data' not in data or 'teams' not in data['data']:
            print("Brak danych o drużynach w odpowiedzi API lub nieoczekiwana struktura.")
            return {}

        teams_list = data['data']['teams']

        print(f"Znaleziono {len(teams_list)} drużyn w odpowiedzi API.")

        for team in teams_list:
            team_name = team.get('name')
            team_slug = team.get('code') # Tag/skrót drużyny
            
            if team_name and team_slug:
                all_teams[team_slug] = team_name
            elif team_name:
                all_teams[team_name] = team_name # Fallback, jeśli slug jest pusty

    except requests.exceptions.HTTPError as e:
        print(f"Błąd HTTP podczas łączenia z API: {e}")
        print(f"Odpowiedź serwera: {e.response.text}")
    except requests.exceptions.ConnectionError as e:
        print(f"Błąd połączenia z siecią: {e}")
    except requests.exceptions.Timeout as e:
        print(f"Przekroczono czas połączenia z API: {e}")
    except requests.exceptions.RequestException as e:
        print(f"Wystąpił nieznany błąd podczas zapytania: {e}")
    except json.JSONDecodeError as e:
        print(f"Błąd dekodowania JSON: {e}. Odpowiedź serwera: {response.text}")
    except Exception as e:
        print(f"Wystąpił nieoczekiwany błąd: {e}")
    
    return all_teams

if __name__ == "__main__":
    teams = get_teams_from_lolesports_api_with_params()

    if teams:
        print("\n--- Nazwy drużyn i tagi z LoL Esports API (getTeams endpoint) ---")
        print("Skrót,Pełna nazwa")
        
        sorted_teams = sorted(teams.items(), key=lambda item: item[0].lower())
        for tag, name in sorted_teams:
            print(f"{tag},{name}")
    else:
        print("Nie udało się pobrać żadnych drużyn.")