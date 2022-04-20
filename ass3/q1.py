# COMP3311 19T3 Assignment 3

import cs3311
conn = cs3311.connect()

cur = conn.cursor()

cur.execute('SELECT * FROM Q1b')
for tup in cur.fetchall():
    x,y,z = tup
    print(x + ' ' + str(round(z/y*100)) + '%')


cur.close()
conn.close()
