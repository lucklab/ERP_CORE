% This function provides a comprehensive example of using the bids_export
% function. Note that eventually, you may simply use bids_export({file1.set file2.set}) 
% and that all other parameters are highly recommended but optional.

% You may not run this script because you do not have the associated data.
% It correspond to the actual dataset included in the BIDS EEG publication
% available at https://psyarxiv.com/63a4y.
%
% The data itself is available at https://zenodo.org/record/1490922
%
% A. Delorme - Jan 2019

% raw data files (replace with your own)
% ----------------------------------
data(1).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-001/ses-01/eeg/sub-001_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-001/ses-02/eeg/sub-001_ses-02_task-meditation_eeg.bdf' };
data(1).session = [1 2];
data(1).run     = [1 1];

data(2).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-002/ses-01/eeg/sub-002_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-002/ses-02/eeg/sub-002_ses-02_task-meditation_eeg.bdf'};
data(2).session = [1 2];
data(2).run     = [1 1];

data(3).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-003/ses-01/eeg/sub-003_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-003/ses-02/eeg/sub-003_ses-02_task-meditation_eeg.bdf'};
data(3).session = [1 2];
data(3).run     = [1 1];           
            
data(4).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-004/ses-01/eeg/sub-004_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-004/ses-02/eeg/sub-004_ses-02_task-meditation_eeg.bdf'};
data(4).session = [1 2];
data(4).run     = [1 1];            

data(5).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-005/ses-01/eeg/sub-005_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-005/ses-02/eeg/sub-005_ses-02_task-meditation_eeg.bdf'};
data(5).session = [1 2];
data(5).run     = [1 1];

data(6).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-006/ses-01/eeg/sub-006_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-006/ses-02/eeg/sub-006_ses-02_task-meditation_eeg.bdf'};
data(6).session = [1 2];
data(6).run     = [1 1];

data(7).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-007/ses-01/eeg/sub-007_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-007/ses-02/eeg/sub-007_ses-02_task-meditation_eeg.bdf'};
data(7).session = [1 2];
data(7).run     = [1 1];

data(8).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-008/ses-01/eeg/sub-008_ses-01_task-meditation_eeg.bdf'};
data(8).session = 1;
data(8).run     = 1;

data(9).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-009/ses-01/eeg/sub-009_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-009/ses-02/eeg/sub-009_ses-02_task-meditation_eeg.bdf'};
data(9).session = [1 2];
data(9).run     = [1 1];

data(10).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-010/ses-01/eeg/sub-010_ses-01_task-meditation_eeg.bdf'
                '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-010/ses-02/eeg/sub-010_ses-02_task-meditation_eeg.bdf'};
data(10).session = [1 2];
data(10).run     = [1 1];

data(11).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-011/ses-01/eeg/sub-011_ses-01_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-011/ses-02/eeg/sub-011_ses-02_task-meditation_eeg.bdf'};
data(11).session = [1 2];
data(11).run     = [1 1];

data(12).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-012/ses-01/eeg/sub-012_ses-01_task-meditation_eeg.bdf'};
data(12).session = 1;
data(12).run     = 1;

data(13).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-013/ses-01/eeg/sub-013_ses-01_task-meditation_eeg.bdf'};
data(13).session = 1;
data(13).run     = 1;

data(14).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-014/ses-01/eeg/sub-014_ses-01_task-meditation_eeg.bdf'};
data(14).session = 1;
data(14).run     = 1;

data(15).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-015/ses-01/eeg/sub-015_ses-01_task-meditation_eeg.bdf'};
data(15).session = 1;
data(15).run     = 1;

data(16).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-016/ses-01/eeg/sub-016_ses-01_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-016/ses-02/eeg/sub-016_ses-02_task-meditation_eeg.bdf'};
data(16).session = [1 2];
data(16).run     = [1 1];

data(17).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-017/ses-01/eeg/sub-017_ses-01_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-017/ses-02/eeg/sub-017_ses-02_task-meditation_eeg.bdf'};
data(17).session = [1 2];
data(17).run     = [1 1];

