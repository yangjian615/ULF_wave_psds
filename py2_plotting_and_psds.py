# -*- coding: utf-8 -*-
"""
Created on Fri Jan 15 15:28:09 2016
@author: Sarah

Performs the same function as the MATLAB code.
Begin by reading in some data, find the PSD and plot median. Later you can expand into sorting by MLT and solar wind speed.

"""

import numpy as np
import os
import scipy.io
import matplotlib.pyplot as plt
import datetime
import pandas as pd
from numpy import fft

# Set up variables etc
station = 'GILL'
years = np.arange(1990,2005)
months = np.array([2,3,4])#np.array([2,3,4,8,9,10]) #np.arange(1,13)#13
dirpath = os.getcwd()
day_ranges = np.array([[3,9],[9,15],[15,21],[21,3]])

W = 1
N = 720
Fs = 1/(5.0)

n = np.arange(0,N) #or should this start from 1?
w = 0.5*(1 - np.cos(2*np.pi*n/float(N-1)))

W = sum(w*w);
#w = np.sqrt((N-1)/W)*w; #WHAT IS THIS? GOT IT FROM DSP 

calculate_psds = False# True
get_psd_medians = True
plot_medians = True

freqs = (Fs/N)*1e3*(n)
freqs = freqs[:360]
#dataset = np.empty(shape = [720,4,24*31*np.size(months)*np.size(years)])



def get_psds( col ):
    out_col = col - np.mean(col)    
    out_col = out_col*w

    #REALLY NOT SURE ABOUT CONSTANTS
    
    fted = abs(fft.fft(out_col))#[:361])
    hr_psds = (Fs/(N*W))*2*(fted**2) 
    
    return hr_psds
    
def bin_SW_speeds( col ):
    out_col = np.empty(shape=np.shape(col))
    
    out_col[ col < 300 ] = 1
    out_col[ (col>=300) & (col<400)  ] =2
    out_col[ (col>=400) & (col<500)  ] =3
    out_col[ (col>=500) & (col<600)  ] =4
    out_col[ (col>=600) & (col<700)  ] =5
    out_col[ col>=700 ] =6
    
    return out_col
    
if calculate_psds:
    for year in years:
        for month in months:
            outwords = 'Loading in data from year '+str(year)+', month '+str(month)
            print(outwords)
            fname = 'data'+'/'+str(station)+'_'+str(year)+'_'+str(month)+'.mat'
            matfile = scipy.io.loadmat(os.path.join(dirpath,fname)) #load the data in as dictionary format
    #matfile.keys()
    
            # read in data as numpy arrays
            py2_mini_omni = matfile['mini_omni']
            py2_data = matfile['data']
            datasize = np.shape( py2_data )
            
            #xs = py2_data[:,7,0]
         
            for i in np.arange(0,datasize[2]):
                py2_data[:,7,i] = get_psds(py2_data[:,7,i])
                py2_data[:,8,i] = get_psds(py2_data[:,8,i])
                py2_data[:,9,i] = get_psds(py2_data[:,9,i]) #NEED TO CUT OFF SECOND HALF
        
            py2_data = py2_data[:360,:,:]

        
            fname = os.getcwd() + '/data/_py2_' + str(station) + "_hr_psds_"+str(year) + "_"+str(month)
            #print(fname)
            np.savez(fname, py2_data = py2_data, py2_mini_omni = py2_mini_omni )
            

