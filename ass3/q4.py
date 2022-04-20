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

cur.execute('SELECT * FROM Q4d(\'{}\')'.format(arg))
prev = ''
for t in cur.fetchall():
    x,y,z = t
    if x != prev :
        print(x)
    print(' ' + y + '({})'.format(z))
    prev = x


cur.close()
conn.close()
