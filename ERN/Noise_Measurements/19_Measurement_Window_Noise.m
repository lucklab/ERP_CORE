%Script #19
%Operates on individual subject data
%Uses the output from Script #18: PlusMinus_Averages.m
%This script loads the plus-minus averaged ERP waveforms from Script #18, calculates the standard deviation (std) of the voltage in the measurement time window of the ERP component in each subject, 
%creates probability histograms of the measurement window noise measures, and saves the measurement window noise probability histograms to the Noise Measurements folder. 

close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer, e.g.: 
%DIR = /Users/KappenmanLab/ERP_CORE/ERN
DIR = fileparts(fileparts(mfilename('fullpath'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer, e.g.: 
%Current_File_Path = /Users/KappenmanLab/ERP_CORE/ERN/Noise_Measurements
Current_File_Path = fileparts(mfilename('fullpath'));

%List of subjects to include in the grand average ERP waveforms (i.e., subjects that were not excluded due to excessive artifacts), based on the name of the folder that contains that subject's data
SUB = {'1', '2', '3', '4', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '31', '32', '33', '34', '35', '36', '37', '38', '39'};	

%Intialize a .csv file to write individual subject measurement window noise values for each bin to
fid = fopen(fullfile(Current_File_Path, 'MeasurementWindow_Noise_ERN.csv'), 'w');
fprintf(fid, 'SubID, Incorrect, Correct, Incorrect-Correct, Incorrect Filtered, Correct Filtered, Incorrect-Correct Filtered\n');

%***********************************************************************************************************************************************

%Set measurement time window in milliseconds (e.g., 0 to 100 ms)
timewindow = [0 100];

%Set channel(s) to measure noise from 
chan = 20; 

%Set bin(s) to measure noise from
bins = [19 20 21];

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [DIR filesep SUB{i} filesep];

    %Load the plus-minus averaged waveforms with no low-pass filter applied outputted from Script #16 in .erp ERPLAB file format
    ERP = pop_loaderp('filename', [SUB{i} '_ERN_erp_ar_diff_waves_Odd_minus_Even.erp'], 'filepath', Subject_Path); 
 
    %Convert time window for measurements to corresponding data points
    [~,t_temp,~] = closest(ERP.times,timewindow);
    timerange = t_temp(1):t_temp(2);
    
    %Calculate noise in the measurement window of the ERP component (defined as the standard deviation of the voltage in the measurement time window) in the plus-minus averaged waveforms (no low-pass filter)
    meas_noise = nan(2,length(bins));

    for b = 1:length(bins)
        Voltages = ERP.bindata(chan, timerange, bins(b));
        meas_noise(1,b) = std(Voltages);
    end
    
    %Load the plus-minus averaged waveforms with a low-pass filter applied outputted from Script #16 in .erp ERPLAB file format
    ERP = pop_loaderp('filename', [SUB{i} '_ERN_erp_ar_diff_waves_Odd_minus_Even_lpfilt.erp'], 'filepath', Subject_Path); 
 
    %Calculate noise in the measurement window of the ERP component (defined as the standard deviation of the voltage in the measurement time window) in the plus-minus averaged waveforms (low-pass filtered)
    for b = 1:length(bins)
        Voltages = ERP.bindata(chan, timerange, bins(b));
        meas_noise(2,b) = std(Voltages);
    end
         
    %Write values to .csv file
    fprintf(fid, '%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n', SUB{i}, meas_noise(1,:), meas_noise(2,:));

%End subject loop
end

fclose(fid);

%*************************************************************************************************************************************

%Create measurement window noise probability histograms 

%Set the histogram bin edges (lower and upper limits for each bar) to be plotted 
xrange = [0:0.4:4 10];

%Set the center points of histogram bins to be plotted
bincenters = 0.2:0.4:4.2; 

%Set the width of histogram bars for each condition to be plotted
w1=0.75; w2=0.5; w3=0.25;

%Load the measurement window noise .csv file outputted above 
meas_noise_table = readtable([Current_File_Path filesep 'MeasurementWindow_Noise_ERN.csv']);

%Set the columns of data containing the values from the unfiltered waveforms to plot
meas_noise_unfiltered = meas_noise_table{:,2:4};

%Create measurement window noise probability histograms for the unfiltered plus-minus averages, overlaying the conditions (e.g., columns in the file) specified above
probability_per_bin = [];
probability_per_bin(:,1) = histcounts(meas_noise_unfiltered(:,1),xrange,'Normalization','probability');
probability_per_bin(:,2) = histcounts(meas_noise_unfiltered(:,2),xrange,'Normalization','probability');
probability_per_bin(:,3) = histcounts(meas_noise_unfiltered(:,3),xrange,'Normalization','probability');

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
legend({'Incorrect','Correct', 'Incorrect minus Correct'});
set(gca,'fontsize',12);

%Save measurement window noise plots to pdf
save2pdf([Current_File_Path filesep 'ERN_MeasurementWindow_Noise_Unfiltered.pdf']);
close all

%Set the columns of data containing the values from the filtered waveforms
meas_noise_filtered = meas_noise_table{:,5:7};

%Create measurement window noise probability histograms for the low-pass filtered plus-minus averages, overlaying the conditions (e.g., columns in the file) specified above
probability_per_bin = [];
probability_per_bin(:,1) = histcounts(meas_noise_filtered(:,1),xrange,'Normalization','probability');
probability_per_bin(:,2) = histcounts(meas_noise_filtered(:,2),xrange,'Normalization','probability');
probability_per_bin(:,3) = histcounts(meas_noise_filtered(:,3),xrange,'Normalization','probability');

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
legend({'Incorrect','Correct', 'Incorrect minus Correct'});
set(gca,'fontsize',12);

%Save measurement window noise plots to pdf
save2pdf([Current_File_Path filesep 'ERN_MeasurementWindow_Noise_Filtered.pdf']);
close all

%*************************************************************************************************************************************
