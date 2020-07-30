%Script #13 
%Operates on individual subject data
%Uses the output from Script #12: Measure_ERPs.m
%This script loads the individual subject difference waveform measurement values from Script #12, creates histogram plots of the single-participant measurement values for each measure of amplitude and latency (e.g., mean amplitude, peak amplitude), 
%and saves pdfs of all of the plots in the ERP Measurements folder.

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/MMN
DIR = fileparts(fileparts(fileparts(mfilename('fullpath')))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/MMN/EEG_ERP_Processing/ERP_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%*************************************************************************************************************************************

%Specify the measurements that will be used to create histograms using the text files created by Script #12 (e.g., Mean_Amplitude_Diff_Waves.txt)
Measures = {'Mean_Amplitude','Peak_Amplitude','Peak_Latency','50%_Area_Latency','Onset_Latency'}; 

%Set the histogram bin edges (lower and upper limits for each bar) to be plotted for each measurement
Xranges = {-6.5:1:2.5, -8.5:1:0.5, 140:10:230, 140:10:230, 25:20:225};

%Loop through each measurement listed in Measures
for m = 1:length(Measures)
    
    meas = Measures{m};
    
    %Calculate center points of histogram bins based on bin edges specified above
    intervals = diff(Xranges{m});
    bincenters = Xranges{m}(1:end-1) + intervals/2;
    
    %Load the single-participant measurement values outputted from Script #12
    Meas_file = [Current_File_Path filesep meas '_Diff_Waves_MMN.txt'];
    Meas_table = readtable(Meas_file,'delimiter','\t','HeaderLines',1);
    Meas_data = Meas_table{:,1};
    
    %Create histogram plots
    [bincounts] = histcounts(Meas_data,Xranges{m});
    bar(bincenters,bincounts,0.75,'FaceColor',[0.2 0.2 0.5]);
    ylim([0 30]); xticks(bincenters);
    ylabel('Number of Subjects')
    xlabel(strrep(meas,'_',' '))
    set(gca,'fontsize',12)
    legend({'Deviant-Standard'});
    
    %Saves the histogram plots to pdf
    save2pdf([Current_File_Path filesep meas '_Histogram_MMN.pdf']);
    close all
    
%End measures loop    
end

%*************************************************************************************************************************************
