% ERP CORE BIDS prep
% andrewxstewart July 2020
%
% This script aims to load the ERP CORE datasets, and then save the 
% dataset again in a Brain Imaging Data Structure (BIDS) compatible way.
%
% The paths need to be set.
% Expects EEGLAB to be installed and in-path.
%
% Inspired by example at: https://github.com/sccn/bids-matlab-tools
%
%% set paths
% ERP CORE component path, with numbered subject immediate subfolders
CORE_comp_path = {'/home/axs/eegdata/CORE_2020/P3'};
CORE_comp_names = {'P3'};

% BIDS-matlab-tools path, from https://github.com/sccn/bids-matlab-tools
BIDS_matlab_tools_path = '/home/axs/BIDS/BIDS_conversion/bids-matlab-tools';
addpath(BIDS_matlab_tools_path);

BIDS_write_path = '/home/axs/BIDS/BIDS_conversion/BIDS_test_6';
mkdir(BIDS_write_path);

BIDS_setup_files = '/home/axs/BIDS/BIDS_conversion/';

%% Set dataset file info

eeglab;

for SUB = 1:40;
    
    % set path variable for this sub
    subject_path = [ CORE_comp_path{1} filesep num2str(SUB)];
    subject_data_file = [num2str(SUB) '_' CORE_comp_names{1} '.set'];
    subject_full_path = [subject_path filesep subject_data_file];
    
    % confirm file exists
    file_exists = exist(subject_full_path,'file');
    if file_exists == 0
        beep;
        error('Missing file? Check CORE 2 BIDS folders and paths.');     
    end
    
   data(SUB).file = subject_full_path;
   data(SUB).session = 1;
   data(SUB).run = 1;
    
end

%% Set other BIDS info

% general info for dataset_description.json file
generalInfo.Name = ['ERP CORE _' CORE_comp_names{1}]; 
generalInfo.ReferencesAndLinks = { 'https://erpinfo.org/erp-core' };
generalInfo.Authors = {'Emily Kappenman', 'Jaclyn Farrens', 'Wendy Zhang', 'Andrew X. Stewart', 'Steven J. Luck.'};
generalInfo.HowToAcknowledge = 'Kappenman, Emily, Jaclyn Farrens, Wendy Zhang, Andrew X. Stewart, and Steven J. Luck. 2020. ERP CORE: An Open Resource for Human Event-related Potential Research. PsyArXiv. doi:10.31234/osf.io/4azqm.';
generalInfo.License = 'CC-BY-4.0';

% participant information for participants.tsv file
pInfo = { 'id'  'AGE'   'Sex';
    1   20  'M';
    2   24  'F';
    3   18  'F';
    4   21  'F';
    5   23  'M';
    6   22  'M';
    7   20  'F';
    8   25  'F';
    9   30  'F';
    10  20  'F';
    11  19  'F';
    12  25  'M';
    13  22  'M';
    14  30  'M';
    15  21  'M';
    16  20  'F';
    17  19  'F';
    18  23  'F';
    19  19  'M';
    20  20  'F';
    21  23  'M';
    22  20  'F';
    23  22  'F';
    24  21  'M';
    25  19  'F';
    26  20  'M';
    27  21  'M';
    28  21  'F';
    29  20  'F';
    30  19  'F';
    31  20  'F';
    32  21  'M';
    33  28  'F';
    34  18  'F';
    35  24  'M';
    36  19  'F';
    37  22  'F';
    38  19  'F';
    39  21  'F';
    40  21  'M';};

% participant column description for participants.json file
pInfoDesc.id.Description = 'Subject ID';


% Content for README file

README = sprintf( [ 'The ERP CORE is a freely available online resource consisting of optimized paradigms, experiment control scripts, example data from 40 participants, data processing pipelines and analysis scripts, and a broad set of results for 7 different ERP components obtained from 6 different ERP paradigms:\n\n' ...
'N170 (Face Perception Paradigm)\n' ...
'MMN (Passive Auditory Oddball Paradigm)\n' ...
'N2pc (Simple Visual Search Paradigm)\n' ...
'N400 (Word Pair Judgement Paradigm)\n' ...
'P3b (Active Visual Oddball Paradigm)\n' ...
'LRP and ERN (Flankers Paradigm)\n' ...
'The experiment control scripts, data, and data analysis scripts are at https://erpinfo.org/erp-core ']);

