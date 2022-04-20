# COMP3311 19T3 Assignment 3

import sys
import cs3311


class Interval(object):
  def __init__(self, s, e):
    self.s = s
    self.e = e

conn = cs3311.connect()

cur = conn.cursor()

arg = ''

if len(sys.argv) == 1:
    arg = '19T1'
else :
    arg = sys.argv[1]

pre_hour = 0
pre = -1
underused = 0

cur.execute('SELECT * FROM Q7sub1(\'{}\')'.format(arg))
for t in cur.fetchall():
    underused = int(t[0])

total = 0

cur.execute('SELECT num FROM Q7d')
for t in cur.fetchall():
    total = int(t[0])

tuples = []

cur.execute('SELECT * FROM Q7e(\'{}\')'.format(arg))
for t in cur.fetchall():

    id, day, start, end, week = t

    if pre != id :
        tuples = []
        ind = 0
        while ind < 10 :
            a = []
            tuples.append(a)
            ind+=1

    ind = 0
    temp = []
    while ind < 10 :
        a = []
        temp.append(a)
        ind+=1
    hour = 0
    weekc = 0
    for cha in week :
        if cha == '1' :
            interval = []
            interval.append(Interval(start, end))
            for record in tuples[weekc] :
                if day == record[1]:
                    for ele in interval :
                        if ele.s >= record[2] and ele.e <= record[3] :
                            ele.s = 0
                            ele.e = 0
                        elif ele.s < record[2] and ele.e <= record[3] and ele.e >= record[2]:
                            ele.e = record[2]
                        elif ele.s >= record[2] and ele.s <= record[3] and ele.e > record[3]:
                            ele.s = record[3]
                        elif ele.s < record[2] and ele.e > record[3] :
                            interval.append(Interval(ele.s, record[2]))
                            interval.append(Interval(record[3], ele.e))
                            interval.remove(ele)

            for ele in interval :
                hour = hour + ele.e - ele.s
                res = id, day, ele.s, ele.e
                temp[weekc].append(res)
        weekc += 1

    if pre != id and pre != -1:
        if pre_hour < 400:
            underused+=1
        pre_hour = 0
        tuples = []
        ind = 0
        while ind < 10 :
            a = []
            tuples.append(a)
            ind+=1

    pre = id
    pre_hour = pre_hour + hour
    ind = 0
    while ind < 10 :
        tuples[ind] = tuples[ind] + temp[ind]
        ind+=1

if pre_hour < 400 and id != -1:
    underused+=1

print("{:.1f}%".format(underused*100/total))


cur.close()
conn.close()
