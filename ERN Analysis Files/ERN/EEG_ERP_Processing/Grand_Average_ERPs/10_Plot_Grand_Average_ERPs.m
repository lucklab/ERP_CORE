%Script #10
%Operates on data averaged across participants
%Uses the output from Script #9: Grand_Average_ERPs.m
%This script loads the low-pass filtered grand average ERP waveforms from Script #9, plots the difference waveforms, parent waveforms, ICA-corrected and uncorrected HEOG, and ICA-corrected VEOG, 
%and saves pdfs of all of the plots in the grand average ERPs folder.

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/ERN
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/ERN/EEG_ERP_Processing/Grand_Average_ERPs
Current_File_Path = fileparts(mfilename('fullpath'));

%*************************************************************************************************************************************

%Set baseline correction period in milliseconds
baselinecorr = '-400 -200';

%Set x-axis scale in milliseconds
xscale = [-600.0 400.0   -600:200:400];

%Set y-axis scale in microvolts for the EEG channels for the parent waves
yscale_EEG_parent = [-10.0 15.0   -10:5:15];

%Set y-axis scale in microvolts for the EEG channels for the difference waves
yscale_EEG_diff = [-30.0 20.0   -30:10:20];

%Set y-axis scale in microvolts for the ICA-corrected and uncorrected bipolar HEOG channels
yscale_HEOG = [-15.0 15.0   -15:5:15];

%Set y-axis scale in microvolts for the ICA-corrected monopolar VEOG signals and corrected bipolar VEOG signal
yscale_VEOG = [-25.0 25.0   -25:10:25];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Load the low-pass filtered grand average ERP waveforms outputted from Script #9 in .erp ERPLAB file format
ERP = pop_loaderp('filename', 'GA_ERN_erp_ar_diff_waves_lpfilt.erp', 'filepath', Current_File_Path);    

%Plot the ERN incorrect and correct parent waveforms at the key electrode sites of interest (Fz, FCz, Cz, CPz)
ERP = pop_ploterps( ERP, [1 2], [16 20 21 14] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_parent);
save2pdf([Current_File_Path filesep 'GA_ERN_Parent_Waves.pdf']);
close all

%Plot the ERN incorrect-minus-correct difference waveform at the key electrode sites of interest (Fz, FCz, Cz, CPz)
ERP = pop_ploterps( ERP, [7], [16 20 21 14] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
save2pdf([Current_File_Path filesep 'GA_ERN_Difference_Wave.pdf']);
close all

%Plot the ERN incorrect-minus-correct difference waveform at the key electrode sites of interest (Fz, FCz, Cz, CPz) with the standard error of the mean (SEM)
ERP = pop_ploterps( ERP, [7], [16 20 21 14] , 'SEM', 'on', 'Transparency',  0.8, 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
save2pdf([Current_File_Path filesep 'GA_ERN_Difference_Wave_SEM.pdf']);
close all

%Plot the ERN incorrect and correct parent waveforms at all electrode sites
ERP = pop_ploterps( ERP, [1 2], [1:35] , 'Box', [6 7], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_parent);
save2pdf([Current_File_Path filesep 'GA_ERN_Parent_Waves_All_Channels.pdf']);
close all

%Plot the ERN incorrect-minus-correct difference waveform at all electrode sites
ERP = pop_ploterps( ERP, [7], [1:35] , 'Box', [6 7], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
save2pdf([Current_File_Path filesep 'GA_ERN_Difference_Wave_All_Channels.pdf']);
close all

%Plot the parent (incorrect and correct conditions) ICA-corrected and uncorrected HEOG signals 
ERP = pop_ploterps( ERP, [ 1 2], [32 34] , 'Box', [1 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_HEOG);
save2pdf([Current_File_Path filesep 'GA_ERN_HEOG.pdf']);
close all

%Plot the parent (incorrect and correct conditions) ICA-corrected monopolar VEOG signals and corrected bipolar VEOG signal
ERP = pop_ploterps( ERP, [1 2], [15 31 33] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_VEOG);
save2pdf([Current_File_Path filesep 'GA_ERN_VEOG.pdf']);
close all

%*************************************************************************************************************************************
