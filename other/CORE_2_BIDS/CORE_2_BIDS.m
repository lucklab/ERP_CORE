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
% clear all

ERPs = {'N170','MMN','N2pc','N400','P3','LRP','ERN'};

path_here = matlab.desktop.editor.getActiveFilename;   % this Matlab structure reveals the full filename of the current script on your filesystem
path_here = fileparts(path_here); % we want the path to the containing folder on your system

outdir = [path_here filesep 'ERPCORE_BIDS']';
indir = [path_here filesep 'ERPCORE']';

% BIDS-matlab-tools path, from https://github.com/sccn/bids-matlab-tools
BIDS_matlab_tools_path = [outdir filesep 'bids-matlab-tools'];
addpath(BIDS_matlab_tools_path);

BIDS_setup_files = outdir;

T_taskinfo = readtable([outdir filesep 'ERPCORE_TaskInfo.xlsx']);
T_eventinfo = readtable([outdir filesep 'ERPCORE_EventInfo.xlsx']);

%% Set dataset file info

% eeglab;

for e = 2:length(ERPs)
    comp = ERPs{e};
    
    BIDS_write_path = ['/Users/jfarrensadmin/Google Drive/ERP CORE/ERP CORE, BIDS-Compatible Raw Data' filesep comp];
    
    if exist(BIDS_write_path) ~= 7
        mkdir(BIDS_write_path);
    end
    
    for SUB = 1:40

        % set path variable for this sub
        subject_path = [ indir filesep comp ' Raw Data and Scripts Only' filesep num2str(SUB)];
        subject_data_file = [num2str(SUB) '_' comp '.set'];
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
    generalInfo.Name = comp; 
    generalInfo.BIDSVersion = 'v1.4.0';
    generalInfo.DatasetType = 'raw';
    generalInfo.License = 'CC-BY-4.0';
    generalInfo.Authors = {'Emily Kappenman', 'Jaclyn Farrens', 'Wendy Zhang', 'Andrew X. Stewart', 'Steven J. Luck.'};
    generalInfo.HowToAcknowledge = 'Kappenman, Emily, Jaclyn Farrens, Wendy Zhang, Andrew X. Stewart, and Steven J. Luck. 2020. ERP CORE: An Open Resource for Human Event-related Potential Research. PsyArXiv. doi:10.31234/osf.io/4azqm.';
    generalInfo.ReferencesAndLinks = { 'https://erpinfo.org/erp-core' };

    % participant information for participants.tsv file
    pInfo = { 'participant_id'  'age'   'sex'   'handedness';
        '001'	20  'M' 'right';
        '002'	24  'F' 'right';
        '003'	18  'F' 'right';
        '004'	21  'F' 'right';
        '005'	23  'M' 'right';
        '006'	22  'M' 'right';
        '007'	20  'F' 'right';
        '008'	25  'F' 'right';
        '009'	30  'F' 'right';
        '010'	20  'F' 'right';
        '011'	19  'F' 'right';
        '012'	25  'M' 'left';
        '013'	22  'M' 'right';
        '014'	30  'M' 'right';
        '015'	21  'M' 'right';
        '016'	20  'F' 'right';
        '017'	19  'F' 'right';
        '018'	23  'F' 'right';
        '019'	19  'M' 'left';
        '020'	20  'F' 'right';
        '021'	23  'M' 'right';
        '022'	20  'F' 'right';
        '023'	22  'F' 'right';
        '024'	21  'M' 'right';
        '025'	19  'F' 'right';
        '026'	20  'M' 'right';
        '027'	21  'M' 'right';
        '028'	21  'F' 'right';
        '029'	20  'F' 'right';
        '030'	19  'F' 'right';
        '031'	20  'F' 'right';
        '032'	21  'M' 'right';
        '033'	28  'F' 'right';
        '034'	18  'F' 'right';
        '035'	24  'M' 'right';
        '036'	19  'F' 'right';
        '037'	22  'F' 'right';
        '038'	19  'F' 'right';
        '039'	21  'F' 'right';
        '040'	21  'M' 'right';};

    % participant column description for participants.json file
    pInfoDesc.participant_id.Description = 'Subject ID';
    pInfoDesc.age.Description = 'Age of participant in years';
    pInfoDesc.sex.Description = 'Sex of participant by self report';
    pInfoDesc.handedness.Description = 'Handedness of participant by self report';

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
%     stimuli = {[BIDS_setup_files 'Stimuli_readme.txt'],...
%         [BIDS_setup_files 'A.txt'], ...
%         [BIDS_setup_files 'B.txt'], ...
%         [BIDS_setup_files 'C.txt'], ...
%         [BIDS_setup_files 'D.txt'], ...
%         [BIDS_setup_files 'E.txt']};   

    % channel location file
    chanlocs = [BIDS_setup_files filesep 'CORE_chanlocs_33_no_eog_info.ced'];