data(18).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-018/ses-01/eeg/sub-018_ses-01_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-018/ses-02/eeg/sub-018_ses-02_task-meditation_eeg.bdf'};
data(18).session = [1 2];
data(18).run     = [1 1];

data(19).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-019/ses-01/eeg/sub-019_ses-01_task-meditation_eeg.bdf'};
data(19).session = 1;
data(19).run     = 1;

data(20).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-020/ses-01/eeg/sub-020_ses-01_task-meditation_eeg.bdf'};
data(20).session = 1;
data(20).run     = 1;

data(21).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-021/ses-01/eeg/sub-021_ses-01_task-meditation_eeg.bdf'};
data(21).session = 1;
data(21).run     = 1;

data(22).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-022/ses-01/eeg/sub-022_ses-01_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-022/ses-02/eeg/sub-022_ses-02_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-022/ses-03/eeg/sub-022_ses-03_task-meditation_eeg.bdf'};
data(22).session = [1 2 3];
data(22).run     = [1 1 1];

data(23).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-023/ses-01/eeg/sub-023_ses-01_task-meditation_eeg.bdf'
                 '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-023/ses-02/eeg/sub-023_ses-02_task-meditation_eeg.bdf'};
data(23).session = [1 2];
data(23).run     = [1 1];

data(24).file = {'/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/sub-024/ses-01/eeg/sub-024_ses-01_task-meditation_eeg.bdf' }; 
data(24).session = 1;
data(24).run     = 1;

% general information for dataset_description.json file
% -----------------------------------------------------
generalInfo.Name = 'Meditation study';
generalInfo.ReferencesAndLinks = { "https://www.ncbi.nlm.nih.gov/pubmed/27815577" };

% participant information for participants.tsv file
% -------------------------------------------------
pInfo = { 'gender'   'age'   'group'; % originally from file mw_expe_may28_2015 and convert_files_to_bids.m
'M'	32 'expert';
'M'	35 'expert';
'F'	41 'expert';
'M'	29 'expert';
'F'	34 'expert';
'M'	32 'expert';
'M'	32 'expert';
'M'	32 'expert';
'M'	43 'expert';
'M'	33 'expert';
'M'	62 'expert';
'M'	65 'expert';
'F'	47 'novice';
'F'	52 'novice';
'F'	78 'novice';
'M'	77 'novice';
'F'	32 'novice';
'F'	'n/a' 'novice';
'F'	42 'novice';
'F'	41 'novice';
'F'	41 'novice';
'F'	31 'novice';
'M'	50 'novice';
'F'	38 'novice' };
       
% participant column description for participants.json file
% ---------------------------------------------------------
pInfoDesc.gender.Description = 'sex of the participant';
pInfoDesc.gender.Levels.M = 'male';
pInfoDesc.gender.Levels.F = 'female';
pInfoDesc.participant_id.Description = 'unique participant identifier';
pInfoDesc.age.Description = 'age of the participant';
pInfoDesc.age.Units       = 'years';
pInfoDesc.group.Description = 'group, expert or novice meditators';
pInfoDesc.group.Levels.expert = 'expert meditator';
pInfoDesc.group.Levels.novice = 'novice meditator';

% event column description for xxx-events.json file (only one such file)
% ----------------------------------------------------------------------
eInfoDesc.onset.Description = 'Event onset';
eInfoDesc.onset.Units = 'second';
eInfoDesc.duration.Description = 'Event duration';
eInfoDesc.duration.Units = 'second';
eInfoDesc.trial_type.Description = 'Type of event (different from EEGLAB convention)';
eInfoDesc.trial_type.Levels.stimulus = 'Onset of first question';
eInfoDesc.trial_type.Levels.response = 'Response to question 1, 2 or 3';
eInfoDesc.response_time.Description = 'Response time column not use for this data';
eInfoDesc.sample.Description = 'Event sample starting at 0 (Matlab convention starting at 1)';
eInfoDesc.value.Description = 'Value of event (numerical)';
eInfoDesc.value.Levels.x2   = 'Response 1 (this may be a response to question 1, 2 or 3)';
eInfoDesc.value.Levels.x4   = 'Response 2 (this may be a response to question 1, 2 or 3)';
eInfoDesc.value.Levels.x8   = 'Response 3 (this may be a response to question 1, 2 or 3)';
eInfoDesc.value.Levels.x16   = 'Indicate involuntary response';
eInfoDesc.value.Levels.x128 = 'First question onset (most important marker)';

