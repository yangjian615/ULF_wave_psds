# -*- coding: utf-8 -*-
"""
Making simple types of dummy data. The station will be 'TEST'

Output needs to be
'TEST_mlt_midnights.txt', format YEAR  MIDNIGHT (UT) / 
'TEST_omni_all.dat', format same as OMNI, 55 word rows, 
        (1)YEAR (2)DAY (3)HOUR... (25)SW SPEED ... (39)Kp ... (36)electric field
        (column numbers here beginning from 1 not 0)
'TEST_raw_YEAR_MONTH.mat'
    matlab file scipy.io.savemat(fname_out,mdict={'data':month_data})
    9 cols, format YEAR MONTH DAY HOUR MIN SECOND X Y Z
    Recall data every 5s
'TEST_decs.txt', format YEAR DEC/   


Created on Tue Jan 26 10:55:00 2016

@author: Sarah
"""

