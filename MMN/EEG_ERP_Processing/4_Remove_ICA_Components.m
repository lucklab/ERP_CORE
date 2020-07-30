%Script #4
%Operates on individual subject data
%Uses the output from Script #3: Run_ICA.m
%This script loads the outputted semi-continuous EEG data file containing the ICA weights from Script #3, loads the list of ICA component(s) from the ICA_Components_MMN.xlsx Excel file, and removes the component(s) from the EEG.
%Note that if ICA weights were re-computed on the data, the component(s) to remove will need to be updated in the Excel file to match the new components (see Script #3: Run_ICA.m for further details).

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

%**********************************************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes  
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the continuous EEG data file containing the ICA weights outputted from Script #3 in .set EEGLAB file format
    EEG = pop_loadset('filename',[SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_weighted.set'],'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_weighted'], 'gui','off'); 

    %Load list of ICA component(s) corresponding to ocular artifacts from Excel file ICA_Components_MMN.xlsx
    [ndata, text, alldata] = xlsread([Current_File_Path filesep 'ICA_Components_MMN']); 
    MaxNumComponents = size(alldata, 2);
        for j = 1:length(alldata)
            if isequal(SUB{i}, num2str(alldata{j,1}));
                NumComponents = 0;
                for k = 2:MaxNumComponents
                    if ~isnan(alldata{j,k});
                        NumComponents = NumComponents+1;
                    end
                    Components = [alldata{j,(2:(NumComponents+1))}];
                end
            end
        end

    %Perform ocular correction by removing the ICA component(s) specified above
    EEG = pop_subcomp( EEG, [Components], 0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr'],'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr.set'],'gui','off'); 
    
    %Create a bipolar HEOG channel (HEOG_left minus HEOG_right) and a bipolar VEOG channel (VEOG_lower minus FP2) from the ICA corrected data; the original uncorrected HEOG and VEOG channels are retained for later artifact detection procedures
    EEG = pop_eegchanoperator( EEG, [Current_File_Path filesep 'Add_Corrected_Bipolars_MMN.txt']);
    
    %Add channel location information corresponding to the 3-D coordinates of the electrodes based on 10-10 International System site locations
    EEG = pop_chanedit(EEG, 'lookup',[Current_File_Path filesep 'standard-10-5-cap385.elp']);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip.set'], 'gui', 'off'); 

%End subject loop
end

%**********************************************************************************************************************************************************************