%     % event column description for xxx-events.json file (only one such file)
%     eInfoDesc.value.Description = 'Type of event (different from EEGLAB convention). When 2 digits match, like 11 or 22, that is a target matching stimulus';
%     %eInfoDesc.duration = 0; % the duration is considered zero if an impulse, as our event markers are.
%     %eInfoDesc.type.Levels.stimulus = 'Appearance of letter stimulus - A B C D or E';
%     %eInfoDesc.type.Levels.response = 'Correct 201 or incorrect 202';
%     eInfoDesc.latency.Description = 'Latency';


    % Trial types correspondance with event types/values
    % BIDS allows for both trial types and event values
    % --------------------------------------------------
    comp_rowi = find(strcmp(T_eventinfo.Component,comp));
    
    stimcodes = eval(T_eventinfo.StimCodes{comp_rowi});
        
    trialtypes_stim = cell(length(stimcodes),3);
    trialtypes_stim(1:end,1) = num2cell(stimcodes);
    trialtypes_stim(1:end,2) = {'stimulus'};
    trialtypes_stim(1:end,3) = {T_eventinfo.StimDuration(comp_rowi)};
    
    if ~strcmp(comp,'MMN')
        
        respcodes = eval(T_eventinfo.ResponseCodes{comp_rowi});
        
        trialtypes_resp = cell(length(respcodes),3); 
        trialtypes_resp(1:end,1) = num2cell(respcodes);
        trialtypes_resp(1:end,2) = {'response'};
        trialtypes_resp(1:end,3) = {0};

        TrialTypes = [trialtypes_stim; trialtypes_resp];
    else
        TrialTypes = trialtypes_stim;
    end
        



    % Task information for xxxx-eeg.json file
    % ---------------------------------------
    
    comp_rowi = find(strcmp(T_taskinfo.Component,comp));
    
    tInfo.TaskName = T_taskinfo.TaskName{comp_rowi};

    tInfo.InstitutionName = 'San Diego State University';
    tInfo.InstitutionAddress = '6363 Alvarado Court, Suite 250, San Diego, CA 92120 ';

    tInfo.Manufacturer = 'Biosemi';
    tInfo.ManufacturersModelName = 'ActiveTwo';
%     tInfo.SoftwareVersions = 'Recorded with Biosemi ActiView';

    tInfo.TaskDescription = T_taskinfo.TaskDescription{comp_rowi};
    tInfo.Instructions = T_taskinfo.TaskInstructions{comp_rowi};

    % EEG requirements, MUST include:
    tInfo.EEGReference = 'CMS';
    tInfo.SamplingFrequency = 1024;
    tInfo.PowerLineFrequency = 60;
    tInfo.SoftwareFilters = 'n/a';

    % EEG should also have: 
    % https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/03-electroencephalography.html
    tInfo.EEGPlacementScheme = '10-20';
    tInfo.RecordingType = 'continuous';

    tInfo.EEGChannelCount = 30;
    tInfo.EOGChannelCount = 3; 
    tInfo.EMGChannelCount = 0;
    tInfo.ECGChannelCount = 0;
    tInfo.MiscChannelCount = 0;

    % List of script to run the experiment
    code = {[BIDS_setup_files 'Stimuli_readme.txt']};


    %% BIDS write explore
%     bids_export(data, 'targetdir', BIDS_write_path, 'taskName', generalInfo.Name, 'trialtype', TrialTypes, 'gInfo', generalInfo, 'pInfo', pInfo, 'pInfoDesc', pInfoDesc, 'eInfoDesc', eInfoDesc, 'README', README, 'CHANGES', CHANGES, 'stimuli', stimuli, 'codefiles', code, 'tInfo', tInfo, 'chanlocs', chanlocs);
    bids_export(data, 'targetdir', BIDS_write_path, 'taskName', generalInfo.Name, 'trialtype', TrialTypes, 'gInfo', generalInfo, 'pInfo', pInfo, 'pInfoDesc', pInfoDesc,  'README', README, 'CHANGES', CHANGES, 'codefiles', code, 'tInfo', tInfo, 'chanlocs', chanlocs);

end



   

