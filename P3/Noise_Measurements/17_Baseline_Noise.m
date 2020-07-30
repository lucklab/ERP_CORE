%Script #17
%Operates on individual subject data
%Uses the output from Script #7: Average_ERPs.m
%This script loads the averaged ERP waveforms and low-pass filtered averaged ERP waveforms from Script #7, calculates the standard deviation (std) of the voltage in the baseline period in each subject,
%creates probability histograms of the baseline noise measures, and saves the baseline noise probability histograms to the Noise Measurements folder. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/P3
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/P3/Noise_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to include in the grand average ERP waveforms (i.e., subjects that were not excluded due to excessive artifacts), based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '5', '7', '8', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '31', '32', '33', '34', '36', '37', '38', '39'};	

%Intialize a .csv file to write individual subject baseline noise values for each bin to
fid = fopen(fullfile(Current_File_Path, 'Baseline_Noise_P3.csv'), 'w');
fprintf(fid, 'SubID, Rare, Frequentsi, Rare-Frequent, Rare Filtered, Frequentsi Filtered, Rare-Frequent Filtered\n');

%*************************************************************************************************************************************

%Set baseline period time window in milliseconds (e.g., -200 to 0 ms)
timewindow = [-200 0];

%Set channel(s) to measure baseline noise from 
chan = 13; 

%Set bin(s) to measure baseline noise from
bins = [1 2 3];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the averaged ERP waveforms with no low-pass filter applied outputted from Script #7 in .erp ERPLAB file format
    ERP = pop_loaderp('filename', [SUB{i} '_P3_erp_ar_diff_waves.erp'], 'filepath', Subject_Path); 
 
    %Convert baseline period to corresponding data points
    [~,t_temp,~] = closest(ERP.times,timewindow);
    timerange = t_temp(1):t_temp(2); 
      
    %Measure baseline noise (defined as the standard deviation of the voltage in the baseline period) in the averaged ERP waveforms (no low-pass filter)
    baseline_noise = nan(2,length(bins));
    for b = 1:length(bins)
        Voltages = ERP.bindata(chan, timerange, bins(b));
        baseline_noise(1,b) = std(Voltages);
    end
    
    %Load the averaged ERP waveforms with a low-pass filter applied outputted from Script #7 in .erp ERPLAB file format
    ERP = pop_loaderp('filename', [SUB{i} '_P3_erp_ar_diff_waves_lpfilt.erp'], 'filepath', Subject_Path); 
 
    %Calculate baseline noise (defined as the standard deviation of the voltage in the baseline period) in the low-pass filtered averaged ERP waveforms 
    for b = 1:length(bins)
        Voltages = ERP.bindata(chan, timerange, bins(b));
        baseline_noise(2,b) = std(Voltages);
    end
         
    %Save the baseline noise measures for each subject to a .csv file 
    fprintf(fid, '%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n', SUB{i}, baseline_noise(1,:), baseline_noise(2,:));

%End subject loop
end

fclose(fid);

%*************************************************************************************************************************************

%Create baseline noise probability histograms 

%Set the histogram bin edges (lower and upper limits for each bar) to be plotted 
xrange = [0:0.4:4 10];

%Set the center points of histogram bins to be plotted
bincenters = 0.2:0.4:4.2; 

%Set the width of histogram bars for each condition to be plotted
w1=0.75; w2=0.5; w3=0.25;

%Load the baseline noise .csv file outputted above 
baseline_noise_table = readtable([Current_File_Path filesep 'Baseline_Noise_P3.csv']); 

%Set the columns of data containing the values from the unfiltered waveforms to plot
baseline_noise_unfiltered = baseline_noise_table{:,2:4};

%Create baseline noise probability histograms for the unfiltered ERPs, overlaying the conditions (e.g., columns in the file) specified above
probability_per_bin = [];
probability_per_bin(:,1) = histcounts(baseline_noise_unfiltered(:,1),xrange,'Normalization','probability');
probability_per_bin(:,2) = histcounts(baseline_noise_unfiltered(:,2),xrange,'Normalization','probability');
probability_per_bin(:,3) = histcounts(baseline_noise_unfiltered(:,3),xrange,'Normalization','probability');

bar(bincenters,probability_per_bin(:,1),w1, 'FaceColor', [0.2 0.2 0.5]);
hold on;
bar(bincenters, probability_per_bin(:,2), w2, 'FaceColor',[0 0.7 0.7]);
bar(bincenters, probability_per_bin(:,3), w3, 'FaceColor',[1 0.7 0.7]);
hold off;
ylim([0 1]);
xticks(bincenters); 
myxticklabels = xticklabels; xticklabels([myxticklabels(1:end-1); '>=4']);
ylabel('Probability')
xlabel('SD Amplitude (\muV)');
legend({'Rare','Frequent','Rare minus Frequent'});
set(gca,'fontsize',12);

%Save baseline noise plots to pdf
save2pdf([Current_File_Path filesep 'P3_Baseline_Noise_Unfiltered.pdf']);
close all

%Set the columns of data containing the values from the filtered waveforms
baseline_noise_filtered = baseline_noise_table{:,5:7};

%Create baseline noise probability histograms for the low-pass filtered ERPs, overlaying the conditions (e.g., columns in the file) specified above
probability_per_bin = [];
probability_per_bin(:,1) = histcounts(baseline_noise_filtered(:,1),xrange,'Normalization','probability');
probability_per_bin(:,2) = histcounts(baseline_noise_filtered(:,2),xrange,'Normalization','probability');
probability_per_bin(:,3) = histcounts(baseline_noise_filtered(:,3),xrange,'Normalization','probability');

bar(bincenters,probability_per_bin(:,1),w1, 'FaceColor', [0.2 0.2 0.5]);
hold on;
bar(bincenters, probability_per_bin(:,2), w2, 'FaceColor',[0 0.7 0.7]);
bar(bincenters, probability_per_bin(:,3), w3, 'FaceColor',[1 0.7 0.7]);
hold off;
ylim([0 1]);
xticks(bincenters); 
myxticklabels = xticklabels; xticklabels([myxticklabels(1:end-1); '>=4']);
ylabel('Probability')
xlabel('SD Amplitude (\muV)');
legend({'Rare','Frequent','Rare minus Frequent'});
set(gca,'fontsize',12);

%Save baseline noise plots to pdf
save2pdf([Current_File_Path filesep 'P3_Baseline_Noise_Filtered.pdf']);
close all

%*************************************************************************************************************************************
