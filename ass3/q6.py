# COMP3311 19T3 Assignment 3

import cs3311
conn = cs3311.connect()

cur = conn.cursor()

cur.execute('UPDATE meetings set weeks_binary = Q6a(weeks);')
conn.commit()

cur.close()
conn.close()