if get_psd_medians:
    speeds = np.arange(1,7)
    day_sectors = np.arange(1,5)
    
    
    unsorted_data = np.zeros(shape=(360,10,np.size(years)*np.size(months)*31*24))
    unsorted_omni = np.zeros(shape=(np.size(years)*np.size(months)*31*24,4))
    index_count = 0
    for year in years:
        for month in months:
            outwords = 'Loading in data from year '+str(year)+', month '+str(month)+' to find medians'
            print(outwords)
            fname = 'data'+'/_py2_'+str(station)+'_hr_psds_'+str(year)+'_'+str(month)+'.npz'
            loading = np.load(os.path.join(dirpath,fname))
            
            #loading.files
            data = loading['py2_data']
            omni = loading['py2_mini_omni']      
            
            datasize = np.shape(data)
            omnisize = np.shape(omni)
            
            if datasize[2] != omnisize[0]:
                raise ValueError('Size of OMNI data did not match magnetometer data')
            
            unsorted_data[:,:,index_count:index_count+datasize[2]] = data
            unsorted_omni[index_count:index_count+datasize[2]] = omni

            index_count += datasize[2]          
         
    unsorted_data = unsorted_data[:,:,:index_count]
    unsorted_omni = unsorted_omni[:index_count,:]
    
    datasize = np.shape(unsorted_data)
    omnisize= np.shape(unsorted_omni)
    
    if datasize[2] != omnisize[0]:
        raise ValueError('Size of OMNI data did not match magnetometer data after finding medians')
    
#    temp_medians = np.zeros(shape=(360,3))
#    
#    for i in np.arange(0,360):
#        for coord in np.arange(0,3):
#            temp_medians[i,coord] = np.median( unsorted_data[i,coord+7,:] )
    
    #now sort the medians
    unsorted_omni[:,1] = bin_SW_speeds( unsorted_omni[:,1] )
    sorted_meds = np.zeros(shape=(360,3,4,6)) #freq,coord,day sector, SW speed
    
    for speed in speeds:
        index_speed = 0
        
        for sector in day_sectors:
            index_sector = 0
            hr_range = day_ranges[sector-1,:]
            
            if hr_range[1] > hr_range[0]:
                data_this_sector_speed = unsorted_data[:,7:,(unsorted_data[0,4,:]>= hr_range[0])&(unsorted_data[0,4,:]<hr_range[1])&(unsorted_omni[:,1]==speed)   ]
            else: 
                data_this_sector_speed = unsorted_data[:,7:,(unsorted_data[0,4,:]>= hr_range[1])&(unsorted_data[0,4,:]<hr_range[0])&(unsorted_omni[:,1]==speed)   ]
                
            if np.size(data_this_sector_speed) > 0:
                for coord in np.arange(0,3):
                    for i in np.arange(0,360):
                        sorted_meds[i,coord,sector-1,speed-1] = np.median( data_this_sector_speed[i,coord,:] )  
            
            
    
if plot_medians:
    coord = 0    
    fig = plt.figure()
    
    for sector in day_sectors:
        hr_range = day_ranges[sector-1,:]
        ax = fig.add_subplot(2,2,sector)
        
        for speed in speeds:
            ax.plot(freqs[1:],sorted_meds[1:,coord,sector-1,speed-1])
  
        titletext = 'x for MLT between '+str(hr_range[0])+' and '+str(hr_range[1])
        plt.title( titletext )
        plt.yscale('log')
        plt.xlabel('Freqs, mHz')
        plt.ylabel('PSD Amplitude')
        plt.xscale('log')
        plt.axis([0.9,10.1,0.9e-4,1.1e4])
    plt.show()





#datasize = np.shape(py2_data) #a tuple
#dates = np.empty(shape=[datasize[0]*datasize[2],6])
#dim1 = datasize[0]
#
## trying to tsort out dates
#for slice in np.arange(0,datasize[2]):
#    print slice
#    dates[slice*dim1:(slice+1)*dim1,0] = py2_data[:,1,slice]
#    dates[slice*dim1:(slice+1)*dim1,1] = py2_data[:,2,slice]
#    dates[slice*dim1:(slice+1)*dim1,2] = py2_data[:,3,slice]
#    dates[slice*dim1:(slice+1)*dim1,3] = py2_data[:,4,slice]
#    dates[slice*dim1:(slice+1)*dim1,4] = py2_data[:,5,slice]
#    dates[slice*dim1:(slice+1)*dim1,5] = py2_data[:,6,slice]

#x_vals_first_hour = py2_data[:,7,0]

#plt.plot(x_vals_first_hour)
#plt.ylabel('Amplitude nT')
#plt.xlabel('Time s')
#plt.show()