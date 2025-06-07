import pandas as pd

df = pd.read_csv('/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/ban_order.csv')

unique_bans_per_team = df.groupby(['year', 'season','team','bans'])['ban_percentage'].max().reset_index()
top_5_unique_bans_per_team = unique_bans_per_team.groupby(['year', 'season', 'team']).apply(
    lambda x: x.sort_values(by='ban_percentage', ascending=False).head(5)
).reset_index(drop=True)
i = 1
for (year, season,team), group in top_5_unique_bans_per_team.groupby(['year', 'season','team']):
    i+=1
    if i%2 == 0:
        print("*" * 40)
        print("\n")
    print(f"Top probable bans: {year}, season: {season}, team: {team[:-4]}")
    if year < 2017:
        for index, row in group.head(3).iterrows():
            print(f"  - {row['bans']}: {row['ban_percentage']:.2f}%")
        print("\n")
    else:
        for index, row in group.head(5).iterrows():
            print(f"  - {row['bans']}: {row['ban_percentage']:.2f}%")
        print("\n")