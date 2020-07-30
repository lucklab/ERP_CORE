%Script #7
%Operates on individual subject data
%Uses the output from Script #6: Artifact_Rejection.m
%This script loads the epoched and artifact rejected EEG data from Script #6, creates an averaged ERP waveform, calculates the percentage of trials rejected for artifacts (in total and per bin) 
%and saves the information to a .csv file in each subject's data folder, calculates ERP difference waveforms between conditions, and creates low-pass filtered versions of the ERP waveforms.

close all; clearvars;

%Location of the main study directory, based on where this script is saved
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/MMN
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/MMN/EEG_ERP_Processing
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};	

%**********************************************************************************************************************************************************************

%Create averaged ERP waveforms

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the epoched and artifact rejected EEG data file outputted from Script #6 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_ar.set'], 'filepath', Subject_Path);

    %Create an averaged ERP waveform
    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on');
    ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} '_MMN_erp_ar'], 'filename', [Subject_Path SUB{i} '_MMN_erp_ar.erp']);
    
    %Apply a low-pass filter (non-causal Butterworth impulse response function, 20 Hz half-amplitude cut-off, 48 dB/oct roll-off) to the ERP waveforms
    ERP = pop_filterp( ERP,  1:35 , 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  8 );
    ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} '_MMN_erp_ar_lpfilt'], 'filename', [Subject_Path SUB{i} '_MMN_erp_ar_lpfilt.erp']);

    %Calculate the percentage of trials that were rejected in each bin 
    accepted = ERP.ntrials.accepted;
    rejected= ERP.ntrials.rejected;
    percent_rejected= rejected./(accepted + rejected)*100;
    
    %Calculate the total percentage of trials rejected across all trial types (first two bins)
    total_accepted = accepted(1) + accepted(2);
    total_rejected= rejected(1)+ rejected(2);
    total_percent_rejected= total_rejected./(total_accepted + total_rejected)*100; 
    
    %Save the percentage of trials rejected (in total and per bin) to a .csv file 
    fid = fopen([DIR filesep SUB{i} filesep SUB{i} '_AR_Percentages_MMN.csv'], 'w');
    fprintf(fid, 'SubID,Bin,Accepted,Rejected,Total Percent Rejected\n');
    fprintf(fid, '%s,%s,%d,%d,%.2f\n', SUB{i}, 'Total', total_accepted, total_rejected, total_percent_rejected);
    bins = strrep(ERP.bindescr,', ',' - ');
    for b = 1:length(bins)
        fprintf(fid, ',%s,%d,%d,%.2f\n', bins{b}, accepted(b), rejected(b), percent_rejected(b));
    end
    fclose(fid);
    
%End subject loop
end

%**********************************************************************************************************************************************************************

%Create difference waveforms 

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
        
    %Load averaged ERP waveform (without the 20 Hz low-pass filter) 
    ERP = pop_loaderp('filename', [SUB{i} '_MMN_erp_ar.erp'], 'filepath', Subject_Path);                                                                                                                                                                                                                                                                                                                                       

    %Create ERP difference waveforms between conditions
    ERP = pop_binoperator( ERP, [Current_File_Path filesep 'MMN_Diff_Wave.txt']);
    ERP = pop_savemyerp(ERP, 'erpname', [SUB{i} '_MMN_erp_ar_diff_waves'], 'filename', [Subject_Path SUB{i} '_MMN_erp_ar_diff_waves.erp']);

    %Apply a low-pass filter (non-causal Butterworth impulse response function, 20 Hz half-amplitude cut-off, 48 dB/oct roll-off) to the difference waveforms
    ERP = pop_filterp( ERP,  1:35 , 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  8 );
    ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} '_MMN_erp_ar_diff_waves_lpfilt'], 'filename', [Subject_Path SUB{i} '_MMN_erp_ar_diff_waves_lpfilt.erp']);
    
%End subject loop
end 
    
%**********************************************************************************************************************************************************************
