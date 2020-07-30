% bids_export - this function allows converting a collection of datasets to
%               BIDS formated folders and files.
%
% Usage:
%    bids_export(files, varargin)
%
% Input:
%   files      - Structure with the fields 'file','session' and 'run'.
%                The field 'file' should be a cell array of strings
%                with the path to the data files. The fields 'session'
%                and 'run' will contain the session index and the run index
%                within the session for the corresponding data file in the
%                same index. 
%
%                See example below for a case with 2 subjects with
%                2 sessions and 2 run each:
%                 subject(1).file     = 'subj1.set';
%                 subject(1).chanlocs = 'subj1.elp';  % optional
%                 subject(2).file     = 'subj2.set';
%                 subject(2).chanlocs = 'subj2.elp';  % optional
%
%                See example below for a case with 2 subjects with
%                2 sessions and 2 runs each:
%                 subject(1).file    = {'subj-1_ss-1-run1' 'subj-1_ss-1-run2' 'subj-1_ss-2-run1' 'subj-1_ss-2-run2'};
%                 subject(1).session = [ 1 1 2 2 ];
%                 subject(1).run     = [ 1 2 1 2 ];
%                 subject(1).task    = { 'go-no task' 'control task' 'go-no task' 'control task' };
%                 subject(1).instructions = { 'Press button when you see an animal' 'Look passively at the images' 'Press button when you see an animal' 'Look passively at the images'  };
%                 subject(1).chanlocs = {'subj-1_ss-1-run1.elp' 'subj-1_ss-1-run2.elp' 'subj-1_ss-2-run1.elp' 'subj-1_ss-2-run2.elp'};
%                 subject(2).file    = {'subj-2_ss-1-run1' 'subj-2_ss-1-run2' 'subj-2_ss-2-run1' 'subj-2_ss-2-run2'};
%                 subject(2).session = [ 1 1 2 2 ];
%                 subject(2).run     = [ 1 2 1 2 ];
%                 subject(2).task    = { 'go-no task' 'control task' 'go-no task' 'control task' };
%                 subject(2).instructions = { 'Press button when you see an animal' 'Look passively at the images' 'Press button when you see an animal' 'Look passively at the images'  };
%                 subject(2).chanlocs = {'subj-2_ss-1-run1.elp' 'subj-2_ss-1-run2.elp' 'subj-2_ss-2-run1.elp' 'subj-2_ss-2-run2.elp'};
%
%                Alternate representation that is also functional:
%                 subject(1).file(1).file = 'subj-1_ss-1-run1';
%                 subject(1).file(1).session = 1;
%                 subject(1).file(1).run     = 1;
%                 subject(1).file(1).task    = 'go-no task';
%                 subject(1).file(1).instructions = 'Press button when you see an animal';
%                 subject(1).file(1).chanlocs = 'subj-1_ss-1-run1.elp';
%                 subject(1).file(2).file = 'subj-1_ss-1-run2';
%                 subject(1).file(2).session = 1;
%                 subject(1).file(2).run     = 2;
%                 subject(1).file(2).task    = 'control task';
%                 subject(1).file(2).instructions = 'Look passively at the images';
%                 subject(1).file(2).chanlocs = 'subj-1_ss-1-run2.elp';
%                 ...
%
% Optional inputs:
%  'targetdir' - [string] target directory. Default is 'bidsexport' in the
%                current folder.
%
%  'taskName'  - [string] name of the task. No space are allowed and no
%                special characters. Default is ''.
%
%  'README'    - [string] content of the README file. If the string points
%                to a file that exists on the path, the file is copied.
%                Otherwise a new README file is created and the content of
%                this variable is copied to the new file.
%
%  'CHANGES'   - [string] content of the README file. If the string points
%                to a file that exists on the path, the file is copied.
%
%  'codefiles' - [cell] cell array of file names containing code related
%                to importing or processing the data.
%
%  'stimuli'   - [cell] cell array of type and corresponding file names.
%                For example: { 'sound1' '/Users/xxxx/sounds/sound1.mp3';
%                               'img1'   '/Users/xxxx/sounds/img1.jpg' }
%                (the semicolumn above is optional)
%
%  'gInfo'     - [struct] general information fields. See BIDS specifications.
%                For example.
%                info.ReferencesAndLinks = { 'Pubmed 122032020' };
%                info.Name = 'This is a custom task';
%                info.License = 'Creative commons';
%
%  'tInfo'     - [struct] task information fields. See BIDS specifications.
%                For example.
%                tInfo.InstitutionAddress = '9500 Gilman Drive, CA92093-0559 La Jolla, USA';
%                tInfo.InstitutionName = 'Univesity of California, San Diego';
%                tInfo.InstitutionalDepartmentName = 'Institute of Neural Computation';
%                tInfo.PowerLineFrequency = 50;
%                tInfo.SoftwareFilters = struct('NotchFilter', struct('cutof', '50 (Hz)'));
%
%  'pInfo'     - [cell] cell array of participant values, with one row
%                per participants. The first row contains columns names.
%                For example for 2 participants:
%                { 'participant_id' 'sex'     'age';
%                  'control01'      'male'     20;
%                  'control02'      'female'   25 };
%                The columns above are optional and an arbitrary number of custom columns may
%                also be specified. When 'participant_id' is specified, it will be used for
%                naming subject folders (folders names and file prefix will be sub-<label>,
%                <label> being the participant ID).
%
%  'pInfoDesc' - [struct] structure describing participant file columns.
%                The fields are described in the BIDS format.
%                For example
%                pInfo.participant_id.LongName = 'Participant ID';
%                pInfo.participant_id.Description = 'Event onset';
%                pInfo.sex.LongName = 'Gender';
%                pInfo.sex.Description = 'Gender';
%                pInfo.age.LongName = 'Age';
%                pInfo.age.Description = 'Age in years';
%
%  'eInfo'     - [cell] additional event information columns and their corresponding
%                event fields in the EEGLAB event structure. Note that
%                EEGLAB event latency, duration, and type are inserted
%                automatically as columns "onset" (latency in sec), "duration"
%                (duration in sec), "value" (EEGLAB event type). For example 
%                { 'HED' 'usertag';
%                  'value' 'type' }
%                See also 'trial_type parameter.
%
%  'eInfoDesc' - [struct] structure describing additional or/and original
%                event fields if you wish to redefine these.
%                These are EEGLAB event fields listed above.
%                See the BIDS format for more information
%                eInfo.onset.LongName = 'Event onset'; % change default value
%                eInfo.onset.Description = 'Event onset';
%                eInfo.onset.Units = 'seconds';
%                eInfo.HED.LongName = 'Hierarchival Event Descriptors';
%                eInfo.reaction_time.LongName = 'Reaction time';
%                eInfo.reaction_time.Units = 'seconds';
%
%  'cInfo'     - [cell] cell array containing the field names for the
%                channel file in addition to the channel "name", "type" and
%                "unit" which are extracted from the channel location
%                structure. For example, to add the reference as an
%                additional column:
%                {'reference';
%                 'ref' }
%
%  'cInfoDesc' - [struct] structure describing additional or/and original
%                channel fields if you wish to redefine these.
%                cInfo.name.LongName = 'Channel name'; % change default description
%                cInfo.name.Description = 'Channel name';
%                cInfo.reference.LongName = 'Channel reference';
%                cInfo.reference.Description = 'Channel reference montage 10/20';
%
%  'trialtype' - [cell] 2 column cell table indicating the type of event
%                for each event type. For example { '2'    'stimulus';
%                                                   '4'    'stimulus';
%                                                   '128'  'response' }
%
%  'anattype'  - [string] type of anatomical MRI image ('T1w', 'T2w', etc...)
%                see BIDS specification for more information.
%
%  'defaced'   - ['on'|'off'] indicate if the MRI image is defaced or not.
%                Default is 'on'.
%
%  'chanlocs'  - [struct or file name] channel location structure or file
%                name to use when saving channel information. Note that
%                this assumes that all the files have the same number of
%                channels.
%
% 'copydata'   -[0|1] While exporting EEGLAB data to BIDS (.set, .fdt), this flag
%               will enable the copy of all the data files [1], or just create the
%               BIDS files hierarchy without the large data files [0]. This
%               options is aimed to be used to speedup the troubleshooting
%               of bids_export execution. Default: [1]
%
% Validation:
%  If the BIDS data created with this function fails to pass the BIDS
%  validator (npm install -g https://github.com/bids-standard/bids-validator.git
%  Usage bids-validator/bin/bids-validator --bep006 bidsfolder), please
%  email eeglab@sccn.ucsd.edu
%
% Example: The following examples will pass the bids validator.
% data(1).file = 'subject1.set'; data(1).run  = 1; data(1).session = 1;
% data(2).file = 'subject2.set'; data(2).run  = 1; data(2).session = 1;
% bids_export(data);
%
% Note that important information might be missing. For example, line noise
% is set to 0. Use input 'tInfo' to set the line noise as below.
%
% bids_export( data, 'tInfo', struct('PowerLineFrequency', 50 );
%
% In general, you will want to describe your events and include as much
% information as possible. A detailed and comprehensive example is provided
% in bids_export_example.m
%
%
% Authors: Arnaud Delorme, 2019
%          Ramon Martinez-Cancino, 2019

%  The following are automatically
%                populated using channel structure info ('eeg', 'ecg', 'emg', 'eog', 'trigger')
%                tInfo.ECGChannelCount = xxx;
%                tInfo.EEGChannelCount = xxx;
%                tInfo.EMGChannelCount = xxx;
%                tInfo.EOGChannelCount = xxx;
%                tInfo.MiscChannelCount = xxx;
%                tInfo.TriggerChannelCount = xxx;
%                tInfo.EEGReference = xxx;
%                tInfo.EpochLength = xxx;
%                tInfo.RecordingDuration = xxx;
%                tInfo.SamplingFrequency = xxx;
%                tInfo.TaskName = 'meditation';
%                However, they may be overwritten man.

function bids_export(files, varargin)

if nargin < 1
    help bids_format_eeglab;
    return
end
if ~exist('jsonwrite')
    addpath(fullfile(fileparts(which(mfilename)), 'JSONio'));
end

opt = finputcheck(varargin, {
    'Name'      'string'  {}    '';
    'License'   'string'  {}    '';
    'Authors'   'cell'    {}    {''};
    'ReferencesAndLinks' 'cell' {}    {''};
    'targetdir' 'string'  {}    fullfile(pwd, 'bidsexport');
    'taskName'  'string'  {}    'Experiment';
    'codefiles' 'cell'    {}    {};
    'stimuli'   'cell'    {}    {};
    'pInfo'     'cell'    {}    {};
    'eInfo'     'cell'    {}    {};
    'cInfo'     'cell'    {}    {};
    'gInfo'     'struct'  {}    struct([]);
    'tInfo'     'struct'  {}    struct([]);
    'pInfoDesc' 'struct'  {}    struct([]);
    'eInfoDesc' 'struct'  {}    struct([]);
    'cInfoDesc' 'struct'  {}    struct([]);
    'trialtype' 'cell'    {}    {};
    'chanlocs'  ''        {}    '';
    'anattype'  ''        {}    'T1w';
    'defaced'   'string'  {'on' 'off'}    'on';
    'README'    'string'  {}    '';
    'CHANGES'   'string'  {}    '' ;
    'copydata'   'real'   [0 1] 1 }, 'bids_export');
if isstr(opt), error(opt); end
if size(opt.stimuli,1) == 1 || size(opt.stimuli,1) == 1
    opt.stimuli = reshape(opt.stimuli, [2 length(opt.stimuli)/2])';
end

% deleting folder
fprintf('Exporting data to %s...\n', opt.targetdir);
if exist(opt.targetdir,'dir')
    disp('Deleting folder...')
    %rmdir(opt.targetdir, 's');
end

disp('Creating sub-directories...')
mkdir( fullfile(opt.targetdir, 'code'));
mkdir( fullfile(opt.targetdir, 'stimuli'));

% write dataset info (dataset_description.json)
% ---------------------------------------------
gInfoFields = { 'ReferencesAndLinks' 'required' 'cell' { 'n/a' };
    'Name'               'required' 'char' '';
    'License'            'required' 'char' 'CC0';
    'BIDSVersion'        'required' 'char' '1.1.1' ;
    'Authors'            'optional' 'cell' { 'n/a' };
    'Acknowledgements'   'optional' 'char' '';
    'HowToAcknowledge'   'optional' 'char' '';
    'Funding'            'optional' 'cell' { 'n/a' };
    'DatasetDOI'         'optional' 'char' { 'n/a' }};

if ~isfield(opt.gInfo, 'Name'), opt.gInfo(1).Name = opt.Name; end
if ~isfield(opt.gInfo, 'License'), opt.gInfo.License = opt.License; end
if ~isfield(opt.gInfo, 'Authors'), opt.gInfo.Authors = opt.Authors; end
if ~isfield(opt.gInfo, 'ReferencesAndLinks'), opt.gInfo.ReferencesAndLinks = opt.ReferencesAndLinks; end

opt.gInfo = checkfields(opt.gInfo, gInfoFields, 'gInfo');
jsonwrite(fullfile(opt.targetdir, 'dataset_description.json'), opt.gInfo, struct('indent','  '));

% make cell out of file names if necessary
% ----------------------------------------
for iSubj = 1:length(files)
    if ~iscell(files(iSubj).file)
        if isstruct(files(iSubj).file)
            if isfield(files(iSubj).file, 'session')
                files(iSubj).session  = [ files(iSubj).file.session  ];
            end
            if isfield(files(iSubj).file, 'run')
                files(iSubj).run      = [ files(iSubj).file.run  ];
            end
            if isfield(files(iSubj).file, 'task')
                files(iSubj).task      = { files(iSubj).file.task  };
            end
            if isfield(files(iSubj).file, 'instructions')
                files(iSubj).task      = { files(iSubj).file.instructions };
            end
            files(iSubj).file     = { files(iSubj).file.file };
        else
            files(iSubj).file = { files(iSubj).file };
        end
    end
    
    % channel location
    if isfield(files(iSubj), 'chanlocs')
        if ~iscell(files(iSubj).chanlocs)
            files(iSubj).chanlocs = { files(iSubj).chanlocs };
        end
        if length(files(iSubj).chanlocs) ~= length(files(iSubj).file)
            if length(files(iSubj).chanlocs) == 1
                files(iSubj).chanlocs(1:length(files(iSubj).file)) = files(iSubj).chanlocs(1);
            else
                error('Length of channel list must be the same size as the number of file for each participant');
            end
        end
    end
    
    % run and sessions
    if ~isfield(files(iSubj), 'run') || isempty(files(iSubj).run)
        files(iSubj).run = ones(1, length(files(iSubj).file));
    end
    if ~isfield(files(iSubj), 'session') || isempty(files(iSubj).session)
        files(iSubj).session = ones(1, length(files(iSubj).file));
    end
    
    % check that no two files have the same session/run
    if length(files(iSubj).run) ~= length(files(iSubj).session)
        error(sprintf('Length of session and run differ for subject %s', iSubj));
    else
        uniq = files(iSubj).run*1000 + files(iSubj).session;
        if length(uniq) ~= length(unique(uniq))
            error(sprintf('Subject %s does not have unique session and runs for each file', iSubj));
        end
    end
end

% write participant information (participants.tsv)
% -----------------------------------------------
if ~isempty(opt.pInfo)
    if isfield(files, 'subject')
        uniqueSubject = unique( { files.subject } );
        if size(opt.pInfo,1)-1 ~= length( uniqueSubject )
            error(sprintf('Wrong number of participant (%d) in pInfo structure, should be %d based on the number of files', size(opt.pInfo,1)-1, length( uniqueSubject )));
        end
    elseif ~isstruct(files(1).file)
        if size(opt.pInfo,1)-1 ~= length( files )
            error(sprintf('Wrong number of participant (%d) in pInfo structure, should be %d based on the number of files', size(opt.pInfo,1)-1, length( files )));
        end
    end
    participants = { 'participant_id' };
    for iSubj=2:size(opt.pInfo)
        if strcmp('participant_id', opt.pInfo{1,1})
            if length(opt.pInfo{iSubj,1}) > 3 && isequal('sub-', opt.pInfo{iSubj,1}(1:4))
                participants{iSubj, 1} = opt.pInfo{iSubj,1};
            else
                participants{iSubj, 1} = sprintf('sub-%s', opt.pInfo{iSubj,1});
            end
        else
            participants{iSubj, 1} = sprintf('sub-%3.3d', iSubj-1);
        end
    end
    if strcmp('participant_id', opt.pInfo{1,1})
        opt.pInfo = opt.pInfo(:,2:end);
    end
    participants(:,2:2+size(opt.pInfo,2)-1) = opt.pInfo;
    
    writetsv(fullfile(opt.targetdir, 'participants.tsv'), participants);
end

% write participants field description (participants.json)
% --------------------------------------------------------
descFields = { 'LongName'     'optional' 'char'   '';
    'Levels'       'optional' 'struct' struct([]);
    'Description'  'optional' 'char'   '';
    'Units'        'optional' 'char'   '';
    'TermURL'      'optional' 'char'   '' };
if ~isempty(opt.pInfo)
    fields = fieldnames(opt.pInfoDesc);
    if ~isempty(setdiff(fields, participants(1,:)))
        error('Some field names in the pInfoDec structure do not have a corresponding column name in pInfo');
    end
    fields = participants(1,:);
    for iField = 1:length(fields)
        descFields{1,4} = fields{iField};
        if ~isfield(opt.pInfoDesc, fields{iField}), opt.pInfoDesc(1).(fields{iField}) = struct([]); end
        opt.pInfoDesc.(fields{iField}) = checkfields(opt.pInfoDesc.(fields{iField}), descFields, 'pInfoDesc');
    end
    jsonwrite(fullfile(opt.targetdir, 'participants.json'), opt.pInfoDesc,struct('indent','  '));
end

% prepare event file information (_events.json)
% ----------------------------
fields = fieldnames(opt.eInfoDesc);
for iField = 1:length(fields)
    descFields{1,4} = fields{iField};
    if ~isfield(opt.eInfoDesc, fields{iField}), opt.eInfoDesc(1).(fields{iField}) = struct([]); end
    opt.eInfoDesc.(fields{iField}) = checkfields(opt.eInfoDesc.(fields{iField}), descFields, 'eInfoDesc');
end

% Write README files (README)
% ---------------------------
if ~isempty(opt.README)
    if ~exist(opt.README)
        fid = fopen(fullfile(opt.targetdir, 'README'), 'w');
        if fid == -1, error('Cannot write README file'); end
        fprintf(fid, '%s', opt.README);
        fclose(fid);
    else
        copyfile(opt.README, fullfile(opt.targetdir, 'README'));
    end
end

% Write CHANGES files (CHANGES)
% -----------------------------
if ~isempty(opt.CHANGES)
    if ~exist(opt.CHANGES)
        fid = fopen(fullfile(opt.targetdir, 'CHANGES'), 'w');
        if fid == -1, error('Cannot write README file'); end
        fprintf(fid, '%s', opt.CHANGES);
        fclose(fid);
    else
        copyfile(opt.CHANGES, fullfile(opt.targetdir, 'CHANGES'));
    end
end

% Write code files (code)
% -----------------------
if ~isempty(opt.codefiles)
    for iFile = 1:length(opt.codefiles)
        [~,fileName,Ext] = fileparts(opt.codefiles{iFile});
        if ~isempty(dir(opt.codefiles{iFile}))
            copyfile(opt.codefiles{iFile}, fullfile(opt.targetdir, 'code', [ fileName Ext ]));
        else
            fprintf('Warning: cannot find code file %s\n', opt.codefiles{iFile})
        end
    end
end

% Write stimulus files
% --------------------
if ~isempty(opt.stimuli)
    if size(opt.stimuli,1) == 1, opt.stimuli = opt.stimuli'; end
    disp('Copying images...');
    for iStim = 1:size(opt.stimuli,1)
        [~,fileName,Ext] = fileparts(opt.stimuli{iStim,1});
        if ~isempty(dir(opt.stimuli{iStim,1}))
            copyfile(opt.stimuli{iStim,1}, fullfile(opt.targetdir, 'stimuli', [ fileName Ext ]));
        else
            fprintf('Warning: cannot find stimulus file %s\n', opt.codefiles{iFile});
        end
    end
end

% check task info
% ---------------
opt.tInfo(1).TaskName = opt.taskName;

% load channel information
% ------------------------
chanlocs = {};
if ~isempty(opt.chanlocs) && isstr(opt.chanlocs)
    opt.chanlocs = readlocs(opt.chanlocs);
end
if ~isfield(files(1), 'chanlocs')
    for iSubj = 1:length(files)
        for iFile = 1:length(files(iSubj).file)
            files(iSubj).chanlocs{iFile} = opt.chanlocs;
        end
    end
end

% Heuristic for identifying multiple/single-run/sessions
%--------------------------------------------------------------------------
for iSubj = 1:length(files)
    allsubjnruns(iSubj)    = length(unique(files(iSubj).run));
    allsubjnsessions(iSubj) = length(unique(files(iSubj).session));
end
tmpuniqueruns = unique(allsubjnruns);
tmpuniquesessions = unique(allsubjnsessions);

multsessionflag = 1;
if length(tmpuniquesessions) == 1 && tmpuniquesessions == 1
    multsessionflag = 0;
end

multrunflag = 1;
if length(tmpuniqueruns) == 1 && tmpuniqueruns == 1
    multrunflag = 0;
end

tmpsessrun = [multsessionflag multrunflag];
if all(tmpsessrun == [0 0])    % Single-Session Single-Run
    bidscase = 1';
elseif all(tmpsessrun == [0 1]) % Single-Session Mult-Run
    bidscase = 2';
elseif all(tmpsessrun == [1 0]) % Mult-Session Single-Run
    bidscase = 3;
elseif all(tmpsessrun == [1 1]) % Mult-Session Mult-Run
    bidscase = 4;
end
%--------------------------------------------------------------------------
% copy EEG files
% --------------
disp('Copying EEG files...')
for iSubj = 1:length(files)
    if ~isempty(opt.pInfo)
        subjectStr = participants{iSubj+1,1}; % first row of participants contains header
    else
        subjectStr    = sprintf('sub-%3.3d', iSubj);
    end
    
    % copy anatomical file if any
    if isfield(files(iSubj), 'anat') && ~isempty(files(iSubj).anat)
        mkdir(fullfile(opt.targetdir, subjectStr, 'anat'));
        
        % Currently supporting Single-Session Single-Run of MRI anat only.
        % If interested in other combinations of run/sessions please contact the authors.
        fileOut = fullfile(opt.targetdir, subjectStr, 'anat', [ subjectStr '_mod-' opt.anattype ]);
         
        if strcmpi(opt.defaced, 'on')
            fileOut = [ fileOut '_defacemask' ];
        end
        if files(iSubj).anat(end) == 'z'
            fileOut = [ fileOut '.nii.gz' ];
        else
            fileOut = [ fileOut '.nii' ];
        end
        copyfile(files(iSubj).anat, fileOut);
    end
    
    switch bidscase
        case 1 % Single-Session Single-Run
            
            fileOut = fullfile(opt.targetdir, subjectStr, 'eeg', [ subjectStr '_task-' opt.taskName '_eeg' files(iSubj).file{1}(end-3:end)]);
            %             copy_data_bids( files(iSubj).file{1}, fileOut, opt.eInfo, opt.tInfo, opt.trialtype, chanlocs{iSubj}, opt.copydata);
            copy_data_bids( files(iSubj).file{1}, fileOut, opt, files(iSubj).chanlocs{1}, opt.copydata);
            
        case 2 % Single-Session Mult-Run
            
            for iRun = 1:length(files(iSubj).run)
                fileOut = fullfile(opt.targetdir, subjectStr, 'eeg', [ subjectStr  '_task-' opt.taskName sprintf('_run-%2.2d', iRun) '_eeg' files(iSubj).file{iRun}(end-3:end) ]);
                copy_data_bids( files(iSubj).file{iRun}, fileOut, opt, files(iSubj).chanlocs{iRun}, opt.copydata);
            end
            
        case 3 % Mult-Session Single-Run
            
            for iSess = 1:length(unique(files(iSubj).session))
                fileOut = fullfile(opt.targetdir, subjectStr, sprintf('ses-%2.2d', iSess), 'eeg', [ subjectStr sprintf('_ses-%2.2d', iSess) '_task-' opt.taskName '_eeg' files(iSubj).file{iSess}(end-3:end)]);
                copy_data_bids( files(iSubj).file{iSess}, fileOut, opt, files(iSubj).chanlocs{iSess}, opt.copydata);
            end
            
        case 4 % Mult-Session Mult-Run
            
            for iSess = 1:length(unique(files(iSubj).session))
                runindx = find(files(iSubj).session == iSess);
                for iSet = runindx
                    iRun = files(iSubj).run(iSet);
                    fileOut = fullfile(opt.targetdir, subjectStr, sprintf('ses-%2.2d', iSess), 'eeg', [ subjectStr sprintf('_ses-%2.2d', iSess) '_task-' opt.taskName  sprintf('_run-%2.2d', iRun) '_eeg' files(iSubj).file{iSet}(end-3:end)]);
                    copy_data_bids(files(iSubj).file{iSet}, fileOut, opt, files(iSubj).chanlocs{iSet}, opt.copydata);
                end
            end
    end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%function copy_data_bids(fileIn, fileOut, eInfo, tInfo, trialtype, chanlocs, copydata)
function copy_data_bids(fileIn, fileOut, opt, chanlocs, copydata)
folderOut = fileparts(fileOut);
if ~exist(folderOut)
    mkdir(folderOut);
end
if ~exist(fileOut)
end

% if BDF file anonymize records
tInfo = opt.tInfo;
[~,~,ext] = fileparts(fileOut);
if strcmpi(ext, '.bdf')
    fileIDIn  = fopen(fileIn,'rb','ieee-le');  % see sopen
    fileIDOut = fopen(fileOut,'wb','ieee-le');  % see sopen
    data = fread(fileIDIn, Inf);
    data(9:9+160-1) = ' '; % remove potential identity
    fwrite(fileIDOut, data);
    fclose(fileIDIn);
    fclose(fileIDOut);
    tInfo.EEGReference = 'CMS/DRL';
    tInfo.Manufacturer = 'BIOSEMI';
    EEG = pop_biosig(fileOut);
elseif strcmpi(ext, '.set')
    [outfilepath, outfilename,outfileext] = fileparts(fileOut);
    if copydata
        EEGin = pop_loadset(fileIn);
        EEG   = pop_saveset(EEGin, 'filename',[outfilename outfileext], 'filepath', outfilepath);
    else
        copyfile(fileIn, fileOut);
        EEG = pop_loadset([outfilename outfileext],outfilepath, 'loadmode', 'info');
    end
elseif strcmpi(ext, '.cnt')
    EEG = pop_loadcnt(fileIn, 'dataformat', 'int16');
    pop_saveset(EEG, 'filename', fileOut);
elseif strcmpi(ext, '.mff')
    EEG = pop_mffimport(fileIn,{'code'});
    pop_saveset(EEG, 'filename', fileOut);
elseif strcmpi(ext, '.raw')
    EEG = pop_readegi(fileIn);
    pop_saveset(EEG, 'filename', fileOut);
else
    error('Data format not supported');
end

% Getting events latency
insertEpoch = false;
if EEG.trials > 1
    % get TLE events
    insertEpoch = true;
    eventlat = abs(eeg_point2lat( [ EEG.event.latency ], [ EEG.event.epoch ], EEG.srate, [EEG.xmin EEG.xmax]));
    indtle    = find(eventlat == 0);
    if length(indtle) < EEG.trials
        indtle    = find(eventlat < 0.02);
    end
    if length(indtle) ~= EEG.trials
        insertEpoch = false;
    end
end

% write event file information
% --- _events.json
jsonwrite([ fileOut(1:end-7) 'events.json' ], opt.eInfoDesc,struct('indent','  '));

% --- _events.tsv
fid = fopen( [ fileOut(1:end-7) 'events.tsv' ], 'w');

% -- parse eInfo
if isempty(opt.eInfo)
    opt.eInfo                                                  = { 'onset'         'latency' };
    if isfield(EEG.event, 'trial_type')     opt.eInfo(end+1,:) = { 'trial_type'    'trial_type' };
    elseif ~isempty(opt.trialtype)          opt.eInfo(end+1,:) = { 'trial_type'    'xxxx' }; end % to be filled with event type based on opt.trialtype mapping
    if isfield(EEG.event, 'duration')       opt.eInfo(end+1,:) = { 'duration'      'duration' }; end
    if isfield(EEG.event, 'value')          opt.eInfo(end+1,:) = { 'value'         'value' };
    else                                    opt.eInfo(end+1,:) = { 'value'         'type' }; end
    if isfield(EEG.event, 'response_time'), opt.eInfo(end+1,:) = { 'response_time' 'response_time' }; end
    if isfield(EEG.event, 'stim_file'),     opt.eInfo(end+1,:) = { 'stim_file'     'stim_file' }; end
    if isfield(EEG.event, 'usertags'),      opt.eInfo(end+1,:) = { 'HED'           'on' }; end
        
end

% reorder fields so it matches BIDS
fieldOrder = { 'onset' 'duration' 'sample' 'trial_type' 'response_time' 'stim_file' 'value' 'HED' };
newOrder = [];
for iField = 1:length(fieldOrder)
    ind = strmatch(fieldOrder{iField}, opt.eInfo(:,1)', 'exact');
    if isempty(ind)
        opt.eInfo(end+1,1:2) = { fieldOrder{iField} 'n/a' };
        ind = size(opt.eInfo,1);
    end
    newOrder = [ newOrder ind ];
end
remainingInd = setdiff([1:size(opt.eInfo,1)], newOrder);
newOrder = [ newOrder remainingInd];
opt.eInfo = opt.eInfo(newOrder,:);
fprintf(fid,'onset%s\n', sprintf('\t%s', opt.eInfo{2:end,1}));

% scan events
for iEvent = 1:length(EEG.event)
    
    for iField = 1:size(opt.eInfo,1)
        
        tmpField = opt.eInfo{iField,2};
        if strcmpi(tmpField, 'n/a')
            fprintf(fid, '\t%s', tmpField);
        else            
            switch opt.eInfo{iField,1}

                case 'onset'
                    onset = (EEG.event(iEvent).(tmpField)-1)/EEG.srate;
                    fprintf(fid, '%1.10f', onset);

                case 'duration'
                    if isfield(EEG.event, tmpField) && ~isempty(EEG.event(iEvent).(tmpField))
                        duration = num2str(EEG.event(iEvent).(tmpField), '%1.10f');
                    else
                        duration = 'n/a';
                    end
                    if isempty(duration) || strcmpi(duration, 'NaN')
                        duration = 'n/a';
                    end
                    fprintf(fid, '\t%s', duration);

                case 'sample'
                    if isfield(EEG.event, tmpField)
                        sample = num2str(EEG.event(iEvent).(tmpField));
                    else
                        sample = 'n/a';
                    end
                    if isempty(sample) || strcmpi(sample, 'NaN')
                        sample = 'n/a';
                    end
                    fprintf(fid, '\t%s', sample);

                case 'trial_type'
                    % trial type (which is the experimental condition - not the same as EEGLAB)
                    if isfield(EEG.event(iEvent), tmpField) && ~isempty(EEG.event(iEvent).(tmpField))
                        trialType = EEG.event(iEvent).(tmpField);
                    else
                        trialType = 'STATUS';
    %                     if ~isempty(EEG.event(iEvent).(tmpField))
    %                         eventVal = EEG.event(iEvent).(tmpField);
    %                     else
                            eventVal = EEG.event(iEvent).type;
    %                     end
                        if ~isempty(opt.trialtype)
                            % mapping on event value
                            if ~isempty(eventVal)
                                %indTrial = strmatch(eventVal, opt.trialtype(:,1), 'exact');
                                stim_vals = opt.trialtype(:,1); % try this for numeric eventVals?
                                indTrial = find([stim_vals{:}]==eventVal);
                                if ~isempty(indTrial)
                                    trialType = opt.trialtype{indTrial,2};
                                end
                            end
                        end
                        if insertEpoch
                            if any(indtle == iEvent)
                                trialType = 'Epoch';
                            end
                        end
                    end
                    if isnumeric(trialType)
                        trialType = num2str(trialType);
                    end
                    fprintf(fid, '\t%s', trialType);

                case 'response_time'
                    if isfield(EEG.event, tmpField)
                        response_time = num2str(EEG.event(iEvent).(tmpField));
                    else
                        response_time = 'n/a';
                    end
                    if isempty(response_time) || strcmpi(response_time, 'NaN')
                        response_time = 'n/a';
                    end
                    fprintf(fid, '\t%s', response_time);

                case 'stim_file'
                    if isfield(EEG.event, tmpField)
                        stim_file = num2str(EEG.event(iEvent).(tmpField));
                    else
                        stim_file = 'n/a';
                    end
                    if isempty(stim_file) || strcmpi(stim_file, 'NaN')
                        stim_file = 'n/a';
                    end
                    fprintf(fid, '\t%s', stim_file);

                case 'value'
                    if  isfield(EEG.event, tmpField) && ~isempty(EEG.event(iEvent).(tmpField))
                        eventValue = num2str(EEG.event(iEvent).(tmpField));
                    else
                        eventValue = 'n/a';
                    end
                    if isequal(eventValue, 'NaN') || isempty(eventValue)
                        eventValue = 'n/a';
                    end
                    fprintf(fid, '\t%s', eventValue);

                case 'HED'
                    hed = 'n/a';
                    if isfield(EEG.event, tmpField) && ~isempty(EEG.event(iEvent).(tmpField))
                        hed = EEG.event(iEvent).(tmpField);
                    else
                        if isfield(EEG.event, 'usertags') && ~isempty(EEG.event(iEvent).usertags)
                            hed = EEG.event(iEvent).usertags;
                            if isfield(EEG.event, 'hedtags') && ~isempty(EEG.event(iEvent).hedtags)
                                hed = [hed ',' EEG.event(iEvent).hedtags];
                            end
                        elseif isfield(EEG.event, 'hedtags') && ~isempty(EEG.event(iEvent).hedtags)
                            hed = EEG.event(iEvent).hedtags;
                        end
                    end
                    fprintf(fid, '\t%s', hed);

                otherwise
                    if isfield(EEG.event, opt.eInfo{iField,2})
                        tmpVal = num2str(EEG.event(iEvent).(opt.eInfo{iField,2}));
                    else
                        tmpVal = 'n/a';
                    end
                    fprintf(fid, '\t%s', tmpVal);
            end % switch
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);

% Write channel file information (channels.tsv)
% Note: Consider using here electrodes_to_tsv.m
fid = fopen( [ fileOut(1:end-7) 'channels.tsv' ], 'w');
miscChannels = 0;

if ~isempty(chanlocs)
    EEG.chanlocs = chanlocs;
    if isstr(chanlocs)
        EEG.chanlocs = readlocs(EEG.chanlocs);
    end
    EEG = eeg_checkchanlocs(EEG);
    if length(EEG.chanlocs) == EEG.nbchan+1
        for iChan = 1:length(EEG.chanlocs)
            EEG.chanlocs(iChan).ref = EEG.chanlocs(end).labels;
        end
    elseif length(EEG.chanlocs) ~= EEG.nbchan
        error(sprintf('Number of channels in channel location inconsistent with data for file %s', fileIn));
    end
end

if isempty(EEG.chanlocs)
    fprintf(fid, 'name\ttype\tunits\n');
    for iChan = 1:EEG.nbchan, fprintf(fid, 'E%d\tEEG\tmicroV\n', iChan); end
else
    fprintf(fid, 'name\ttype\tunits\n');
    
    for iChan = 1:EEG.nbchan
        if ~isfield(EEG.chanlocs, 'type') || isempty(EEG.chanlocs(iChan).type)
            type = 'n/a';
        else
            type = EEG.chanlocs(iChan).type;
        end
        if strcmpi(type, 'eeg')
            unit = 'microV';
        else
            unit = 'n/a';
            miscChannels = miscChannels+1;
        end
        
        fprintf(fid, '%s\t%s\t%s\n', EEG.chanlocs(iChan).labels, type, unit);
    end
end
fclose(fid);

% Write electrode file information (electrodes.tsv)
if ~isempty(EEG.chanlocs) && isfield(EEG.chanlocs, 'X') && ~isempty(EEG.chanlocs(2).X)
    fid = fopen( [ fileOut(1:end-7) 'electrodes.tsv' ], 'w');
    fprintf(fid, 'name\tx\ty\tz\n');
    
    for iChan = 1:EEG.nbchan
        if isempty(EEG.chanlocs(iChan).X)
            fprintf(fid, '%s\tn/a\tn/a\tn/a\n', EEG.chanlocs(iChan).labels );
        else
            fprintf(fid, '%s\t%2.2f\t%2.2f\t%2.2f\n', EEG.chanlocs(iChan).labels, EEG.chanlocs(iChan).X, EEG.chanlocs(iChan).Y, EEG.chanlocs(iChan).Z );
        end
    end
    fclose(fid);
    
    % Write coordinate file information (coordsystem.json)
    coordsystemStruct.EEGCoordinateUnits = 'mm';
    coordsystemStruct.EEGCoordinateSystem = 'ARS'; % X=Anterior Y=Right Z=Superior
    writejson( [ fileOut(1:end-7) 'coordsystem.json' ], coordsystemStruct);
end

% Write task information (eeg.json) Note: depends on channels
tInfo.EEGChannelCount = EEG.nbchan-miscChannels;
if miscChannels > 0
    tInfo.MiscChannelCount  = miscChannels;
end
if ~isfield(tInfo, 'EEGReference')
    if ~ischar(EEG.ref) && numel(EEG.ref) > 1 % untested for all cases
        refChanLocs = EEG.chanlocs(EEG.ref);
        ref = join({refChanLocs.labels},',');
        ref = ref{1};
    else
        ref = EEG.ref;
    end
    tInfo.EEGReference    = ref;
end
if EEG.trials == 1
    tInfo.RecordingType = 'continuous';
else
    tInfo.RecordingType = 'epoched';
    tInfo.EpochLength = EEG.pnts/EEG.srate;
end
tInfo.RecordingDuration = EEG.pnts/EEG.srate;
tInfo.SamplingFrequency = EEG.srate;
%     jsonStr = jsonencode(tInfo);
%     fid = fopen( [fileOut(1:end-7) 'eeg.json' ], 'w');
%     fprintf(fid, '%s', jsonStr);
%     fclose(fid);

tInfoFields = {...
    'TaskName' 'REQUIRED' '' '';
    'TaskDescription' 'RECOMMENDED' '' '';
    'Instructions' 'RECOMMENDED' 'char' '';
    'CogAtlasID' 'RECOMMENDED' 'char' '';
    'CogPOID' 'RECOMMENDED' 'char' '';
    'InstitutionName' 'RECOMMENDED' 'char' '';
    'InstitutionAddress' 'RECOMMENDED' 'char' '';
    'InstitutionalDepartmentName' ' RECOMMENDED' 'char' '';
    'DeviceSerialNumber' 'RECOMMENDED' 'char' '';
    'SamplingFrequency' 'REQUIRED' '' '';
    'EEGChannelCount' 'REQUIRED' '' '';
    'EOGChannelCount' 'REQUIRED' '' 0;
    'ECGChannelCount' 'REQUIRED' '' 0;
    'EMGChannelCount' 'REQUIRED' '' 0;
    'EEGReference' 'REQUIRED' 'char' 'Unknown';
    'PowerLineFrequency' 'REQUIRED' '' 0;
    'EEGGround' 'RECOMMENDED ' 'char' '';
    'HeadCircumference' 'OPTIONAL ' '' 0;
    'MiscChannelCount' ' OPTIONAL' '' '';
    'TriggerChannelCount' 'RECOMMENDED' 'char' '';
    'EEGPlacementScheme' 'RECOMMENDED' 'char' '';
    'Manufacturer' 'RECOMMENDED' 'char' '';
    'ManufacturersModelName' 'OPTIONAL' 'char' '';
    'CapManufacturer' 'RECOMMENDED' 'char' 'Unknown';
    'CapManufacturersModelName' 'OPTIONAL' 'char' '';
    'HardwareFilters' 'OPTIONAL' 'struct' struct([]);
    'SoftwareFilters' 'REQUIRED' 'struct' 'n/a';
    'RecordingDuration' 'RECOMMENDED' '' 'n/a';
    'RecordingType' 'RECOMMENDED' 'char' '';
    'EpochLength' 'RECOMMENDED' '' 'n/a';
    'SoftwareVersions' 'RECOMMENDED' 'char' '';
    'SubjectArtefactDescription' 'OPTIONAL' 'char' '' };
tInfo = checkfields(tInfo, tInfoFields, 'tInfo');

jsonwrite([fileOut(1:end-7) 'eeg.json' ], tInfo,struct('indent','  '));

% write channel information
%     cInfo.name.LongName = 'Channel name';
%     cInfo.name.Description = 'Channel name';
%     cInfo.type.LongName = 'Channel type';
%     cInfo.type.Description = 'Channel type';
%     cInfo.units.LongName = 'Channel unit';
%     cInfo.units.Description = 'Channel unit';
%     jsonStr = jsonencode(cInfo);
%     fid = fopen( [fileOut(1:end-7) 'channels.json' ], 'w');
%     fprintf(fid, '%s', jsonStr);
%     fclose(fid);

% check the fields for the structures
% -----------------------------------
function s = checkfields(s, f, structName)

fields = fieldnames(s);
diffFields = setdiff(fields, f(:,1)');
if ~isempty(diffFields)
    error(sprintf('Invalid field name(s) %sfor structure %s', sprintf('%s ',diffFields{:}), structName));
end
for iRow = 1:size(f,1)
    if isempty(s) || ~isfield(s, f{iRow,1})
        if strcmpi(f{iRow,2}, 'required') % required or optional
            if ~iscell(f{iRow,4})
                fprintf('Warning: "%s" set to %s\n', f{iRow,1}, num2str(f{iRow,4}));
            end
            s = setfield(s, {1}, f{iRow,1}, f{iRow,4});
        end
    elseif ~isempty(f{iRow,3}) && ~isa(s.(f{iRow,1}), f{iRow,3}) && ~strcmpi(s.(f{iRow,1}), 'n/a')
        error(sprintf('Parameter %s.%s must be a %s', structName, f{iRow,1}, f{iRow,3}));
    end
end

function printEventHeader(eInfo)
fields = eInfo{:,1};


% write JSON file
% ---------------
function writejson(fileName, matlabStruct)
jsonStr = jsonencode(matlabStruct);

fid = fopen(fileName, 'w');
if fid == -1, error('Cannot write file - make sure you have writing permission'); end
fprintf(fid, '%s', jsonStr);
fclose(fid);

% write TSV file
% --------------
function writetsv(fileName, matlabArray)
fid = fopen(fileName, 'w');
if fid == -1, error('Cannot write file - make sure you have writing permission'); end
for iRow=1:size(matlabArray,1)
    for iCol=1:size(matlabArray,2)
        if isempty(matlabArray{iRow,iCol})
            disp('Empty value detected, replacing by n/a');
            fprintf(fid, 'n/a');
        elseif ischar(matlabArray{iRow,iCol})
            fprintf(fid, '%s', matlabArray{iRow,iCol});
        elseif isnumeric(matlabArray{iRow,iCol}) && rem(matlabArray{iRow,iCol},1) == 0
            fprintf(fid, '%d', matlabArray{iRow,iCol});
        elseif isnumeric(matlabArray{iRow,iCol})
            fprintf(fid, '%1.10f', matlabArray{iRow,iCol});
        else
            error('Table values can only be string or numerical values');
        end
        if iCol ~= size(matlabArray,2)
            fprintf(fid, '\t');
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);
