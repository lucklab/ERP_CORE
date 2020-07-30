%Script #2
%Operates on individual subject data
%Uses the output from Script #1: Import_Raw_EEG_Reref_DS_Hpfilt.m
%This script loads the outputted continuous EEG data file from Script #1, removes segments of EEG during the break periods in between trial blocks, and
%removes especially noisy segments of EEG during the trial blocks to prepare the data for ICA. Note that the goal of this stage of processing is to remove 
%particularly noisy segments of data; a more thorough rejection of artifacts will be performed later on the epoched data.

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/MMN
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/MMN/EEG_ERP_Processing
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};    

%*************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the continuous EEG data file outputted from Script #1 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt'], 'gui', 'off'); 

    %Remove segments of EEG during the break periods in between trial blocks (defined as 2 seconds or longer in between successive stimulus event codes)
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG', 0, 'endEventcodeBufferMS',  2000, 'ignoreUseEventcodes', [70 80 180], 'ignoreUseType', 'Use', 'startEventcodeBufferMS',  2000, 'timeThresholdMS',  2000 );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep1'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep1.set'], 'gui', 'off'); 

    %Load parameters for rejecting especially noisy segments of EEG during trial blocks from Excel file ICA_Prep_Values_MMN.xls. Default parameters can be used initially but may need 
    % to be modified for a given participant on the basis of visual inspection of the data.
    [ndata, text, alldata] = xlsread([Current_File_Path filesep 'ICA_Prep_Values_MMN']); 
        for j = 1:length(alldata)           
            if isequal(SUB{i},num2str(alldata{j,1}));
                AmpthValue = alldata{j,2};
                WindowValue = alldata{j,3};
                StepValue = alldata{j,4};
            end
        end

    %Delete segments of the EEG exceeding the thresholds defined above
    EEG = pop_continuousartdet( EEG, 'ampth', AmpthValue, 'winms', WindowValue, 'stepms', StepValue, 'chanArray', 1:31, 'review', 'off');        
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2.set'], 'gui', 'off'); 

%End subject loop
end

%*************************************************************************************************************************************
