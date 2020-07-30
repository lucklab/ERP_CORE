%Script #18
%Operates on individual subject data
%Uses the output from Script #6: Artifact_Rejection.m
%This script loads the epoched and artifact rejected EEG data file from Script #6, creates separate averaged ERP waveforms for even-numbered trials and odd-numbered trials for each subject,
%inverts the polarity of the ERP from even-numbered trials and averages it with the ERP from odd-numbered trials to create plus-minus averages, plots the plus-minus averages from all subjects, 
%calculates and plots the standard deviation across subjects at each point in the plus-minus averages, and saves pdfs of the plots in the Noise Measurements folder. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/N2pc
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/N2pc/Noise_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '6', '8', '11', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40'};    

%***********************************************************************************************************************************************

%Create separate ERP waveforms for odd-numbered trials and even-numbered trials

%Set the conditions for dividing trials (e.g., odd-numbered and even-numbered)
Conditions = {'ODD','EVEN'};

%Set bins to use in creating plus-minus averages (parent bins only; the difference wave will be re-created below)
bins = [1 2];

%Open EEGLAB and ERPLAB Toolboxes   
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Load the epoched and artifact rejected EEG data file outputted from Script #6 in .set EEGLAB file format
    EEG = pop_loadset('filename', [SUB{i} '_N2pc_shifted_ds_reref_ucbip_hpfilt_ica_corr_cbip_elist_bins_epoch_interp_ar.set'], 'filepath', Subject_Path);

    %Loop through conditions specified above (e.g., odd-numbered, even-numbered)
    for condition = Conditions
        epochFilter = getepochindex6(EEG, 'Bin', bins,'Nepoch', 'amap', 'Artifact', 'good', 'Catching', condition{:}, 'Indexing', 'relative', 'Episode', 'any');      

        %Create an averaged ERP waveform using only the trials from the specified condition (e.g., odd-numbered trials)
        ERP = pop_averager( EEG, 'Criterion', epochFilter, 'ExcludeBoundary', 'on', 'SEM', 'on');
        ERP = pop_savemyerp( ERP, 'erpname', [SUB{i} '_N2pc_erp_ar_' condition{:}], 'filename', [Subject_Path SUB{i} '_N2pc_erp_ar_' condition{:} '.erp']);
        
        %Create a difference ERP waveform using only the trials from the specified condition (e.g., odd-numbered trials)
        ERP = pop_binoperator( ERP, [DIR filesep 'EEG_ERP_Processing' filesep 'N2pc_Diff_Wave.txt']);
        ERP = pop_savemyerp(ERP, 'erpname', [SUB{i} '_N2pc_erp_ar_diff_waves_' condition{:}], 'filename', [DIR filesep SUB{i} filesep SUB{i} '_N2pc_erp_ar_diff_waves_' condition{:} '.erp']);
    
    %End condition loop
    end
    
%End subject loop
end

%***********************************************************************************************************************************************

%Create plus-minus average waveforms (i.e., invert the polarity of the ERP created from even-numbered trials and average with the ERP created from odd-numbered trials)

%Loop through each subject listed in SUB
for i = 1:length(SUB)
    
    %Open EEGLAB and ERPLAB Toolboxes   
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Append the ERP waveforms from odd-numbered trials and even-numbered trials
    [ERP ALLERP] = pop_loaderp( 'filename', {[SUB{i} '_N2pc_erp_ar_diff_waves_ODD.erp'], [SUB{i} '_N2pc_erp_ar_diff_waves_Even.erp']}, 'filepath', Subject_Path);                                                                                                     
    ERP = pop_appenderp( ALLERP , 'Erpsets', [1 2], 'Prefixes', {'Odd', 'Even'} );

    %Subtract the ERP from even-numbered trials from the ERP from odd-numbered trials (odd mins even) and divide by 2 (this is equivalent to inverting the polarity of the ERP from even-numbered trials and averaging it with the ERP from odd-numbered trials)
	ERP = pop_binoperator( ERP, {  'b19 = ((b4 - b13)/2) Label Odd Contra Wave - Even Contra Wave', 'b20 = ((b5 - b14)/2) Label Odd Ipsi Wave - Even Ipsi Wave', 'b21 = ((b1 - b10)/2) Label Odd Diff Wave - Even Diff Wave' });
    ERP = pop_savemyerp(ERP, 'erpname', [SUB{i} '_N2pc_erp_ar_diff_waves_Odd_minus_Even'], 'filename', [SUB{i} '_N2pc_erp_ar_diff_waves_Odd_minus_Even.erp'], 'filepath', [DIR filesep SUB{i} filesep]);   

    %Apply a low-pass filter (non-causal Butterworth impulse response function, 20 Hz half-amplitude cut-off, 48 dB/oct roll-off) to the plus-minus waveforms
    ERP = pop_filterp( ERP,  1:11 , 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  8 );
    ERP = pop_savemyerp(ERP, 'erpname', [SUB{i} '_N2pc_erp_ar_diff_waves_Odd_minus_Even_lpfilt'], 'filename', [SUB{i} '_N2pc_erp_ar_diff_waves_Odd_minus_Even_lpfilt.erp'], 'filepath', Subject_Path, 'Warning', 'off');

