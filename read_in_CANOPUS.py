# -*- coding: utf-8 -*-
"""
Created on Mon Sep  7 14:00:15 2015

Read in the CANOPUS data for the GILL station (I need to expand to other stations) and save the good data in MATLAB format by month.
I think py3???

Run in Python3

@author: Sarah

History:
16-02-03 Save data in slightly different folder
16-02-03 Fiddle with reading in stuff - why not working?
"""


import os
import numpy as np
import datetime,time
import scipy, scipy.io
import gc
#os.chdir('C:\\Users\\Sarah\\Documents\\PhD\\Data_tester')

import os.path
start_time = time.time()



# Get all files from GILL station
all_GILL_files = []
station = 'GILL'

print('Reading in files from '+station)

for dirpath, dirnames, filenames in os.walk("Bentley"): #is there something quicker than os.walk?
    for filename in [f for f in filenames if f.endswith(station+".MAG")]:
        all_GILL_files.append(os.path.join(dirpath,filename))
        
print(all_GILL_files)
findfile_time = time.time()
print('Time to find files '+str(findfile_time - start_time)+'s')
        
        
# Now read in good data from all these files, add to file
years = np.arange(1990,2006) #np.arange( 1990, 2006 )
months = np.arange(1,13)
print(years)


max_yr_entries = 365*24*60*60/5
max_mth_entries = (31+4)*24*60*60/5
for year in years:
    print('Doing files for year ',year)
    
    for month in months:
        month_data = np.zeros((max_mth_entries,9))
        month_data_entry = 0
        
        #delete and overwrite file if it already exists
        fname_out = os.path.join(os.getcwd(),"data/raw/"+str(station)+'_'+str(year)+'_'+str(month)+'.mat')
        if os.path.isfile( fname_out ):
            os.remove(fname_out)
        
        for GILL_data in all_GILL_files:
            end = len(GILL_data)
  
            #print(GILL_data[end-16:end-12],GILL_data[end-12:end-10])
            if GILL_data[end-16:end-12] == str(year) and int( GILL_data[end-12:end-10] ) == month:
                with open(GILL_data) as this_file:
                
                    if month_data_entry > 31*24*60*60/5:
                        print('Warning: seems to be too much data in month ',month)
                    for line in this_file:
                        if len(line) > 44:
                            if line[0] != '#' and line[45] == '.':
                                
                                #fopen.write(line[0:4] + ' ' + line[4:6] + ' ' + line[6:8] + ' ' +line[8:10] + ' ' + line[10:12] +' ' + line[12:44] + '\n')
                                line_data = [int(line[0:4]), int(line[4:6]), int(line[6:8]), float(line[8:10]), int(line[10:12]), int(line[12:14]), float(line[14:24]), float(line[24:34]),float(line[34:44])]
                                month_data[month_data_entry,:] = line_data
                                month_data_entry += 1
                              
             
        #print('Saved file ',fname_out)
        scipy.io.savemat(fname_out,mdict={'data':month_data})
        gc.collect()
    
    
end_time = time.time()
print('Time for whole function '+str(end_time - start_time)+'s')


    