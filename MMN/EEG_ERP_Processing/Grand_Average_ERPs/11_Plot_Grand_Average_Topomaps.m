%Script #11
%Operates on data averaged across participants
%Uses the output from Script #9: Grand_Average_ERPs.m
%This script loads the grand average ERP waveforms from Script #9, plots the topographic maps of the mean amplitude for the parent waveforms and difference waveform during the time window of the component, 
%and saves pdfs of all of the plots in the grand average ERPs folder.

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/MMN
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/MMN/EEG_ERP_Processing/Grand_Average_ERPs
Current_File_Path = fileparts(mfilename('fullpath'));

%*************************************************************************************************************************************

%Set mean amplitude time window in milliseconds (e.g., 125 to 225 ms)
timewindow = [125 225];

%Set EEG channels to include in the topomaps
chans = [1:28];

%Set bins to create corresponding topomaps; a separate topomap will be created for each bin specified
bins = [1 2 3]; 

%Set color scale limits for the topomaps for each bin in microvolts. To have scale limits set automatically, replace the code with myclim  = [];
myclim = [-0.5 2; -0.5 2; -2 0];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Load the grand average ERP waveforms outputted from Script #9 in ERPLAB format
ERP = pop_loaderp('filename', 'GA_MMN_erp_ar_diff_waves.erp', 'filepath', Current_File_Path);  

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
save2pdf([Current_File_Path filesep 'GA_MMN_Topomaps.pdf']);
close all

%*************************************************************************************************************************************
