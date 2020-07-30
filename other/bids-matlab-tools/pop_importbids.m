% pop_importbids() - Import BIDS format folder structure into an EEGLAB
%                    study.
% Usage:
%   >> [STUDY ALLEEG] = pop_importbids(bidsfolder);
%   >> [STUDY ALLEEG] = pop_importbids(bidsfolder, 'key', value);
%
% Inputs:
%   bidsfolder - a loaded epoched EEG dataset structure.
%     options are 'bidsevent', 'bidschanloc' of be turned 'on' (default) or 'off'
%                 'outputdir' default is bidsfolder/derivatives
%                 'studyName' default is eeg
%
% Optional inputs:
%  'studyName'   - [string] name of the STUDY
%  'bidsevent'   - ['on'|'off'] import events from BIDS .tsv file and
%                  ignore events in raw binary EEG files.
%  'bidschanloc' - ['on'|'off'] import channel location from BIDS .tsv file 
%                  and ignore locations (if any) in raw binary EEG files.  
%  'outputdir'   - [string] output folder (default is to use the BIDS
%                  folders).
%
% Authors: Arnaud Delorme, SCCN, INC, UCSD, January, 2019
%         Cyril Pernet, University of Edinburgh
%
% Example:
% pop_importbids('/data/matlab/bids_matlab/rishikesh_study/BIDS_EEG_meditation_experiment');

% Copyright (C) Arnaud Delorme, 2018
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [STUDY, ALLEEG, bids, commands] = pop_importbids(bidsFolder, varargin)

if nargin < 1
    bidsFolder = uigetdir('Pick a BIDS folder');
    if isequal(bidsFolder,0), return; end
        
    cb_select = [ 'tmpfolder = uigetdir;' ...
        'if ~isequal(tmpfolder, 0)' ...
        '   set(findobj(gcbf, ''tag'', ''folder''), ''string'', tmpfolder);' ...
        'end;' ...
        'clear tmpfolder;' ];
    
    promptstr    = { ...
        { 'style'  'text'       'string' 'Enter study name (default is BIDS folder name)' } ...
        { 'style'  'edit'       'string' '' 'tag' 'studyName' } ...
        { 'style'  'checkbox'  'string' 'Overwrite events with BIDS event files' 'tag' 'events' 'value' 0 } ...
        { 'style'  'checkbox'   'string' 'Overwrite channel locations with BIDS channel location files' 'tag' 'chanlocs' 'value' 0 } ...
        { 'style'  'text'       'string' 'Study output folder' } ...
        { 'style'  'edit'       'string' fullfile(bidsFolder, 'derivatives') 'tag' 'folder' 'HorizontalAlignment' 'left' } ...
        { 'style'  'pushbutton' 'string' '...' 'callback' cb_select } ...
        };
    geometry = {[2 1.5], 1,1,[1 2 0.5]};
    
    [~,~,~,res] = inputgui( 'geometry', geometry, 'uilist', promptstr, 'helpcom', 'pophelp(''pop_importbids'')', 'title', 'Import BIDS data -- pop_importbids()');
    if isempty(res), return; end
    
    options = { };
    if res.events,    options = { options{:} 'bidsevent' 'on' }; end
    if res.chanlocs,  options = { options{:} 'bidschanloc' 'on' }; end
    if ~isempty(res.folder),  options = { options{:} 'outputdir' res.folder }; end
    if ~isempty(res.studyName),  options = { options{:} 'studyName' res.studyName }; end
else
    options = varargin;
end

[~,defaultStudyName] = fileparts(bidsFolder);
opt = finputcheck(options, { ...
    'bidsevent'      'string'    { 'on' 'off' }    'on';  ...
    'bidschanloc'    'string'    { 'on' 'off' }    'on'; ...
    'outputdir'      'string'    { } fullfile(bidsFolder,'derivatives'); ...
    'studyName'      'string'    { }                defaultStudyName ...
    }, 'pop_importbids');