%End subject loop
end

%***********************************************************************************************************************************************


%Append plus-minus waveforms from all subjects for plotting 

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 

%Loop through each subject listed in SUB
for i = 1:length(SUB)  
    
    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];
    
    %Load low-pass filtered plus-minus waveforms 
    [ERP ALLERP] = pop_loaderp( 'filename', [SUB{i} '_N2pc_erp_ar_diff_waves_Odd_minus_Even_lpfilt.erp'], 'filepath', [DIR filesep SUB{i} filesep]);      
end

%Append low-pass filtered ERP waveforms from all subjects 
ERP = pop_appenderp( ALLERP , 'Erpsets', 1:length(SUB), 'Prefixes', SUB);
ERP = pop_savemyerp(ERP, 'erpname', 'All_Sub_Appended_Odd_minus_Even_N2pc_lpfilt', 'filename', 'All_Sub_Appended_Odd_minus_Even_N2pc_lpfilt.erp', 'filepath', Current_File_Path, 'Warning', 'off');

%***********************************************************************************************************************************************

%Plot individual subject plus-minus waveforms overlaid on a single plot separately for each condition

%Set x-axis scale in milliseconds
xscale =  [-200.0 800.0   -200:200:800];

%Set y-axis scale in microvolts for the EEG channels for the parent waves
yscale = [ -6.0 4.0   -6:2:4 ];

%Set channel to plot 
chan = 9;

%Set line colors 
linecolors = {'y','m','c','r','g','b','k'};

%Plot individual subject plus-minus waveforms for contralateral trials (bin 19)
bin = 19;
ERP = pop_ploterps( ERP,  bin:21:ERP.nbin,  chan , 'Box', [ 1 1], 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale, 'yscale', yscale, 'linespec', linecolors);
save2pdf([Current_File_Path filesep 'N2pc_PlusMinus_Waveforms_Contra.pdf']);
close all

%Plot individual subject plus-minus waveforms for ipsilateral trials (bin 20)
bin = 20;
ERP = pop_ploterps( ERP,  bin:21:ERP.nbin,  chan , 'Box', [ 1 1], 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale, 'yscale', yscale, 'linespec', linecolors);
save2pdf([Current_File_Path filesep 'N2pc_PlusMinus_Waveforms_Ipsi.pdf']);
close all

%Plot individual subject plus-minus waveforms for contralateral minus ipsilateral trials (bin 21)
bin = 21;
ERP = pop_ploterps( ERP,  bin:21:ERP.nbin,  chan , 'Box', [ 1 1], 'Maximize', 'on', 'Style', 'Classic', 'xscale', xscale, 'yscale', yscale, 'linespec', linecolors);
save2pdf([Current_File_Path filesep 'N2pc_PlusMinus_Waveforms_Contra-Ipsi.pdf']);
close all

%***********************************************************************************************************************************************

%Plot the standard deviation across subjects in the plus-minus average waveforms at each time point 

%Extract data from specified bin (e.g., bin 21 - contralateral minus ipsilateral trials)
bin = 21;
OnlyMainBins = ERP.bindata(:,:,bin:21:ERP.nbin);

%Compute standard deviation across subjects at each time point 
GAstd = std(OnlyMainBins,0,3);

%%Plot the standard deviation values 
plot(ERP.times,GAstd(chan,:),'linewidth',2);
xlim([ERP.xmin ERP.xmax]*1000);
ylim([0 5]);
xlabel('Time (ms)');
ylabel('Standard Deviation (\muV)');

%Save a pdf of the plot
save2pdf([Current_File_Path filesep 'N2pc_PlusMinus_SD.pdf']);
close all;

%***********************************************************************************************************************************************
