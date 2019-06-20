# MCSspikedetection
Generates spike train matrix from MultiChannel Systems MEA2100-System recordings (60 electrodes) converted to HDF5

Use the function spikeMatrix = ReadFilterSpikes(loc, filename, Nsig)

INPUTS  
loc: file location  
filename: name of data file  
Nsig: number of standard deviations for event detection

OUTPUT  
spikeMatrix: binary matrix, where 0 indicates no spike and 1 indicates spike; matrix dimension is m x n, where m is the number of samples and n is the number of electrodes (60)

Saves .mat file containing  
spikeMatrix: spike matrix described above,  
rate: sampling rate used in the recording,  
threshold: thresholds for event detection on each electrode in microvolts,  
Nsig: number of standard deviations for event detection,  
filename: name of data file
