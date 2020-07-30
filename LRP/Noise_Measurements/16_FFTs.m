%Script #16
%Operates on individual subject data
%Uses the output from Script #2: ICA_Prep.m
%This script loads the semi-continuous EEG data file with break periods and excessively noisy segments removed outputted from Script #2, computes the fast Fourier transform (FFT) on 5-second moving-window segments of the EEG (overlapping by 50%),
%averages the FFTs across all subjects, plots the grand average FFT, and saves a pdf of the FFT plot in the Noise Measurements folder. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/LRP
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/LRP/Noise_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};    

% *************************************************************************************************************************************

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Load the semi-continuous EEG data file with break periods and excessively noisy segments removed outputted from Script #2 in .set EEGLAB file format
    EEG = pop_loadset('filename',[SUB{i} '_LRP_shifted_ds_reref_ucbip_hpfilt_ica_prep2.set'],'filepath', Subject_Path);   

    %Set EEG channel(s) to compute FFT on 
    EEG = pop_eegchanoperator( EEG, {  'ch34 = ((ch5 + ch22)/2) Label C3/C4'} , 'ErrorMsg', 'popup', 'Warning', 'off' );
    chans = 34;

    %Compute FFT for each subject averaged across 5-second moving-window segments of the EEG (with 50% overlap)
    [fft_out(i,:), freq_bin_labels, n_freq_bins_out, freq_bin_width] = compute_fourier(EEG, chans);

%End subject loop
end

%Average FFTs across subjects
All_FFT = mean(fft_out);

%Set frequencies for plotting the FFT (e.g., 1 to 100 Hz)
bottom_freq = 1;
top_freq = 100;

%Plot grand average FFT
plot_fourier(All_FFT, freq_bin_labels, bottom_freq, top_freq)

%Save a pdf of the FFT plot
save2pdf([Current_File_Path filesep 'LRP_FFT.pdf']);

close all

% *************************************************************************************************************************************
