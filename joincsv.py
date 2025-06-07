import pandas as pd
# Nazwy plików
plik1_nazwa = '/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/tag_full.csv'
plik2_nazwa = '/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/tag_full_add.csv'

# Wczytaj pliki CSV
df1 = pd.read_csv(plik1_nazwa)
df2 = pd.read_csv(plik2_nazwa)

# Wykonaj lewe połączenie (left merge) df2 z df1 na kolumnie 'tag'.
# Dzięki sufiksom rozróżnimy kolumnę 'full' z df1 (full_x) od tej z df2 (full_y).
df_merged = pd.merge(df2, df1[['tag', 'full']], on='tag', how='left', suffixes=('', '_z_pierwszego'))

# Nadpisz kolumnę 'full' w df2 wartościami 'full_z_pierwszego' tam,
# gdzie 'full_z_pierwszego' nie jest brakujące (czyli gdzie było dopasowanie tagów).
# Używamy .fillna() na kopii, aby uniknąć SettingWithCopyWarning, choć w tym przypadku nie jest to krytyczne.
df_merged['full'] = df_merged['full_z_pierwszego'].fillna(df_merged['full'])

# Usuń tymczasową kolumnę 'full_z_pierwszego'
df_wynikowy = df_merged.drop(columns=['full_z_pierwszego'])

# Zapisz zmieniony DataFrame z powrotem do drugiego pliku CSV
# index=False zapobiega zapisaniu indeksu wierszy jako dodatkowej kolumny
df_wynikowy.to_csv('tag_full_new', index=False)