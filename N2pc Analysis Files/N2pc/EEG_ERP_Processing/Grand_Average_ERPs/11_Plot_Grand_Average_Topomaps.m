%Script #11
%Operates on data averaged across participants
%Uses the output from Script #9: Grand_Average_ERPs.m
%This script loads the grand average ERP waveforms from Script #9, plots the topographic maps of the mean amplitude for the parent waveforms and difference waveform during the time window of the component, 
%and saves pdfs of all of the plots in the grand average ERPs folder.

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/N2pc
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/N2pc/EEG_ERP_Processing/Grand_Average_ERPs
Current_File_Path = fileparts(mfilename('fullpath'));

%*************************************************************************************************************************************

%Set mean amplitude time window in milliseconds (e.g., 200 to 275 ms)
timewindow = [200 275];

%Set EEG channels to include in the topomaps
chans = [1:22];

%Set bins to create corresponding topomaps; a separate topomap will be created for each bin specified
bins = [4 5 1]; 

%Set color scale limits for the topomaps for each bin in microvolts. To have scale limits set automatically, replace the code with myclim  = [];
myclim = [-3 5; -3 5; -1 0];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Load the grand average ERP waveforms outputted from Script #9 in ERPLAB format
ERP = pop_loaderp('filename', 'GA_N2pc_erp_ar_diff_waves.erp', 'filepath', Current_File_Path);  

%Mirror collapsed contralateral/ipsilateral channels in both hemispheres (e.g., replace channel FP1/FP2 with a mirrored copy at the locations of FP1 and FP2) 
ERP = pop_erpchanoperator( ERP, {  'nch1 = ch1 label FP1',  'nch2 = ch2 label F3',  'nch3 = ch3 label F7',  'nch4 = ch4 label FC3',...
  'nch5 = ch5 label C3',  'nch6 = ch6 label C5',  'nch7 = ch7 label P3',  'nch8 = ch8 label P7',  'nch9 = ch9 label PO7',  'nch10 = ch10 label PO3',...
  'nch11 = ch11 label O1',  'nch12 = ch1 label FP2',  'nch13 = ch2 label F4',  'nch14 = ch3 label F8',  'nch15 = ch4 label FC4',  'nch16 = ch5 label C4',...
  'nch17 = ch6 label C6',  'nch18 = ch7 label P4',  'nch19 = ch8 label P8',  'nch20 = ch9 label PO8',  'nch21 = ch10 label PO4',...
  'nch22 = ch11 label O2'} , 'ErrorMsg', 'popup', 'KeepLocations',  0, 'Warning', 'on' );

%Look up channel location 
ERP = erpchanedit(ERP, [DIR filesep 'EEG_ERP_Processing' filesep 'standard-10-5-cap385.elp']);

%Convert mean amplitude time window to corresponding data points
[~,t_temp,~] = closest(ERP.times,timewindow);
timerange = t_temp(1):t_temp(2);

%Create figure
figure('Position',[500 500 1500 500]);

%Calculate the mean amplitude for each bin and channel and create a topomap of the mean amplitude for each bin
for b = 1:length(bins) 
    data2plot = squeeze(mean(ERP.bindata(chans,timerange,bins(b)),2)); 
    if isempty(myclim)
        clim(b,:) = round([min(data2plot) max(data2plot)]/0.5)*0.5; 
    else 
        clim = myclim; 
    end
    
    subplot(1,length(bins),b)
    topoplot(data2plot,ERP.chanlocs,'maplimits',clim(b,:),'colormap',jet); 
    c = colorbar;  
    set(c,'YLim',clim(b,:),'fontsize',12);
    text(0, -0.8, ERP.bindescr{bins(b)},'fontsize',20, 'VerticalAlignment','bottom', ...
  'HorizontalAlignment', 'center'); 
end

%Save a pdf of the topomaps
save2pdf([Current_File_Path filesep 'GA_N2pc_Topomaps.pdf']);
close all

%*************************************************************************************************************************************
