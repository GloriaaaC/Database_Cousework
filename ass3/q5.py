# COMP3311 19T3 Assignment 3

import sys
import cs3311
conn = cs3311.connect()

cur = conn.cursor()

arg = ''

if len(sys.argv) == 1:
    arg = 'COMP1521'
else :
    arg = sys.argv[1]

cur.execute('SELECT * FROM Q5d(\'{}\')'.format(arg))
for t in cur.fetchall():
    x,y,z = t
    print('{} {} is {}% full'.format(x,y,z))

cur.close()
conn.close()
