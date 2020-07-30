%Script #14
%Operates on individual subject data
%Uses the outputs from Script #5: Elist_Bin_Epoch.m and Script #6: Artifact_Rejection.m
%This script loads the semi-continuous ICA-corrected EEG data file from Script #5 (prior to artifact rejection) and the epoched, artifact rejected EEG data file from Script #6,
%transfers the Event List from the artifact rejected file (containing information about which trials are marked for artifact rejection) to the non-artifact rejected semi-continuous EEG data file, 
%assigns events to bins for correct and incorrect response trials separately for all trials and for only the non-artifact rejected trials, extracts the mean reaction time (RT) data, 
%trial counts, and accuracy per condition for each subject, and saves the behavioral data for all subjects to a .csv file in the Behavior Measurements folder. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/P3
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/P3/Behavior_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};    

%***********************************************************************************************************************************************

%Extract the reaction time data for each subject separately for correct and incorrect trials

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
  
    %Load the epoched and artifact rejected EEG data file outputted from Script #6 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_P3_shifted_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_ar.set'], 'filepath', Subject_Path);
        
    %Export an eventlist containing a record of all event codes with epochs marked for artifact rejection flagged 
    EEG = pop_exporteegeventlist( EEG , 'Filename', [Subject_Path SUB{i} '_P3_Eventlist_For_RTs.txt']); 

    %Load the semi-continuous ICA-corrected EEG data file outputted from Script #5 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_P3_shifted_ds_reref_ucbip_hpfilt_ica_corr.set'], 'filepath', Subject_Path);
    
    %Import the eventlist exported above (with epochs marked for artifact rejection) to the semi-continuous EEG data file  
    EEG = pop_importeegeventlist( EEG, [Subject_Path SUB{i} '_P3_Eventlist_For_RTs.txt'], 'ReplaceEventList', 'on' ); 

    %Assign events to correct and incorrect trial bins for each condition (both before and after artifact rejection) with Binlister; an individual trial may be assigned to more than one bin (bin assignments can be reviewed in each subject's P3_Eventlist_Bins_RTs.txt file)
    EEG  = pop_binlister( EEG , 'BDF', [Current_File_Path filesep 'BDF_P3_RTs.txt'], 'ExportEL', [Subject_Path SUB{i} '_P3_Eventlist_RTs.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );

    %Extract reaction time (RT) data for each trial in each bin and save to a text file in each subject's folder
    pop_rt2text(EEG, 'filename', [Subject_Path SUB{i} '_RTs_&_ACC_P3.txt'], 'Header', 'on', 'listformat', 'basic');
    close all;

%End subject loop
end
%*************************************************************************************************************************************

%Calculate the mean reaction time, trial count, and accuracy data for each subject and compile in a single .csv file

%Intialize a .csv file to write individual subject mean reaction time, trial count, and accuracy values to
fid = fopen(fullfile(Current_File_Path, 'RTs_Trial_Counts_&_ACCs_P3.csv'), 'w');
fprintf(fid, ['SubID, Rare All Correct RT (After AR), Frequent All Correct RT (After AR),'...
 	'Rare All Correct Trial Count (After AR), Frequent All Correct Trial Count (After AR),'...
 	'Rare Accuracy (Before AR), Frequent Accuracy (Before AR), Total Accuracy (Before AR)\n']);

%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Load the reaction time text file outputted above 
    RT_table = readtable([Subject_Path SUB{i} '_RTs_&_ACC_P3.txt'],'delimiter','tab'); 
    
    %Calculate the mean reaction time for each bin (excluding trials marked for artifacts)
    Mean_RT = nanmean(RT_table{:,1:8},1);
    
    %Calculate the trial counts per bin
    Trial_Counts = sum(~isnan(RT_table{:,1:8}),1);
    
    %Calculate the accuracy for the bin(s) of interest (e.g., all trials, prior to artifact rejection) 
    RareAccuracy = Trial_Counts(5) / (Trial_Counts(5) + Trial_Counts(7)) * 100;  
    FrequentAccuracy = Trial_Counts(6) / (Trial_Counts(6) + Trial_Counts(8)) * 100;  
    TotalAccuracy = (RareAccuracy + FrequentAccuracy)/2;  
    
    %Save the mean reaction time (RT), trial counts, and accuracy information for bin(s) of interest to a .csv file 
    fprintf(fid, '%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n', SUB{i}, Mean_RT(1:2), Trial_Counts(1:2), RareAccuracy, FrequentAccuracy, TotalAccuracy);

%End subject loop
end

fclose(fid);  

%*************************************************************************************************************************************
    