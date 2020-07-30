%Script #1
%Operates on individual subject data
%This script loads the raw continuous EEG data in .set EEGLAB file format, downsamples the data to 256 Hz to speed data processing time, references to the average of 
%P9 and P10, creates bipolar HEOG and VEOG channels, adds channel location information, removes the DC offsets, and applies a high-pass filter. 

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

%***********************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the raw continuous EEG data file in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_MMN.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_MMN'], 'gui', 'off'); 

    %Downsample from the recorded sampling rate of 1024 Hz to 256 Hz to speed data processing (automatically applies the appropriate low-pass anti-aliasing filter)
    EEG = pop_resample( EEG, 256);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[SUB{i} '_MMN_ds'],'savenew',[Subject_Path SUB{i} '_MMN_ds.set'] ,'gui','off'); 

    %Rereference to the average of P9 and P10; create a bipolar HEOG channel (HEOG_left minus HEOG_right) and a bipolar VEOG channel (VEOG_lower minus FP2)
    EEG = pop_eegchanoperator( EEG, [Current_File_Path filesep 'Rereference_Add_Uncorrected_Bipolars_MMN.txt']);
    
    %Add channel location information corresponding to the 3-D coordinates of the electrodes based on 10-10 International System site locations
    EEG = pop_chanedit(EEG, 'lookup',[Current_File_Path filesep 'standard-10-5-cap385.elp']);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', [SUB{i} '_MMN_ds_reref_ucbip'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip.set'], 'gui', 'off');

    %Remove DC offsets and apply a high-pass filter (non-causal Butterworth impulse response function, 0.1 Hz half-amplitude cut-off, 12 dB/oct roll-off)
    EEG  = pop_basicfilter( EEG,  1:33 , 'Boundary', 'boundary', 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt.set'], 'gui', 'off');

%End subject loop
end

%***********************************************************************************************************************************************
