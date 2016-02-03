# -*- coding: utf-8 -*-
"""
Making simple types of dummy data. The station will be 'TEST'

Output needs to be
'TEST_mlt_midnights.txt', format YEAR  MIDNIGHT (UT) / 
'TEST_omni_all.dat', format same as OMNI, 55 word rows, 
        (1)YEAR (2)DAY (3)HOUR... (25)SW SPEED ... (39)Kp ... (36)electric field
        (column numbers here beginning from 1 not 0)
        (dates don't have to be in exactly this format, hand in year and hours for read_in_omni to deal with)
'TEST_raw_YEAR_MONTH.mat'
    matlab file scipy.io.savemat(fname_out,mdict={'data':month_data})
    9 cols, format YEAR MONTH DAY HOUR MIN SECOND X Y Z
    Recall data every 5s
    Again, can just fill in year and hour or second of dates, as data_prep deals with it.
'TEST_decs.txt', format YEAR DEC/   


Created on Tue Jan 26 10:55:00 2016

@author: Sarah


HISTORY
16-02-01 OMNI data created is lots of ones rather than lots of zeros
16-02-03 Save data in slightly different folder

"""

import numpy as np
import os
import datetime
import scipy.io

#os.chdir('/glusterfs/scenario/users/mm840338/data_tester/data')
datafolder = os.getcwd()+'/data/'

make_midnights = False
make_omni = True
make_decs = False
make_data = False

station = 'TEST'
years = np.arange(1990,2005)
months = np.arange(1,13)
print(station,years,months)

# Make TEST_mlt_midnights.txt
if make_midnights:
    fname = datafolder+station+'_mlt_midnights.txt'
    f = open(fname,'w')
    for year in years:
        tempstr = str(year)+' 6.6\r\n'
        f.write(tempstr)
    f.close()
    print('Made a new TEST_mlt_midnights file')
    
    
if make_omni:
    fname = datafolder+str(station)+'_omni_all.txt'
    f = open(fname,'w')
    for hr in np.arange(0,(np.max(years)-years[0])*np.max(months)*31*24):
        tempstr = '1990 1 '+str(hr)+' 1'*21 + ' 444' + ' 1'*10 +' 12' + ' 1'*2 +' 30' + ' 1'*16+'\r\n'
        f.write(tempstr)
    f.close()
    print('Made a new TEST_omni_all file')
    
    
if make_decs:
    fname = datafolder+station+'_decs.txt'
    f = open(fname,'w')
    for year in years:
        tempstr = str(year)+' 1.0\r\n'
        f.write(tempstr)
    f.close()
    print('Made a new TEST_decs file')
    
time_s = 0 #time in seconds for xvalue   
if make_data:
    for year in years:
        for month in months:
            fname = datafolder+'/raw/'+str(station)+'_'+str(year)+'_'+str(month)+'.mat'
            start_day = datetime.datetime(year,month,1,0,0,0)
            end_month = month+1
            end_year = year
            if end_month == 13:
                end_month = 1
                end_year += 1
            end_day = datetime.datetime(end_year,end_month,1,0,0,0)
            count_time = start_day
            
            time_diff = datetime.timedelta(0,5) #5 seconds
            diffs_max = np.ceil(31*24*60*60/5.0) #max number of entries for a month
            temp_output = np.zeros(shape=(diffs_max,9))
            
            i = 0
            delta = end_day - count_time
            while delta.total_seconds() > 0 & i <= diffs_max:
                xval=np.sin(np.pi*time_s/10)
                yval=0
                zval=0
                temp_output[i,:] = np.array([count_time.year,count_time.month,count_time.day,count_time.hour,count_time.minute,count_time.second,xval,yval,zval])
                
                time_s += time_diff.seconds
                count_time = count_time+time_diff
                i+=1
                delta = end_day - count_time
                
            # now copy and paste records made to output
                
                
            # Have start and end day, how go through every seconds (or every 5 seconds) between them?
            # Can just try adding on a second; if teat doesn't work, add a mintue, etc, up until the datetime equals our end_day. But does the datetime module deal with leap yeas, daylight savings etc? Does MATLAB? Does the data?
            # How do you want to save this? Write lines to temporary file, then readit back in? Or use up LOTS of ememory and append to an array? Or start with an array, keep count of the non-zero lines and only save those? Up to you.
            month_data = temp_output[:i,:]
            scipy.io.savemat(fname,mdict={'data':month_data}) 
                    
    
            print('Dummy data created for '+str(fname))
    