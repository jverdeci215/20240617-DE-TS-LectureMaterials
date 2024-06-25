import pymssql

conn = pymssql.connect(server='JV-PC')

# Create a cursor to run queries
cursor = conn.cursor()
cursor.execute('SELECT * FROM INFORMATION_SCHEMA.TABLES')
rows = cursor.fetchall()
[print(row) for row in rows]

# If we are updating/making any changes
# conn.commit()