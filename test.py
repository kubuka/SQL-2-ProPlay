column_clauses = []
for i in range(1, 37): # Od 1 do 40
    column_clauses.append(f"round(avg(min_{i}:: INT),0) as avg_min_{i}_diff")

values_clause = ",\n".join(column_clauses)

sql_query = f"""
SELECT
    address,
   {values_clause}
FROM
    gold
    
"""
# Tutaj wykonujesz sql_query w bazie danych
print(sql_query)