% Content for CHANGES file
% ------------------------
CHANGES = sprintf([ 'Revision history for ERP CORE\n\n' ...
                    'version 1.0 - 20 Jul 2020\n' ...
                    ' - Initial release\n']);   

% List of stimuli to be copied to the stimuli folder
% --------------------------------------------------
stimuli = {[BIDS_setup_files 'Stimuli_readme.txt'],...
    [BIDS_setup_files 'A.txt'], ...
    [BIDS_setup_files 'B.txt'], ...
    [BIDS_setup_files 'C.txt'], ...
    [BIDS_setup_files 'D.txt'], ...
    [BIDS_setup_files 'E.txt']};
    

% channel location file
chanlocs = [BIDS_setup_files 'CORE_chanlocs_33_no_eog_info.ced'];

% event column description for xxx-events.json file (only one such file)
eInfoDesc.value.Description = 'Type of event (different from EEGLAB convention). When 2 digits match, like 11 or 22, that is a target matching stimulus';
%eInfoDesc.duration = 0; % the duration is considered zero if an impulse, as our event markers are.
%eInfoDesc.type.Levels.stimulus = 'Appearance of letter stimulus - A B C D or E';
%eInfoDesc.type.Levels.response = 'Correct 201 or incorrect 202';
eInfoDesc.latency.Description = 'Latency';



% Trial types correspondance with event types/values
% BIDS allows for both trial types and event values
% --------------------------------------------------
trialTypes = { 11 'stimulus'; 12 'stimulus'; 13 'stimulus'; 14  'stimulus'; 15  'stimulus';
               21 'stimulus'; 22 'stimulus'; 23 'stimulus'; 24  'stimulus'; 25  'stimulus';
               31 'stimulus'; 32 'stimulus'; 33 'stimulus'; 34  'stimulus'; 35  'stimulus';
               41 'stimulus'; 42 'stimulus'; 43 'stimulus'; 44  'stimulus'; 45  'stimulus';
               51 'stimulus'; 52 'stimulus'; 53 'stimulus'; 54  'stimulus'; 55  'stimulus';
               201 'response'; 202 'response'};
% When 2 digits match, like '11' or '22', that is a target-matching stimulus.
% 201 for correct response, 202 for incorrect

% Task information for xxxx-eeg.json file
% ---------------------------------------
%tInfo.
tInfo.InstitutionAddress = '6363 Alvarado Court, Suite 250, San Diego, CA 92120 ';
tInfo.InstitutionName = 'San Diego State University';
tInfo.InstitutionalDepartmentName = 'Department of Psychology ';

tInfo.Manufacturer = 'Biosemi';
tInfo.ManufacturersModelName = 'ActiveTwo';
tInfo.SoftwareVersions = 'Recorded with Biosemi ActiView';
tInfo.Instructions = 'In this task, a letter (A, B, C, D, or E) was presented in the center of the screen. For each block of trials, there was a target letter. The task is to respond whether the letter presented matches the target letter or does not match the target letter. If the letter matches target letter, press the [TARGET_BUTTON] with your dominant hand. If the letter does not match  target letter, press the [NONTARGET_BUTTON] with your dominant hand.';


% List of script to run the experiment
code = {[BIDS_setup_files 'Stimuli_readme.txt']};

%% write more BIDS fields
% EEG requirements, MUST include:
tInfo.EEGReference = 'CMS';
tInfo.SamplingFrequency = 1024;
tInfo.PowerLineFrequency = 60;
tTinfo.SoftwareFilters = 'n/a';

% EEG should also have: 
% https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/03-electroencephalography.html
tTinfo.EEGPlacementScheme = '10-20';
tTinfo.RecordingType = 'continuous';



%% BIDS write explore
bids_export(data, 'targetdir', BIDS_write_path, 'taskName', generalInfo.Name, 'trialtype', trialTypes, 'gInfo', generalInfo, 'pInfo', pInfo, 'pInfoDesc', pInfoDesc, 'eInfoDesc', eInfoDesc, 'README', README, 'CHANGES', CHANGES, 'stimuli', stimuli, 'codefiles', code, 'tInfo', tInfo, 'chanlocs', chanlocs);










