%Script #6
%Operates on individual subject data
%Uses the output from Script #5: Elist_Bin_Epoch.m
%This script loads the epoched EEG data file from Script #5, interpolates bad channels listed in Excel file Interpolate_Channels_MMN.xls, and performs artifact rejection to remove noisy segments
%of EEG and segments containing uncorrected residual eye movements using the parameters tailored to an individual subject's data listed in the corresponding Excel file for that artifact.

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

%Load the Excel file with the list of channels to interpolate for each subject 
[ndata1, text1, alldata1] = xlsread([Current_File_Path filesep 'Interpolate_Channels_MMN']);

%Load the Excel file with the list of thresholds and parameters for identifying C.R.A.P. with the simple voltage threshold algorithm for each subject 
[ndata2, text2, alldata2] = xlsread([Current_File_Path filesep 'AR_Parameters_for_SVT_CRAP_MMN']);

%Load the Excel file with the list of thresholds and parameters for identifying C.R.A.P. with the moving window peak-to-peak algorithm for each subject 
[ndata3, text3, alldata3] = xlsread([Current_File_Path filesep 'AR_Parameters_for_MW_CRAP_MMN']);

%Load the Excel file with the list of thresholds and parameters for identifying any uncorrected horizontal eye movements (using the ICA-corrected HEOG signal) with the step like algorithm for each subject 
[ndata4, text4, alldata4] = xlsread([Current_File_Path filesep 'AR_Parameters_for_SL_HEOG_MMN']);

%*************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes  
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the epoched EEG data file outputted from Script #5 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch'], 'gui', 'off'); 

    %Interpolate channel(s) specified in Excel file Interpolate_Channels_MMN.xls; any channels without channel locations (e.g., the eye channels) should not be included in the interpolation process and are listed in ignored channels
    %EEG channels that will later be used for measurement of the ERPs should not be interpolated
    ignored_channels = [29 30 31 32 33 34 35];        
    DimensionsOfFile1 = size(alldata1);
    for j = 1:DimensionsOfFile1(1);
        if isequal(SUB{i},num2str(alldata1{j,1}));
           badchans = (alldata1{j,2});
           if ~isequal(badchans,'none') | ~isempty(badchans)
           	  if ~isnumeric(badchans)
                 badchans = str2num(badchans);
              end
              EEG  = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  0, 'ignoreChannels',  ignored_channels, 'interpolationMethod', 'spherical', 'replaceChannels', badchans);
           end
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp.set'], 'gui', 'off'); 
        end
    end

    %Identify segments of EEG with C.R.A.P. artifacts using the simple voltage threshold algorithm with the parameters in the Excel file for this subject
    DimensionsOfFile2 = size(alldata2);
    for j = 1:DimensionsOfFile2(1)
        if isequal(SUB{i},num2str(alldata2{j,1}));
            if isequal(alldata2{j,2}, 'default')
                Channels = 1:31;
            else
                Channels = str2num(alldata2{j,2});
            end
            ThresholdMinimum = alldata2{j,3};
            ThresholdMaximum = alldata2{j,4};
            TimeWindowMinimum = alldata2{j,5};
            TimeWindowMaximum = alldata2{j,6};
        end
    end

    EEG  = pop_artextval( EEG , 'Channel',  Channels, 'Flag', [1 2], 'Threshold', [ThresholdMinimum ThresholdMaximum], 'Twindow', [TimeWindowMinimum  TimeWindowMaximum] ); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_SVT'], 'gui', 'off'); 

    %Identify segments of EEG with C.R.A.P. artifacts using the moving window peak-to-peak algorithm with the parameters in the Excel file for this subject
    DimensionsOfFile3 = size(alldata3);
    for j = 1:DimensionsOfFile3(1)
        if isequal(SUB{i},num2str(alldata3{j,1}));
            if isequal(alldata3{j,2}, 'default')
                Channels = 1:28;
            else
                Channels = str2num(alldata3{j,2});
            end
            Threshold = alldata3{j,3};
            TimeWindowMinimum = alldata3{j,4};
            TimeWindowMaximum = alldata3{j,5};
            WindowSize = alldata3{j,6};
            WindowStep = alldata3{j,7};
        end
    end

    EEG  = pop_artmwppth( EEG , 'Channel',  Channels, 'Flag', [1 3], 'Threshold', Threshold, 'Twindow', [TimeWindowMinimum  TimeWindowMaximum], 'Windowsize', WindowSize, 'Windowstep', WindowStep ); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_SVT_MW'], 'gui', 'off'); 

    %Identify segments of EEG with any uncorrected horizontal eye movement artifacts using the step like algorithm with the parameters in the Excel file for this subject
    DimensionsOfFile4 = size(alldata4);
    for j = 1:DimensionsOfFile4(1)
        if isequal(SUB{i},num2str(alldata4{j,1}));
            Channel = alldata4{j,2};
            Threshold = alldata4{j,3};
            TimeWindowMinimum = alldata4{j,4};
            TimeWindowMaximum = alldata4{j,5};
            WindowSize = alldata4{j,6};
            WindowStep = alldata4{j,7};
        end
    end

    EEG  = pop_artstep( EEG , 'Channel', Channel, 'Flag', [1 4], 'Threshold',  Threshold, 'Twindow', [TimeWindowMinimum  TimeWindowMaximum], 'Windowsize',  WindowSize, 'Windowstep', WindowStep );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5, 'setname', [SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_SVT_MW_SL'], 'savenew', [Subject_Path SUB{i} '_MMN_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_ar.set'], 'gui', 'off'); 
 
%End subject loop
end

%*************************************************************************************************************************************
