#!/usr/bin/env python


import os, sys, inspect
from datetime import (
datetime,
timedelta,
time,
date,
tzinfo,
)

## realpath() with make your script run, even if you symlink it :)
cmd_folder = os.path.realpath(os.path.abspath(os.path.split(inspect.getfile( inspect.currentframe() ))[0]))
#if cmd_folder not in sys.path:
    #sys.path.insert(0, cmd_folder)
    
# use this if you want to include modules from a subforder
cmd_subfolder = os.path.realpath(cmd_folder + '/icalendar/src')
if cmd_subfolder not in sys.path:
    sys.path.insert(0, cmd_subfolder)


icstoread = 'FeG-Jahresplanung.ics'
print 'Einlesen von', icstoread, '...'

# when pytz (Python Timezone) is missing, either execute in icalender: sudo python setup.py install or install pytz manually
from icalendar import Calendar, Event
import pytz

GermanWeekDays = [ 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So' ]
berlin = pytz.timezone('Europe/Berlin')

cal = Calendar.from_ical(open(icstoread,'rb').read())
values = dict()
for component in cal.walk():
    if component.name == "VEVENT":
        cmsDayOfWeek = ''
        cmsStartTime = ''
        startdate = component.get('DTSTART').dt;
        cmsSortKey  = "%04d-%02d-%02d" % (startdate.year, startdate.month, startdate.day)
        if isinstance(startdate, datetime):
            #startdate = startdate.astimezone(berlin)
            if 20 != startdate.hour or 0 != startdate.minute:
                if 0 == startdate.minute:
                    cmsStartTime = "%02d Uhr, " % (startdate.hour)
                else:
                    cmsStartTime = "%02d:%02d Uhr, " % (startdate.hour, startdate.minute)
                    
        enddate = component.get('DTEND').dt
        cmsEndDate = ''
        delta = enddate - startdate
        if 1 < delta.days:
            if startdate.month == enddate.month:
                cmsStartDate = "%02d." % (startdate.day)
            else:
                cmsStartDate = "%02d.%02d." % (startdate.day, startdate.month)
            cmsEndDate = "--%02d.%02d." % (enddate.day-1, enddate.month)
        else:
            cmsStartDate = "%02d.%02d." % (startdate.day, startdate.month)
            pos = startdate.weekday()
            cmsDayOfWeek = "%s, " % GermanWeekDays[pos]
        cmsLocation = ''
        if component.get('LOCATION') is not None and component.get('LOCATION') != 'FeG':
            cmsLocation = ', ' + component.get('LOCATION')
            
        summary = component.get('SUMMARY')
        if 'MAL' == summary:
            cmsSummary = 'Mitarbeiterleitung'
        elif 'LK' == summary:
            cmsSummary = 'Leitungskreis'
        else:
            cmsSummary = summary.replace('GV', 'Gemeindeversammlung')
            
        print 'SUMMARY:', summary, ' -> ', cmsSummary
        print 'DTSTART:', startdate, ' -> ', cmsDayOfWeek, cmsStartDate, cmsStartTime, ' - ', cmsSortKey
        print 'DTEND:', enddate, ' -> ', cmsEndDate
        print 'LOCATION:', component.get('LOCATION'), ' -> ', cmsLocation
        
        # Do, 10.01. #Leitungskreis
        #11.--13.01.#Jugend-Mitarbeiter-Wochenende in der Eifel        
        cmsValue = '%s%s%s # %s%s%s' % ( cmsDayOfWeek, cmsStartDate, cmsEndDate, cmsStartTime, cmsSummary, cmsLocation)
        values[cmsSortKey] = cmsValue
    else:
        print '** Other component:', component.name
    print

#values.sort()
keys = values.keys()
keys.sort()

# Reihenfolge in der Zeile: Wochentag (mit zwei Buchstaben), Datum
#(mit Tag.Monat), Uhrzeit (mit hh:mm), Text, Ort
lastyear = ''
lastmonth = ''
for k in keys:
    year = k[:4]
    month = k[:7]
    if year != lastyear:
        print
        print '***  ', year, '  ***'
        lastyear = year
    if month != lastmonth:
        print
        lastmonth = month
    print values[k]
    