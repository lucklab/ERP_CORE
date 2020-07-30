%Script #12
%Operates on individual subject data
%Uses the output from Script #7: Average_ERPs.m
%This script uses the individual subject averaged ERP waveforms from Script #7, and measures the mean amplitude, peak amplitude, peak latency, 50% area latency, and onset latency (50% peak latency) 
%during the time window of the component, and saves a separate text file for each measurement in the ERP Measurements folder. 
%Note that based on their respective susceptibility to high frequency noise, some measurements (e.g., mean amplitude, 50% area latency) are calculated on the averaged ERP waveforms without a low-pass filter applied, 
%whereas %other measurements (e.g., peak amplitude, peak latency, and onset latency) are calculated from waveforms that have been low-pass filtered. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/MMN
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/MMN/EEG_ERP_Processing/ERP_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to measure component amplitudes and latencies from (i.e., subjects that were not excluded due to excessive artifacts), based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};	

%*************************************************************************************************************************************

%Set measurement time window for measuring mean amplitude, peak amplitude, peak latency, and 50% area latency in milliseconds (e.g., 125 to 225 ms)
timewindow = [125 225];

%Set measurement time window for measuring onset latency (50% peak latency) in milliseconds (e.g., 25 to 225 ms)
timewindow_onsetlat = [25 225];

%Set EEG channel(s) to measure the components
chan = [20];

%Set difference wave bin(s) for measurement
diffbin = [3];  

%Set parent wave bins for measurement
parentbins = [1 2];  

%Set baseline correction period for measurement
baselinecorr = [-200 0]; 

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%*************************************************************************************************************************************

%Difference waveform measurements on averaged ERP waveforms without a low-pass filter applied

%Create a text file containing a list of unfiltered ERPsets and their file locations to measure mean amplitude and 50% area latency from
ERPset_list = fullfile(Current_File_Path, 'Measurement_ERP_List_MMN.txt');
fid = fopen(ERPset_list, 'w');
    for i = 1:length(SUB)
        Subject_Path = [DIR filesep SUB{i} filesep];
        erppath = [Subject_Path SUB{i} '_MMN_erp_ar_diff_waves.erp'];
        fprintf(fid,'%s\n', erppath);
    end
fclose(fid);

%Measure mean amplitude using the time window, channel(s), and bin(s) specified above
ALLERP = pop_geterpvalues( ERPset_list, timewindow, diffbin, chan, 'Baseline', baselinecorr, 'Measure', 'meanbl',... 
    'Filename', [Current_File_Path filesep 'Mean_Amplitude_Diff_Waves_MMN.txt'], 'Binlabel', 'on', 'FileFormat', 'wide',... 
    'InterpFactor',  1,  'Resolution', 3);

%Measure 50% area latency (negative area only) using the time window, channel(s), and bin(s) specified above
ALLERP = pop_geterpvalues( ERPset_list, timewindow, diffbin, chan, 'Baseline', baselinecorr, 'Measure', 'fareanlat',... 
    'Afraction', 0.5, 'PeakOnset',  1, 'Fracreplace', 'NaN', 'Filename', [Current_File_Path filesep '50%_Area_Latency_Diff_Waves_MMN.txt'],...
    'Binlabel', 'on', 'FileFormat', 'wide', 'InterpFactor',  1,  'Resolution', 3);
    
%*************************************************************************************************************************************

%Difference waveform measurements on averaged ERP waveforms with a low-pass filter applied

%Create a text file containing a list of low-pass filtered ERPsets and their file locations to measure peak amplitude, peak latency and onset latency (50% peak latency) from
ERPset_list = fullfile(Current_File_Path, 'Measurement_ERP_List_lpfilt_MMN.txt');
fid = fopen(ERPset_list, 'w');
    for i = 1:length(SUB)
        Subject_Path = [DIR filesep SUB{i} filesep];
        erppath = [Subject_Path SUB{i} '_MMN_erp_ar_diff_waves_lpfilt.erp'];
        fprintf(fid,'%s\n', erppath);
    end
fclose(fid);

%Measure (local) peak amplitude using the time window, channel(s), and bin(s) specified above
ALLERP = pop_geterpvalues( ERPset_list, timewindow, diffbin, chan, 'Baseline', baselinecorr, 'Measure','peakampbl',... 
    'Peakpolarity', 'negative', 'Neighborhood',  3, 'PeakReplace', 'absolute', 'Filename',...
    [Current_File_Path filesep 'Peak_Amplitude_Diff_Waves_MMN.txt'], 'Binlabel', 'on', 'FileFormat', 'wide', 'InterpFactor',  1,  'Resolution', 3);

%Measure (local) peak latency using the time window, channel(s), and bin(s) specified above
ALLERP = pop_geterpvalues( ERPset_list, timewindow, diffbin, chan, 'Baseline', baselinecorr, 'Measure','peaklatbl',... 
    'Peakpolarity', 'negative', 'Neighborhood',  3, 'PeakReplace', 'absolute', 'Filename',... 
    [Current_File_Path filesep 'Peak_Latency_Diff_Waves_MMN.txt'], 'Binlabel', 'on', 'FileFormat', 'wide', 'InterpFactor',  1,  'Resolution', 3);

%Measure onset latency (50% peak latency) using the time window, channel(s), and bin(s) specified above
ALLERP = pop_geterpvalues( ERPset_list, timewindow_onsetlat, diffbin, chan, 'Baseline', baselinecorr, 'Measure','fpeaklat', 'Neighborhood',  3,... 
    'Peakpolarity', 'negative', 'Afraction', 0.5, 'Neighborhood',  3, 'Peakreplace', 'absolute', 'PeakOnset',  1, 'Fracreplace', 'NaN', 'Filename',...
    [Current_File_Path filesep 'Onset_Latency_Diff_Waves_MMN.txt'], 'Binlabel', 'on', 'FileFormat', 'wide', 'InterpFactor',  1,  'Resolution', 3);

%*************************************************************************************************************************************

%Parent waveform measurements on averaged ERP waveforms without a low-pass filter applied

ERPset_list = fullfile(Current_File_Path, 'Measurement_ERP_List_MMN.txt');

%Measure mean amplitude using the time window, channel(s), and bin(s) specified above
ALLERP = pop_geterpvalues( ERPset_list, timewindow, parentbins, chan, 'Baseline', baselinecorr, 'Measure', 'meanbl', 'Filename',... 
    [Current_File_Path filesep 'Mean_Amplitude_Parent_Waves_MMN.txt'], 'Binlabel', 'on', 'FileFormat', 'wide', 'InterpFactor',  1,  'Resolution', 3);

%*************************************************************************************************************************************
