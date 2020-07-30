% %Script #3
% %Operates on individual subject data
% %Uses the output from Script #2: ICA_Prep.m
% %This script loads the outputted semi-continuous EEG data file from Script #2, computes the ICA weights that will be used for artifact correction of ocular artifacts, transfers the ICA weights to the 
% %continuous EEG data file outputted from Script #1 (e.g., without the break periods and noisy segments of EEG removed), and saves a pdf of the topographic maps of the ICA weights.
%
%
% % PLEASE NOTE:
% % The results of ICA decomposition using binica/runica (i.e., the ordering of the components, the scalp topographies, and the time courses of the components) will differ slightly each time ICA weights are computed.
% % This is because ICA decomposition starts with a random weight matrix (and randomly shuffles the data order in each training step), so the convergence is slightly different every time it is run.
% % As a result, the topographic maps of the ICA weights and the excel spreadsheet (ICA_Components_MMN.xlsx) containing the list of ICA components to be removed for each subject included in this package 
% % will NOT be valid if ICA weights are re-computed. To avoid confusion or accidental overwriting of the relevant data files, this script has been commented out.   
%
% % To maintain the component weights and ordering from the original analysis, you can skip running this script and proceed to Script #4 Remove_ICA_Components.m. 
%
% % If you wish to re-compute ICA weights on the ERP CORE data, you will need to disregard the information in ICA_Components_MMN.xslx and evaluate the scalp topography and 
% % time course of the outputted ICA components to determine which component(s) to remove. 
%
% % To use this script, select all and use the shortcut Ctrl-T for PC or Command-T for Mac to uncomment the code. 
% 
% 
% close all; clearvars;
% 
% %Location of the main study directory
% %This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
% %DIR = /Users/KappenmanLab/ERP_CORE/MMN
% DIR = fileparts(fileparts(mfilename('fullpath'))); 
% 
% %Location of the folder that contains this script and any associated processing files
% %This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
% %Current_File_Path = /Users/KappenmanLab/ERP_CORE/MMN/EEG_ERP_Processing
% Current_File_Path = fileparts(mfilename('fullpath'));
% 
% %List of subjects to process, based on the name of the folder that contains that subject's data
% SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};    
%
% %***********************************************************************************************************************************************
% 
% %Loop through each subject listed in SUB
% for i = 1:length(SUB)
%     
%     %Open EEGLAB and ERPLAB Toolboxes  
%     [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
% 
%     %Define subject path based on study directory and subject ID of current subject
%     Subject_Path = [DIR filesep SUB{i} filesep];
% 
%     %Load the semi-continuous EEG data file outputted from Script #2 in .set EEGLAB file format
%     EEG = pop_loadset( 'filename', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2.set'], 'filepath', Subject_Path);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2'], 'gui', 'off');   
% 
%     %Compute ICA weights with binICA (a compiled and faster version of ICA). If binICA is not an option (e.g., on a Windows machine), use runICA by replacing the code with the following: 
%     %EEG = pop_runica(EEG,'extended',1,'chanind', [1:31]);
%     %Note that the bipolar HEOG and VEOG channels are not included in the channel list for computing ICA weights, because they are not linearly independent of the channels that were used to create them
%     EEG = pop_runica(EEG,'extended',1,'icatype','binica','chanind', [1:31]); 
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2_weighted'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2_weighted.set'], 'gui', 'off');
% 
%     %Load the continuous EEG data file outputted from Script #1 in .set EEGLAB file format
%     EEG = pop_loadset( 'filename', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt.set'], 'filepath', Subject_Path);
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt'], 'gui', 'off'); 
% 
%     %Transfer ICA weights to the continuous EEG data file (e.g., without the break periods and noisy segments of data removed)
%     EEG = pop_editset(EEG, 'icachansind', 'ALLEEG(2).icachansind', 'icaweights', 'ALLEEG(2).icaweights', 'icasphere', 'ALLEEG(2).icasphere');
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_weighted'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_weighted.set'], 'gui', 'off');
% 
%     %Save a pdf of the topographic maps of the ICA weights for later review
%     set(groot,'DefaultFigureColormap',jet)
%     pop_topoplot(EEG, 0, [1:31],[SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_prep2_weighted'], [6 6] ,0,'electrodes','on');
%     save2pdf([Subject_Path 'graphs' filesep SUB{i} '_MMN_ICA_Weights.pdf']);
%     close all
%     
% %End subject loop
% end
% 
% %***********************************************************************************************************************************************