% Content for README file
% -----------------------
README = sprintf( [ 'This meditation experiment contains 24 subjects. Subjects were\n' ...
                    'meditating and were interupted about every 2 minutes to indicate\n' ...
                    'their level of concentration and mind wandering. The scientific\n' ...
                    'article (see Reference) contains all methodological details\n\n' ...
                    '- Arnaud Delorme (October 17, 2018)' ]);
                
% Content for CHANGES file
% ------------------------
CHANGES = sprintf([ 'Revision history for meditation dataset\n\n' ...
                    'version 1.0 beta - 17 Oct 2018\n' ...
                    ' - Initial release\n' ...
                    '\n' ...
                    'version 2.0 - 9 Jan 2019\n' ...
                    ' - Fixing event field names and various minor issues\n' ...
                    '\n' ...
                    'Version 3.0 - 20 March 2019\n' ...
                    ' - Adding channel location information\n' ]);                    
                
% List of stimuli to be copied to the stimuli folder
% --------------------------------------------------
stimuli = {'/data/matlab/tracy_mw/rate_mw.wav' 
    '/data/matlab/tracy_mw/rate_meditation.wav'
    '/data/matlab/tracy_mw/rate_tired.wav'
    '/data/matlab/tracy_mw/expe_over.wav'
    '/data/matlab/tracy_mw/mind_wandering.wav'
    '/data/matlab/tracy_mw/self.wav'
    '/data/matlab/tracy_mw/time.wav'
    '/data/matlab/tracy_mw/valence.wav'
    '/data/matlab/tracy_mw/depth.wav'
    '/data/matlab/tracy_mw/resume.wav'
    '/data/matlab/tracy_mw/resumed.wav'
    '/data/matlab/tracy_mw/resumemed.wav'
    '/data/matlab/tracy_mw/cancel.wav'
    '/data/matlab/tracy_mw/starting.wav' };

% List of script to run the experiment
% ------------------------------------
code = { '/data/matlab/tracy_mw/run_mw_experiment6.m' mfilename('fullpath') };

% Task information for xxxx-eeg.json file
% ---------------------------------------
tInfo.InstitutionAddress = 'Centre de Recherche Cerveau et Cognition, Place du Docteur Baylac, Pavillon Baudot, 31059 Toulouse, France';
tInfo.InstitutionName = 'Paul Sabatier University';
tInfo.InstitutionalDepartmentName = 'Centre de Recherche Cerveau et Cognition';
tInfo.PowerLineFrequency = 50;
tInfo.ManufacturersModelName = 'ActiveTwo';

% Trial types correspondance with event types/values
% BIDS allows for both trial types and event values
% --------------------------------------------------
trialTypes = { '2' 'response';
               '4' 'response';
               '8' 'response';
               '16' 'n/a';
               '128' 'stimulus' };
           
% channel location file
% ---------------------
chanlocs = '/data/matlab/bids_matlab/BIDS_EEG_meditation_raw_do_not_delete/channel_loc_file.ced';
           
% call to the export function
% ---------------------------
bids_export(data, 'targetdir', '/Users/arno/temp/bids_meditation_export', 'taskName', 'meditation', 'trialtype', trialTypes, 'gInfo', generalInfo, 'pInfo', pInfo, 'pInfoDesc', pInfoDesc, 'eInfoDesc', eInfoDesc, 'README', README, 'CHANGES', CHANGES, 'stimuli', stimuli, 'codefiles', code, 'tInfo', tInfo, 'chanlocs', chanlocs);
