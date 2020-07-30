%Script #8
%Operates on individual subject data
%Uses the output from Script #7: Average_ERPs.m
%This script loads the low-pass filtered averaged ERP waveforms from Script #7, plots the difference waveforms, parent waveforms, ICA-corrected and uncorrected HEOG, and ICA-corrected VEOG,
%and saves pdfs of all of the plots in the graphs folder located within each subjects's data folder.

close all; clearvars;

%Location of the main study directory, based on where this script is saved
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/ERN
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};	

%**********************************************************************************************************************************************************************

%Set baseline correction period in milliseconds
baselinecorr = '-400 -200';

%Set x-axis scale in milliseconds
xscale = [-600.0 400.0   -600:200:400];

%Set y-axis scale in microvolts for the EEG channels for the parent waves
yscale_EEG_parent = [-35.0 35.0   -35:10:35];

%Set y-axis scale in microvolts for the EEG channels for the difference waves
yscale_EEG_diff = [-35.0 35.0   -35:10:35];

%Set y-axis scale in microvolts for the ICA-corrected and uncorrected bipolar HEOG channels
yscale_HEOG = [-15.0 15.0   -15:5:15];

%Set y-axis scale in microvolts for the ICA-corrected monopolar VEOG signals and corrected bipolar VEOG signal
yscale_VEOG = [-25.0 25.0   -25:10:25];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the low-pass filtered averaged ERP waveform outputted from Script #7 in .erp ERPLAB file format
    ERP = pop_loaderp('filename', [SUB{i} '_ERN_erp_ar_diff_waves_lpfilt.erp'], 'filepath', Subject_Path);    
    
    %Plot the ERN incorrect and correct parent waveforms at the key electrode sites of interest (Fz, FCz, Cz, CPz)
    ERP = pop_ploterps( ERP, [1 2], [16 20 21 14] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_parent);
    save2pdf([Subject_Path 'graphs' filesep SUB{i} '_ERN_Parent_Waves.pdf']);
    close all

    %Plot the ERN incorrect-minus-correct difference waveform at the key electrode sites of interest (Fz, FCz, Cz, CPz)
    ERP = pop_ploterps( ERP, [7], [16 20 21 14] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
    save2pdf([Subject_Path 'graphs' filesep SUB{i} '_ERN_Difference_Wave.pdf']);
    close all

    %Plot the ERN incorrect and correct parent waveforms at all electrode sites
    ERP = pop_ploterps( ERP, [1 2], [1:35] , 'Box', [6 7], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_parent);
    save2pdf([Subject_Path 'graphs' filesep SUB{i} '_ERN_Parent_Waves_All_Channels.pdf']);
    close all

    %Plot the ERN incorrect-minus-correct difference waveform at all electrode sites
    ERP = pop_ploterps( ERP, [7], [1:35] , 'Box', [6 7], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_EEG_diff);
    save2pdf([Subject_Path 'graphs' filesep SUB{i} '_ERN_Difference_Wave_All_Channels.pdf']);
    close all

    %Plot the parent (incorrect and correct conditions) ICA-corrected and uncorrected bipolar HEOG signals 
    ERP = pop_ploterps( ERP, [1 2], [32 34] , 'Box', [1 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_HEOG);
    save2pdf([Subject_Path 'graphs' filesep SUB{i} '_ERN_HEOG.pdf']);
    close all
    
    %Plot the parent (incorrect and correct conditions) ICA-corrected monopolar VEOG signals and corrected bipolar VEOG signal
    ERP = pop_ploterps( ERP, [1 2], [15 31 33] , 'Box', [2 2], 'blc', baselinecorr, 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale,  'yscale', yscale_VEOG);
    save2pdf([Subject_Path 'graphs' filesep SUB{i} '_ERN_VEOG.pdf']);
    close all

%End subject loop
end

%*************************************************************************************************************************************