if isstr(opt), error(opt); end

% Options:
% - copy folder
% - use channel location and event

% load change file
changesFile = fullfile(bidsFolder, 'CHANGES');
bids.CHANGES = '';
if exist(changesFile,'File')
    bids.CHANGES = importalltxt( changesFile );
end

% load Readme file
readmeFile = fullfile(bidsFolder, 'README');
bids.README = '';
if exist(readmeFile,'File')
    bids.README = importalltxt( readmeFile );
end

% load dataset description file
dataset_descriptionFile = fullfile(bidsFolder, 'dataset_description.json');
bids.dataset_description = '';
if exist(dataset_descriptionFile,'File')
    bids.dataset_description = jsondecode(importalltxt( dataset_descriptionFile ));
end

% load participant file
participantsFile = fullfile(bidsFolder, 'participants.tsv');
bids.participants = '';
if exist(participantsFile,'File')
    bids.participants = importtsv( participantsFile );
end

% load participant file
participantsJSONFile = fullfile(bidsFolder, 'participants.json');
bids.participantsJSON = '';
if exist(participantsJSONFile,'File')
    bids.participantsJSON = jsondecode(importalltxt( participantsJSONFile ));
end

% scan participants
count = 1;
commands = {};
task = [ 'task-' bidsFolder ];
for iSubject = 1:size(bids.participants,1)
    
    parentSubjectFolder = fullfile(bidsFolder   , bids.participants{iSubject,1});
    outputSubjectFolder = fullfile(opt.outputdir, bids.participants{iSubject,1});
    
    % find folder containing eeg
    if exist(fullfile(parentSubjectFolder, 'eeg'),'dir')
        subjectFolder = { fullfile(parentSubjectFolder, 'eeg') };
        subjectFolderOut = { fullfile(outputSubjectFolder, 'eeg') };
    else
        subFolders = dir(fullfile(parentSubjectFolder, 'ses*'));
        subjectFolder    = {};
        subjectFolderOut = {};
        
        for iFold = 1:length(subFolders)
            subjectFolder{   iFold} = fullfile(parentSubjectFolder, subFolders(iFold).name, 'eeg');
            subjectFolderOut{iFold} = fullfile(outputSubjectFolder, subFolders(iFold).name, 'eeg');
        end
    end
    
    % import data
    for iFold = 1:length(subjectFolder)
        if ~exist(subjectFolder{iFold},'dir')
            error('No EEG data found for subject %s', bids.participants{iSubject,1});
        end
        
        % which raw data - with folder inheritance
        eegFile     = dir(fullfile(subjectFolder{iFold}, '*eeg.*'));
        channelFile = searchparent(subjectFolder{iFold}, '*_channels.tsv');
        elecFile    = searchparent(subjectFolder{iFold}, '*_electrodes.tsv');
        eventFile   = dir(fullfile(subjectFolder{iFold}, '*_events.tsv'));
        
        % raw data
        allFiles = { eegFile.name };
        ind = strmatch( 'json', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) );
        if ~isempty(ind)
            eegFileJSON = allFiles(ind);
            allFiles(ind) = [];
        end
        ind = strmatch( '.set', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) );
        if ~isempty(ind)
            eegFileRawAll  = allFiles(ind);
        elseif length(allFiles) == 1
            eegFileRawAll  = allFiles;
        else
            ind = strmatch( '.eeg', allFiles);
            if ~isempty(ind)
                error('No EEG data found for subject %s', bids.participants{iSubject,1});
            end
            eegFileRawAll  = allFiles(ind);
        end
        
        % skip most import if set file with no need for modication
        for iFile = 1:length(eegFileRawAll)
            
            eegFileRaw = eegFileRawAll{iFile};
            [~,tmpFileName,fileExt] = fileparts(eegFileRaw);
            eegFileRaw     = fullfile(subjectFolder{   iFold}, eegFileRaw);
            eegFileNameOut = fullfile(subjectFolderOut{iFold}, [ tmpFileName '.set' ]);
            
            % what is the run
            iRun = 1;
            ind = strfind(eegFileRaw, '_run-');
            if ~isempty(ind)
                iRun = str2double(eegFileRaw(ind(1)+5:ind(1)+6));
                if isnan(iRun) || iRun == 0, error('Problem converting run information'); end
            end
            
            % extract task name
            underScores = find(tmpFileName == '_');
            if ~strcmpi(tmpFileName(underScores(end)+1:end), 'eeg')
                error('EEG file name does not contain eeg'); % theoretically impossible
            end
            if isempty(findstr('ses', tmpFileName(underScores(end-1)+1:underScores(end)-1)))
                task = tmpFileName(underScores(end-1)+1:underScores(end)-1);
            end
            
            if ~strcmpi(fileExt, '.set') || strcmpi(opt.bidsevent, 'on') || strcmpi(opt.bidschanloc, 'on') || ~strcmpi(opt.outputdir, bidsFolder)
                switch lower(fileExt)
                    case '.set' % do nothing
                        EEG = pop_loadset( eegFileRaw );
                    case {'.bdf','.edf'}
                        EEG = pop_biosig( eegFileRaw );
                    case '.eeg'
                        EEG = pop_loadbva( eegFileRaw );
                    otherwise
                        error('No EEG data found for subject %s', bids.participants{iSubject,1});
                end
                
                % channel location data
                % ---------------------
                if strcmpi(opt.bidschanloc, 'on')
                    channelData = [];
                    if ~isempty(channelFile)
                        channelData = importtsv( fullfile(subjectFolder{iFold}, channelFile.name));
                    end
                    elecData = [];
                    if ~isempty(elecFile)
                        elecData = importtsv( fullfile(subjectFolder{iFold}, elecFile.name));
                    end
                    chanlocs = [];
                    for iChan = 2:size(channelData,1)
                        % the fields below are all required
                        chanlocs(iChan-1).labels = channelData{iChan,1};
                        chanlocs(iChan-1).type   = channelData{iChan,2};
                        chanlocs(iChan-1).unit   = channelData{iChan,3};
                        if size(channelData,2) > 3
                            chanlocs(iChan-1).status = channelData{iChan,4};
                        end
                        if ~isempty(elecData)
                            indElec = strmatch(chanlocs(iChan-1).labels, elecData(:,1), 'exact');
                            chanlocs(iChan-1).X = elecData{indElec,2};
                            chanlocs(iChan-1).Y = elecData{indElec,3};
                            chanlocs(iChan-1).Z = elecData{indElec,4};
                        end
                    end
                    
                    if length(chanlocs) ~= EEG.nbchan
                        warning('Different number of channels in channel location file and EEG file');
                        % check if the difference is due to non EEG channels
                        % list here https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/03-electroencephalography.html
                        keep = {'EEG','EOG','HEOG','VEOG'}; % keep all eeg related channels
                        tsv_eegchannels  = arrayfun(@(x) sum(strcmpi(x.type,keep)),chanlocs,'UniformOutput',true);
                        tmpchanlocs = chanlocs; tmpchanlocs(tsv_eegchannels==0)=[]; % remove non eeg related channels
                        chanlocs = tmpchanlocs; clear tmpchanlocs
                    end
                    
                    if length(chanlocs) ~= EEG.nbchan
                        error('channel location file and EEG file have non matching channel types and numbers');
                    end
                    
                    if isfield(chanlocs, 'X')
                        EEG.chanlocs = convertlocs(chanlocs, 'cart2all');
                    else
                        EEG.chanlocs = chanlocs;
                    end
                end
                
                % event data
                % ----------
                if strcmpi(opt.bidsevent, 'on')
                    eventData = [];
                    if ~isempty(eventFile)
                        eventData = importtsv( fullfile(subjectFolder{iFold}, eventFile.name));
                    end
                    events = struct([]);
                    indTrial = strmatch( 'trial_type', lower(eventData(1,:)), 'exact');
                    for iEvent = 2:size(eventData,1)
                        events(end+1).latency  = eventData{iEvent,1}*EEG.srate+1; % convert to samples
                        events(end).duration   = eventData{iEvent,2}*EEG.srate;   % convert to samples
                        if ~isempty(indTrial)
                            events(end).type = eventData{iEvent,indTrial};
                        end
                        for iField = 1:length(eventData(1,:))
                            if ~strcmpi(eventData{1,iField}, 'onset') && ~strcmpi(eventData{1,iField}, 'duration')
                                events(end).(eventData{1,iField}) = eventData{iEvent,iField};
                            end
                        end
                        %                         if size(eventData,2) > 3 && strcmpi(eventData{1,4}, 'response_time') && ~strcmpi(eventData{iEvent,4}, 'n/a')
                        %                             events(end+1).type   = 'response';
                        %                             events(end).latency  = (eventData{iEvent,1}+eventData{iEvent,4})*EEG.srate+1; % convert to samples
                        %                             events(end).duration = 0;
                        %                         end
                    end
                    EEG.event = events;
                    EEG = eeg_checkset(EEG, 'eventconsistency');
                end
                
                % copy information inside dataset
                EEG.subject = bids.participants{iSubject,1};
                EEG.session = iFold;
                
                if exist(subjectFolderOut{iFold},'dir') ~= 7
                    mkdir(subjectFolderOut{iFold});
                end
                EEG = pop_saveset( EEG, eegFileNameOut);
            end
            
            % building study command
            commands = { commands{:} 'index' count 'load' eegFileNameOut 'subject' bids.participants{iSubject,1} 'session' iFold 'run' iRun };
            
            % custom fields
            for iCol = 2:size(bids.participants,2)
                commands = { commands{:} bids.participants{1,iCol} bids.participants{iSubject,iCol} };
            end
            
            count = count+1;
        end % end for eegFileRaw
    end
