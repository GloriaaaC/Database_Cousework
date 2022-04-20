# COMP3311 19T3 Assignment 3
import sys
import cs3311

conn = cs3311.connect()

cur = conn.cursor()

cur.execute('SELECT * FROM Q2b({})'.format(sys.argv[1]))
for tup in cur.fetchall():
    x,y = tup
    print(x + ':' + y)

cur.close()
conn.close()
