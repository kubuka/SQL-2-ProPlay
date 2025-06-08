from PIL import Image, ImageDraw, ImageFilter
import pandas as pd
import math

def zaznacz_punkt_na_mapie(csv_file, map_width, map_height, file_name = "mapa_z_punktem.png", dots=10):  
    

    df = pd.read_csv(csv_file)
    if len(df) < dots:
        to_draw = len(df)
    else: to_draw = df.head(dots)

    obraz = Image.open('/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/lol_map.jpg')
    
    rysuj = ImageDraw.Draw(obraz)
    for i, row in enumerate(to_draw.itertuples()):
            x_pos = int(row.x_pos*10)
            y_pos = int(row.y_pos*10)
            y_pillow = map_height  - y_pos/2 
            r = 255
            g = int(255 * (i / dots))
            b = int(255 * (i / dots))
            
            
            dot_size = 50-i*2
            print(f"dot_size: {dot_size}")
            color = (r, g, b)
            rysuj.ellipse([x_pos/2 - dot_size // 2, y_pillow - dot_size // 2,
                x_pos/2 + dot_size // 2, y_pillow + dot_size // 2],
                fill=color, outline='white', width=1)
    
    
    obraz.save(file_name)
    print(f"saved'{file_name}'")

szerokosc = 800
wysokosc = 800
csv_file = '/Users/kuba/Desktop/Portfolio/SQL-2-ProPlay/deathPositions.csv'

zaznacz_punkt_na_mapie(csv_file,szerokosc, wysokosc)