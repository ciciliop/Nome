import os
import sys
import csv
sys_path_PSSE=r'C:\Program Files (x86)\PTI\PSSEXplore34\PSSPY27'
sys.path.append(sys_path_PSSE)
os_path_PSSE=r'C:\Program Files (x86)\PTI\PSSEXplore34\PSSBIN'
os.environ['PATH']+= ';'+ os_path_PSSE
import psspy

# PS C:\WINDOWS\system32> [Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Python27\;C:\Python27\Scripts\", "User") 
# this is the command in powershell to get powershell to run python code