end

% study name and study creation
% -----------------------------
studyName = fullfile(opt.outputdir, [opt.studyName '.study']);
[STUDY, ALLEEG]  = std_editset([], [], 'commands', commands, 'filename', studyName, 'task', task);
if ~isempty(options)
    commands = sprintf('[STUDY, ALLEEG] = pop_importbids(''%s'', %s);', bidsFolder, vararg2str(options));
else
    commands = sprintf('[STUDY, ALLEEG] = pop_importbids(''%s'');', bidsFolder);
end

% Import full text file
% ---------------------
function str = importalltxt(fileName)

str = [];
fid =fopen(fileName, 'r');
while ~feof(fid)
    str = [str 10 fgetl(fid) ];
end
str(1) = [];

% search parent folders
% ---------------------
function outFile = searchparent(folder, fileName)
outFile = dir(fullfile(folder, fileName));
if isempty(outFile)
    outFile = dir(fullfile(fileparts(folder), fileName));
end
if isempty(outFile)
    outFile = dir(fullfile(fileparts(fileparts(folder)), fileName));
end
if isempty(outFile)
    outFile = dir(fullfile(fileparts(fileparts(fileparts(folder))), fileName));
end

% Import tsv file
% ---------------
function res = importtsv( fileName)

res = loadtxt( fileName, 'verbose', 'off', 'delim', 9);

for iCol = 1:size(res,2)
    % search for NaNs
    indNaNs = cellfun(@(x)strcmpi('n/a', x), res(:,iCol));
    if ~isempty(indNaNs)
        allNonNaNVals = res(find(~indNaNs),iCol);
        allNonNaNVals(1) = []; % header
        testNumeric   = cellfun(@isnumeric, allNonNaNVals);
        if all(testNumeric)
            res(find(indNaNs),iCol) = { NaN };
        elseif ~all(~testNumeric)
            error('Mixture of numeric and non-numeric values in table');
        end
    end
end
