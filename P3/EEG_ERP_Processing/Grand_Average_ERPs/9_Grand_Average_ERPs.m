%Script #9
%Operates on individual subject data
%Uses the output from Script #7: Average_ERPs.m
%This script uses the individual subject averaged ERP waveforms from Script #7 to create grand average ERP waveforms across participants both with and without a low-pass filter applied. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/P3
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/P3/EEG_ERP_Processing/Grand_Average_ERPs
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to include in the grand average ERP waveforms (i.e., subjects that were not excluded due to excessive artifacts), based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '31', '32', '33', '34', '36', '37', '38', '39'};	

%*************************************************************************************************************************************

%Create grand average ERP waveforms from individual subject ERPs without low-pass filter applied 

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Create a text file containing a list of ERPsets and their file locations to include in the grand average ERP waveforms
ERPset_list = fullfile(Current_File_Path, 'GA_P3_erp_ar_diff_waves.txt');
fid = fopen(ERPset_list, 'w');
    for i = 1:length(SUB)
        Subject_Path = [DIR filesep SUB{i} filesep];
        erppath = [Subject_Path SUB{i} '_P3_erp_ar_diff_waves.erp'];
        fprintf(fid,'%s\n', erppath);
    end
fclose(fid);

%Create a grand average ERP waveform
ERP = pop_gaverager( ERPset_list , 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', 'GA_P3_erp_ar_diff_waves', 'filename', 'GA_P3_erp_ar_diff_waves.erp', 'filepath', Current_File_Path, 'Warning', 'off');

%*************************************************************************************************************************************

%Create grand average ERP waveforms from individual subject ERPs with a low-pass filter applied

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Create a text file containing a list of low-pass filtered ERPsets and their file locations to include in the grand average ERP waveforms
ERPset_list = fullfile(Current_File_Path, 'GA_P3_erp_ar_diff_waves_lpfilt.txt');
fid = fopen(ERPset_list, 'w');
    for i = 1:length(SUB)
        Subject_Path = [DIR filesep SUB{i} filesep];
        erppath = [Subject_Path SUB{i} '_P3_erp_ar_diff_waves_lpfilt.erp'];
        fprintf(fid,'%s\n', erppath);
    end
fclose(fid);

%Create a grand average ERP waveform
ERP = pop_gaverager( ERPset_list , 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', 'GA_P3_erp_ar_diff_waves_lpfilt', 'filename', 'GA_P3_erp_ar_diff_waves_lpfilt.erp', 'filepath', Current_File_Path, 'Warning', 'off');

%*************************************************************************************************************************************
