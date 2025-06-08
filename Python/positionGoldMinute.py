import pandas as pd

df = pd.read_csv('/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/position_gold_minute.csv')
print(df.columns)
df_index = df.set_index('type')
diff_cols = df_index.columns
diff = pd.DataFrame(columns=diff_cols)

diff.loc['adcDiff'] = df_index.loc['goldblueADC', diff_cols] - df_index.loc['goldredADC', diff_cols]
diff.loc['supDiff'] = df_index.loc['goldblueSupport', diff_cols] - df_index.loc['goldredSupport', diff_cols]
diff.loc['jngDiff'] = df_index.loc['goldblueJungle', diff_cols] - df_index.loc['goldredJungle', diff_cols]
diff.loc['midDiff'] = df_index.loc['goldblueMiddle', diff_cols] - df_index.loc['goldredMiddle', diff_cols]
diff.loc['topDiff'] = df_index.loc['goldblueTop', diff_cols] - df_index.loc['goldredTop', diff_cols]

print(diff)
diff.to_csv('/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/position_gold_minute_diff.csv', index=True)