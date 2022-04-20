import cs3311
conn = cs3311.connect()

cur = conn.cursor()

cur.execute('SELECT id, weeks_binary FROM Meetings ORDER BY id')

for t in cur.fetchall():
    x,y = t
    print('UPDATE meetings SET weeks_binary = \'{}\' WHERE id = {};'.format(y,x))

cur.close()
conn.close()