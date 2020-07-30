%Script #15 
%Operates on individual subject data
%Uses the output from Script #5: Elist_Bin_Epoch.m
%This script loads the individual subject semi-continuous ICA-corrected EEG data file with an event list from Script #5 (prior to rejecting artifacts), assigns events to bins without applying a reaction time filter using Binlister, 
%extracts the reaction time (RT) data for every trial for each subject, plots probability histograms of the reaction times for each trial across all subjects, and saves the histograms to a pdf file in the Behavior Measurements folder. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/LRP
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/LRP/Behavior_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};    

%*************************************************************************************************************************************

%Extract the reaction time data for each subject with no reaction time filter applied

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Load the semi-continuous ICA-corrected EEG data file with an event list outputted from Script #5 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', [SUB{i} '_LRP_shifted_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist.set'], 'filepath', Subject_Path);
 
    %Assign events to left-hand response and right-hand response trial bins using no reaction time filter with Binlister (bin assignments can be reviewed in each subject's LRP_Eventlist_For_Histo_RTs_Bins.txt file)
    EEG  = pop_binlister( EEG , 'BDF', [Current_File_Path filesep 'BDF_Histo_RTs_LRP.txt'], 'ExportEL', [Subject_Path SUB{i} '_LRP_Eventlist_For_Histo_RTs_Bins.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );

    %Extract reaction time (RT) data for each trial per bin and save to a text file in each subject's folder
    pop_rt2text(EEG, 'filename', [Subject_Path SUB{i} '_LRP_Histo_RTs.txt'], 'Header', 'on', 'listformat', 'basic');
    
%End subject loop    
end

%*************************************************************************************************************************************

%Compile the reaction time data from all subjects and create reaction time probability histograms

All_Sub_Left_RTs = [];
All_Sub_Right_RTs = [];

%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Load the reaction time text file outputted above 
    Single_Sub_Data = readtable([Subject_Path SUB{i} '_LRP_Histo_RTs.txt'],'ReadVariableNames',1,'Delimiter',{'\t'});
    
    Single_Sub_Left_RTs = Single_Sub_Data{:,1};
    Single_Sub_Right_RTs = Single_Sub_Data{:,2};
    
    %Combine reaction times from all subjects
    All_Sub_Left_RTs = [All_Sub_Left_RTs; Single_Sub_Left_RTs];
    All_Sub_Right_RTs = [All_Sub_Right_RTs; Single_Sub_Right_RTs];
   
%End subject loop        
end

%Set the histogram bin edges (lower and upper limits for each bar) to be plotted 
xrange = 0:100:1200;

%Set the width of histogram bars for each condition to be plotted
w1=0.5; w2=0.25; 

%Calculate center points of histogram bins based on bin edges specified above
intervals = diff(xrange);
bincenters = xrange(1:end-1) + intervals/2;
    
%Create baseline noise probability histograms for the unfiltered ERPs, overlaying the conditions (e.g., columns in the file) specified above
Probability_Left_Per_RT_Bin = histcounts(All_Sub_Left_RTs,xrange,'Normalization','probability');
Probability_Right_Per_RT_Bin = histcounts(All_Sub_Right_RTs,xrange,'Normalization','probability');

bar(bincenters, Probability_Left_Per_RT_Bin, w1, 'FaceColor', [0.2 0.2 0.5]);
hold on;
bar(bincenters, Probability_Right_Per_RT_Bin, w2, 'FaceColor',[0 0.7 0.7]);
hold off;
xticks(bincenters(1:2:end)); 
xlim([xrange(1) xrange(end)]);
ylabel('Probability')
xlabel('RT bins (ms)')
legend({'Lefts','Rights'})
set(gca,'fontsize',12);

%Save the histograms to a pdf file
save2pdf([Current_File_Path filesep 'RT_Probability_Histogram_Lefts_&_Rights.pdf']);
close all

%*************************************************************************************************************************************
