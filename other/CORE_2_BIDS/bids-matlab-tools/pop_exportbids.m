% pop_exportbids() - Export EEGLAB study into BIDS folder structure
%
% Usage:
%     pop_exportbids(STUDY, ALLEEG, 'key', val);
%
% Inputs:
%   bidsfolder - a loaded epoched EEG dataset structure.
%
% Note: 'key', val arguments are the same as the one in bids_export()
%
% Authors: Arnaud Delorme, SCCN, INC, UCSD, January, 2019

% Copyright (C) Arnaud Delorme, 2019
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

function [STUDY,EEG,com] = pop_exportbids(STUDY, EEG, varargin)

com = '';
if isempty(STUDY)
    error('BIDS export can only export EEGLAB studies');
end
if nargin < 2
    error('This function needs at least 2 parameters');
end

if nargin < 3 && ~ischar(STUDY)
    com = [ 'bidsFolderxx = uigetdir(''Pick a BIDS output folder'');' ...
            'if ~isequal(bidsFolderxx, 0), set(findobj(gcbf, ''tag'', ''outputfolder''), ''string'', bidsFolderxx); end;' ...
            'clear bidsFolderxx;' ];
            
    cb_task         = 'pop_exportbids(''edit_task'', gcbf);';
    cb_eeg          = 'pop_exportbids(''edit_eeg'', gcbf);';
    cb_participants = 'pop_exportbids(''edit_participants'', gcbf);';
    cb_events       = 'pop_exportbids(''edit_events'', gcbf);';
    uilist = { ...
        { 'Style', 'text', 'string', 'Export EEGLAB study to BIDS', 'fontweight', 'bold'  }, ...
        {} ...
        { 'Style', 'text', 'string', 'Output folder:' }, ...
        { 'Style', 'edit', 'string',   fullfile('.', 'BIDS_EXPORT') 'tag' 'outputfolder' }, ...
        { 'Style', 'pushbutton', 'string', '...' 'callback' com }, ...
        { 'Style', 'text', 'string', 'Licence for distributing:' }, ...
        { 'Style', 'edit', 'string', 'Creative Common 0 (CC0)' 'tag' 'license'  }, ...
        { 'Style', 'text', 'string', 'CHANGES compared to previous releases:' }, ...
        { 'Style', 'edit', 'string', '' 'tag' 'changes'  'HorizontalAlignment' 'left' 'max' 3   }, ...
        { 'Style', 'pushbutton', 'string', 'Edit task & EEG info' 'tag' 'task' 'callback' cb_task }, ...
        { 'Style', 'pushbutton', 'string', 'Edit participants' 'tag' 'participants' 'callback' cb_participants }, ...
        { 'Style', 'pushbutton', 'string', 'Edit event info' 'tag' 'events' 'callback' cb_events }, ...
        };
    relSize = 0.7;
    geometry = { [1] [1] [1-relSize relSize*0.8 relSize*0.2] [1-relSize relSize] [1] [1] [1 1 1] };
    geomvert =   [1  0.2 1                                                   1  1   3   1];
    userdata.EEG = EEG;
    userdata.STUDY = STUDY;
    [results,userdata,~,restag] = inputgui( 'geometry', geometry, 'geomvert', geomvert, 'uilist', uilist, 'helpcom', 'pophelp(''pop_exportbids'');', 'title', 'Export EEGLAB STUDY to BIDS -- pop_exportbids()', 'userdata', userdata );
    if length(results) == 0, return; end
    STUDY  = userdata.STUDY;
    EEG = userdata.EEG;

    % decode some outputs
    if ~isempty(strfind(restag.license, 'CC0')), restag.license = 'CC0'; end
