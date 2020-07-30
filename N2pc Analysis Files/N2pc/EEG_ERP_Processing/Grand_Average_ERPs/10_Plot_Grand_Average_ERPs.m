%Script #10
%Operates on data averaged across participants
%Uses the output from Script #9: Grand_Average_ERPs.m
%This script loads the low-pass filtered grand average ERP waveforms from Script #9, plots the difference waveforms, parent waveforms, corrected and uncorrected HEOG, and contra and uncorrected VEOG, 
%and saves pdfs of all of the plots in the grand average ERPs folder.

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/N2pc
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/N2pc/EEG_ERP_Processing/Grand_Average_ERPs
Current_File_Path = fileparts(mfilename('fullpath'));

%*************************************************************************************************************************************

%Set baseline correction period in milliseconds
baselinecorr = '-200 0';

%Set x-axis scale in milliseconds
xscale = [-200.0 800.0   -200:200:800];

%Set y-axis scale in microvolts for the EEG channels for the parent waves
yscale_EEG_parent = [-6.0 9.0   -6:3:9];

%Set y-axis scale in microvolts for the EEG channels for the difference waves
yscale_EEG_diff = [-6.0 4.0   -6:2:4];

%Set y-axis scale in microvolts for the ICA-corrected and uncorrected bipolar HEOG channels
yscale_HEOG = [-15.0 15.0   -15:5:15];

%Set y-axis scale in microvolts for the ICA-corrected monopolar VEOG signals and corrected bipolar VEOG signal
yscale_VEOG = [-25.0 25.0   -25:10:25];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Load the low-pass filtered grand average ERP waveforms outputted from Script #9 in .erp ERPLAB file format
ERP = pop_loaderp('filename', 'GA_N2pc_erp_ar_diff_waves_lpfilt.erp', 'filepath', Current_File_Path);    

%Plot the N2pc contra and ipsi parent waveforms at the key electrode sites of interest (P7/P8, PO7/PO8, PO3/PO4, O1/O2)
ERP = pop_ploterps( ERP, [4 5], [8:11] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_parent);
save2pdf([Current_File_Path filesep 'GA_N2pc_Parent_Waves.pdf']);
close all

%Plot the N2pc contra-minus-ipsi difference waveform at the key electrode sites of interest (P7/P8, PO7/PO8, PO3/PO4, O1/O2)
ERP = pop_ploterps( ERP, [1], [8:11] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
save2pdf([Current_File_Path filesep 'GA_N2pc_Difference_Wave.pdf']);
close all

%Plot the N2pc contra-minus-ipsi difference waveform at the key electrode sites of interest (P7/P8, PO7/PO8, PO3/PO4, O1/O2) with the standard error of the mean (SEM)
ERP = pop_ploterps( ERP, [1], [8:11] , 'SEM', 'on', 'Transparency',  0.8, 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
save2pdf([Current_File_Path filesep 'GA_N2pc_Difference_Wave_SEM.pdf']);
close all

%Plot the N2pc contra and ipsi parent waveforms at all electrode sites
ERP = pop_ploterps( ERP, [4 5], [1:11] , 'Box', [3 4], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_parent);
save2pdf([Current_File_Path filesep 'GA_N2pc_Parent_Waves_All_Channels.pdf']);
close all

%Plot the N2pc contra-minus-ipsi difference waveform at all electrode sites
ERP = pop_ploterps( ERP, [1], [1:11] , 'Box', [3 4], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
save2pdf([Current_File_Path filesep 'GA_N2pc_Difference_Wave_All_Channels.pdf']);
close all

%Load the low-pass filtered grand average ERP waveforms outputted from Script #9 in .erp ERPLAB file format
ERP = pop_loaderp('filename', 'GA_N2pc_erp_ar_lpfilt.erp', 'filepath', Current_File_Path);    

%Plot the parent (left and right conditions) ICA-corrected and uncorrected HEOG signals 
ERP = pop_ploterps( ERP, [1 2], [32 34] , 'Box', [1 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_HEOG);
save2pdf([Current_File_Path filesep 'GA_N2pc_HEOG.pdf']);
close all

%Plot the parent (left and right conditions) ICA-corrected monopolar VEOG signals and corrected bipolar VEOG signal
ERP = pop_ploterps( ERP, [1 2], [15 31 33] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_VEOG);
save2pdf([Current_File_Path filesep 'GA_N2pc_VEOG.pdf']);
close all

%*************************************************************************************************************************************
