from __future__ import division
from collections import defaultdict
import os,sys

#Change to your PSS/e Location
sys.path.append(r"C:\Program Files (x86)\PTI\PSSEXplore34\PSSPY27") #Give the path to PSSBIN to imoport psspy
sys.path.append(r"C:\Program Files (x86)\PTI\PSSEXplore34\PSSBIN")
sys.path.append(r"C:\Program Files (x86)\PTI\PSSEXplore34\EXAMPLE")
os.environ['PATH'] = (r"C:\Program Files (x86)\PTI\PSSEXplore34\PSSPY27;" + r"C:\Program Files (x86)\PTI\PSSEXplore34\PSSBIN;" + r"C:\Program Files (x86)\PTI\PSSEXplore34\EXAMPLE;" + os.environ['PATH'])
#import pssarrays
import psspy
import pssarrays
import redirect
import dyntools
import pssplot
import random
import copy
import math
import multiprocessing
import time
import sys
import csv
#import matplotlib
_i=psspy.getdefaultint()
_f=psspy.getdefaultreal()
_s=psspy.getdefaultchar()
redirect.psse2py()

def Initialize_Case(in_file):
	psspy.psseinit(50)
	psspy.case(in_file) #Load example case savnw.sav


		
def Solve_Steady():
	Ok_Solution = 1
	psspy.fnsl([0,0,0,1,1,0,99,0]) #Full newton solution 
	ierr, rarray = psspy.abusreal(-1, 2, 'PU') #Get all bus voltages
	#Check if voltage is above/below a threshold
	if min(rarray[0]) < 0.95 or max(rarray[0]) > 1.05:
		Ok_Solution = 0
	
	return rarray, Ok_Solution
	
def Convert_Dynamic():
	psspy.fdns([0,0,0,1,1,0,99,0]) #Solve fixed slope decoupled newton raphson	
	psspy.cong(0) #Convert our generators using Zsource (Norton Equiv)
	psspy.conl(0,1,1,[0,0],[ 100.0,00.0,00.0, 100.0]) #Convert our loads (represent active power as 100% constant current type, reactive power as 100% constant impedance type.)
	psspy.conl(0,1,2,[0,0],[ 100.0,00.0,00.0, 100.0]) #Convert our loads
	psspy.conl(0,1,3,[0,0],[ 100.0,00.0,00.0, 100.0]) #Convert our loads
	psspy.ordr(0) #Order network for matrix operations
	psspy.fact() #Factorize admittance matrix
	psspy.tysl(0) #Solution for Switching Studies
def Out_Put_Channels():
	psspy.dyre_new([1,1,1,1],Dynamic_File,"","","") #Open our .dyr file that gives the information for dynamic responses of the machines
	psspy.chsb(0,1,[-1,-1,-1,1,4,0]) #Setup Dynamic Simulation channels, Machine voltages in this case
	#psspy.chsb(0,1,[-1,-1,-1,1,14,0]) #Bus voltage and angle
	psspy.chsb(0,1,[-1,-1,-1,1,12,0]) #Frequency
	psspy.chsb(0,1,[-1,-1,-1,1,2,0]) #Machine Real power
	psspy.chsb(0,1,[-1,-1,-1,1,3,0]) #Machine Reactive Power
	#psspy.chsb(0,1,[-1,-1,-1,1,1,0]) #Machine Angle
	psspy.chsb(0,1,[-1,-1,-1,1,7,0]) #Machine Speed
	psspy.chsb(0,1,[-1,-1,-1,1,14,0])
def Islanding(Time_Trip, Time_Reconnect, End_Time, Out_File):
	psspy.strt(0,Out_File) #Start our case and specify our output file
	psspy.run(0,0.0,1,1,0) #Run until 0 seconds 
	psspy.run(0, 10,1,1,0) #Run until 50 seconds
	psspy.dist_branch_trip(323,325,r"""1""") #Open branch between main grid and microgrid
	psspy.change_channel_out_file(Out_File) #Resume our output file
	psspy.run(0, 10,1,1,0) #Run until 100 seconds
	psspy.dist_branch_trip(223,318,r"""1""") #Open branch between main grid and microgrid
	psspy.change_channel_out_file(Out_File) #Resume our output file	
	psspy.run(0, 10,1,1,0) #Run until 100 seconds	
	psspy.dist_branch_trip(121,325,r"""1""") #Open branch between main grid and microgrid
	psspy.change_channel_out_file(Out_File) #Resume our output file
	psspy.run(0, 10,1,1,0) #Run until 100 seconds
	#psspy.run(0, 50,1,1,0) #Run until 200 seconds
	#psspy.dist_branch_trip(16,24,r"""1""") #Open branch between main grid and microgrid
	#psspy.change_channel_out_file(Out_File) #Resume our output file	
	#psspy.run(0, 50,1,1,0) #Run until 5 seconds
	#psspy.dist_branch_trip(16,21,r"""1""") #Open branch between main grid and microgrid
	#psspy.change_channel_out_file(Out_File) #Resume our output file	
	
def Return_Load_Info():	
	ierr, Complex_Power = psspy.aloadcplx(-1, 4, 'MVANOM') #Obtain Complex Power of Loads
	ierr, Complex_Current = psspy.aloadcplx(-1, 4, 'ILNOM') #Obtain Complex Currents of Loads
	ierr, Complex_Impedance = psspy.aloadcplx(-1, 4, 'YLNOM') #Obtain Complex Impedances of Loads
	ierr, Load_Numbers = psspy.aloadint(-1, 4, 'NUMBER') #Obtain Load Numbers
	ierr, Load_Count = psspy.aloadcount(-1, 4) #Obtain Count of Loads

	return Load_Count, Load_Numbers, Complex_Power, Complex_Current, Complex_Impedance


#def main():
	


#if __name__ == "__main__": 
#	main()	



