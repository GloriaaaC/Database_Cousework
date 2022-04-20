# COMP3311 19T3 Assignment 3

import sys
import cs3311
conn = cs3311.connect()

cur = conn.cursor()

arg = ''

if len(sys.argv) == 1:
    arg = 'ENGG'
else :
    arg = sys.argv[1]

cur.execute('SELECT * FROM Q3c(\'{}\')'.format(arg))
prev = ''
for t in cur.fetchall():
    x,y = t
    if x != prev :
        print(x)
    print(' ' + y)
    prev = x

cur.close()
conn.close()
