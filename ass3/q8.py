# COMP3311 19T3 Assignment 3

import sys
import cs3311
conn = cs3311.connect()

cur = conn.cursor()

# class to record individual meeting
class Meeting(object):
    def __init__(self, code, type_name, id1):
        self.code = code
        self.type_name = type_name
        self.id1 = id1
        self.start = 2400
        self.end = -1
        self.time = []

    def add_time(self,s,e, day):
        r = s,e ,day
        self.time.append(r)
        if s < self.start :
            self.start = s
        if e > self.end :
            self.end = e

    def is_conflict(self, meeting):
        for time in meeting.time :
            s = time[0]
            e = time[1]
            day = time[2]
            for ele in self.time :
                if day == ele[2] :
                    if (s < ele[1] and s >= ele[0]) or (e <= ele[1] and e > ele[0]) or (s <= ele[0] and e >= ele[1]) :
                        return True
        return False

    def __str__(self):
        return "{} {} {} {}".format(self.code, self.type_name, self.id1, self.time)

# class that hold meetings on a day of week
class DayMeetingList(object):
    def __init__(self):
        self.start = 2400
        self.end = -1
        self.meetings = []

    def add_meeting(self,meeting):
        self.meetings.append(meeting)
        if meeting.start < self.start : 
            self.start = meeting.start
        if meeting.end > self.end :
            self.end = meeting.end
    
    def get_len(self):
        return len(self.meetings)

# structure to record final result and all candidate results
class Result(object):

    def __init__(self):
        self.results = []
        i = 0
        while i < 7 :
            self.results.append(DayMeetingList())
            i+=1
    
    def last_day(self):
        i = 6
        while i > -1 :
            if self.results[i].get_len != 0 :
                return i
            i-=1
        return -1
    
    def total_days(self):
        i = 0
        for ele in self.results :
            if ele.get_len() != 0 :
                i+=1
        return i
    
    def total_hours(self):
        i = 2*self.total_days()
        for ele in self.results :
            if ele.get_len() != 0 :
                s = int(ele.start/100)
                e = int(ele.end/100)
                if ele.start%100 == 30 :
                    s = float(s + 0.5)
                if ele.end%100 == 30 :
                    e = float(e + 0.5)   
                i = i + e - s
        return i            

# all the course information goes here
all_course = []

arg = ''
if len(sys.argv) == 1:
    arg = []
    arg.append('COMP1511')
    arg.append('MATH1131')
else :
    arg = sys.argv[1:]

for code in arg :
    cur.execute('SELECT * FROM Q8b(\'{}\')'.format(code))
    course = []
    same_type = []
    pre_type = ''
    pre_id = ''
    pre_meeting = None
    for t in cur.fetchall():
        code , id1, type_name, day, starting, ending = t

        if type_name != pre_type and pre_type != '':
            course.append(same_type)
            same_type = []


        if pre_id != '' and pre_id == id1 :
            pre_meeting.add_time(starting, ending, day)
        else :
            meeting = Meeting(code, type_name, id1)
            meeting.add_time(starting, ending, day)
            same_type.append(meeting)
            pre_meeting = meeting

        pre_type = type_name
        pre_id = id1

    if pre_type != '':
        course.append(same_type)
        same_type = []

    all_course.append(course)

# all solution goes here
all_solution = []

#generate all possible combinatoins
for course in all_course :
    for type_name in course :
        if all_solution == [] :
            for meeting in type_name :
                solution = []
                solution.append(meeting)
                all_solution.append(solution)
        else :
            new_all_solution = []
            for solution in all_solution :
                for meeting in type_name :
                    state = True
                    for ele in solution :
                        if ele.is_conflict(meeting) :
                            state = False
                            break
                    if state :
                        new_solution = []
                        for me in solution :
                            new_solution.append(me)
                        new_solution.append(meeting)
                        new_all_solution.append(new_solution)
            all_solution = new_all_solution

candidate = []
least_time = 99999

#chose the one(s) that have least time overall
for solution in all_solution :
    result = Result()
    for meeting in solution :
        code = meeting.code
        type_name = meeting.type_name
        id1 = meeting.id1
        for time in meeting.time :
            new_meeting = Meeting(code,type_name,id1)
            new_meeting.add_time(time[0],time[1],time[2])
            if time[2] == 'Mon' :
                result.results[0].add_meeting(new_meeting)
            elif time[2] == 'Tue' :
                result.results[1].add_meeting(new_meeting)
            elif time[2] == 'Wed' :
                result.results[2].add_meeting(new_meeting)
            elif time[2] == 'Thu' :
                result.results[3].add_meeting(new_meeting)
            elif time[2] == 'Fri' :
                result.results[4].add_meeting(new_meeting)
            elif time[2] == 'Sat' :
                result.results[5].add_meeting(new_meeting)
            elif time[2] == 'Sun' :
                result.results[6].add_meeting(new_meeting)
    total_hours = result.total_hours()
    if total_hours == least_time :
        candidate.append(result)
    elif total_hours < least_time :
        candidate = []
        candidate.append(result)
        least_time = total_hours

candidate_day = []
least_day = 7

#then choose from the least day
for solution in candidate :
    total_days = solution.total_days()
    if total_days == least_day :
        candidate_day.append(solution)
    elif total_days < least_day :
        candidate_day = []
        candidate_day.append(solution)
        least_day = total_days

candidate_early = []
least_day = 7
least_mom = 2500

#then choose from the earlist
for solution in candidate_day :
    last_day = solution.last_day()
    if last_day == least_day :
        if solution.results[last_day].end == least_mom :
            candidate_early.append(solution)
        elif solution.results[last_day].end < least_mom :
            candidate_early = []
            candidate_early.append(solution)
            least_mom = solution.results[last_day].end
    elif last_day < least_day :
        candidate_early = []
        candidate_early.append(solution)
        least_day = last_day
        least_mom = solution.results[last_day].end


print('Total hours: {:.1f}'.format(least_time))
i = 0

# print out the first of many best solution
for ele in candidate_early[0].results :
    if ele.get_len() != 0 :
        if i == 0 :
            print('  Mon')
        elif i == 1:
            print('  Tue')
        elif i == 2:
            print('  Wed')
        elif i == 3:
            print('  Thu')
        elif i == 4:
            print('  Fri')
        elif i == 5:
            print('  Sat')
        elif i == 6:
            print('  Sun')
        ele.meetings = sorted(ele.meetings, key=lambda meeting: meeting.start)
        for meeting in ele.meetings :
            print('    {} {}: {}-{}'.format(meeting.code, meeting.type_name,meeting.start, meeting.end))
    i+=1

cur.close()
conn.close()