%     if ~isempty(restag.authors)
%         authors = textscan(restag.authors, '%s', 'delimiter', ';');
%         authors = authors{1}';
%     else
%         authors = { '' };
%     end
    
    % options
    options = { 'targetdir' restag.outputfolder 'License' restag.license 'CHANGES' restag.changes};
    if isfield(EEG(1), 'BIDS')
        if isfield(EEG(1).BIDS, 'gInfo') && isfield(EEG(1).BIDS.gInfo,'README') 
            options = [options 'README' {EEG(1).BIDS.gInfo.README}];
            EEG(1).BIDS.gInfo = rmfield(EEG(1).BIDS.gInfo,'README');
        end
        if isfield(EEG(1).BIDS, 'gInfo') && isfield(EEG(1).BIDS.gInfo,'TaskName') 
            options = [options 'taskName' {EEG(1).BIDS.gInfo.TaskName}];
            EEG(1).BIDS.gInfo = rmfield(EEG(1).BIDS.gInfo,'TaskName');
        end
        bidsFieldsFromALLEEG = fieldnames(EEG(1).BIDS); % All EEG should share same BIDS info -> using EEG(1)
        for f=1:numel(bidsFieldsFromALLEEG)
            options = [options bidsFieldsFromALLEEG{f} {EEG(1).BIDS.(bidsFieldsFromALLEEG{f})}];
        end
    end
    
elseif ischar(STUDY)
    command = STUDY;
    fig = EEG;
    userdata = get(fig, 'userdata');
    switch command
        case 'edit_participants'
            userdata.EEG = pop_participantinfo(userdata.EEG);
        case 'edit_events'
            userdata.EEG = pop_eventinfo(userdata.EEG);
        case 'edit_task'
            userdata.EEG  = pop_taskinfo(userdata.EEG);
        case 'edit_eeg'
            userdata.EEG = pop_eegacqinfo(userdata.EEG);
    end
    set(fig, 'userdata', userdata);
    return
else
    options = varargin;
end

% get subjects and sessions
% -------------------------
if ~isempty(EEG(1).subject)
    allSubjects = { EEG.subject };
elseif ~isempty(STUDY.datasetinfo(1).subject)
    allSubjects = { STUDY.datasetinfo.subject };
else
    error('No subject info found in either EEG or STUDY.datasetinfo. Please add using Study > Edit STUDY info');
end
if ~isempty(STUDY.datasetinfo(1).session)
    allSessions = { STUDY.datasetinfo.session };
else
    allSessions = { EEG.session };
end
uniqueSubjects = unique(allSubjects);
allSessions(cellfun(@isempty, allSessions)) = { 1 };
allSessions = cellfun(@num2str, allSessions, 'uniformoutput', false);
uniqueSessions = unique(allSessions);

% export STUDY to BIDS
% --------------------
pInfo = {}; % each EEG file has its own pInfo --> need to aggregate
if isfield(EEG(1), 'BIDS') && isfield(EEG(1).BIDS,'pInfo') 
    pInfo = EEG(1).BIDS.pInfo(1,:);
end
subjects = struct('file',{}, 'session', [], 'run', []);
for iSubj = 1:length(uniqueSubjects)
    indS = strmatch( uniqueSubjects{iSubj}, allSubjects, 'exact' );
    for iFile = 1:length(indS)
        subjects(iSubj).file{iFile} = fullfile( EEG(indS(iFile)).filepath, EEG(indS(iFile)).filename);
        if isfield(EEG(indS(iFile)), 'session') && ~isempty(EEG(indS(iFile)).session)
            subjects(iSubj).session(iFile) = EEG(indS(iFile)).session;
        else
            subjects(iSubj).session(iFile) = iFile;
        end
        if isfield(EEG(indS(iFile)), 'run') && ~isempty(EEG(indS(iFile)).run)
            subjects(iSubj).run(iFile) = EEG(indS(iFile)).run;
        else
            subjects(iSubj).run(iFile) = 1;  % Assume only one run
        end
    end
    if isfield(EEG(indS(1)), 'BIDS') && isfield(EEG(indS(1)).BIDS,'pInfo')
        pInfo = [pInfo; EEG(indS(1)).BIDS.pInfo(2,:)];
    end
end
if ~isempty(pInfo)
    options = [options 'pInfo' {pInfo}];
end
bids_export(subjects, options{:});

% history
% -------
if nargin < 1
    com = sprintf('pop_exportbids(STUDY, %s);', vararg2str(options));
end

end