% eegplugin_bids() - EEGLAB plugin for importing data saved
%             by the finders course (Matlab converted)
%
% Usage:
%   >> eegplugin_bids(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.

function vers = eegplugin_bids(fig, trystrs, catchstrs)

    vers = '3.1';
    if nargin < 3
        error('eegplugin_bids requires 3 arguments');
    end
    
    % add folder to path
    % ------------------
    p = which('pop_importbids.m');
    p = p(1:findstr(p,'pop_importbids.m')-1);
    if ~exist('pop_importbids')
        addpath( p );
    end
    
    % find import data menu
    % ---------------------
    menui1 = findobj(fig, 'tag', 'import data');
    menui2 = findobj(fig, 'tag', 'export');
    menui3 = findobj(fig, 'label', 'File');
    
    % menu callbacks
    % --------------
    comcnt1 = [ trystrs.no_check '[STUDYTMP, ALLEEGTMP, ~, LASTCOM] = pop_importbids; '  catchstrs.load_study ];
    comcnt2 = [ trystrs.no_check 'pop_exportbids(STUDY, EEG);' catchstrs.add_to_hist ];
                
    % create menus
    % ------------
    uimenu( menui1, 'label', 'From BIDS folder structure', 'separator', 'on', 'callback', comcnt1);
    uimenu( menui2, 'label', 'To BIDS folder structure', 'separator', 'on', 'callback', comcnt2, 'userdata', 'startup:off;study:on');
    set(menui2, 'userdata', 'startup:off;study:on');

    % create BIDS menus
    % -----------------
    comtaskinfo  = '[EEG,COM] = pop_taskinfo(EEG);';
    comsubjinfo  = '[EEG,COM] = pop_participantinfo(EEG,STUDY);';
    comeventinfo = '[EEG,COM] = pop_eventinfo(EEG);';
%     comvalidatebids = [ trystrs.no_check 'if plugin_askinstall(''bids-validator'',''pop_validatebids'') == 1 pop_validatebids() end' catchstrs.add_to_hist ];
    bids = uimenu( menui3, 'label', 'BIDS tools', 'separator', 'on', 'position', 5, 'userdata', 'startup:on;study:on');
    
    uimenu( bids, 'label', 'Edit BIDS task info', 'callback', comtaskinfo, 'userdata', 'study:on');
    uimenu( bids, 'label', 'Edit BIDS participant info', 'callback', comsubjinfo, 'userdata', 'study:on');
    uimenu( bids, 'label', 'Edit BIDS event info', 'callback', comeventinfo, 'userdata', 'study:on');
    uimenu( bids, 'label', 'Import BIDS folder to STUDY', 'separator', 'on', 'callback', comcnt1);
    uimenu( bids, 'label', 'Export STUDY to BIDS folder', 'callback', comcnt2, 'userdata', 'startup:off;study:on');
    uimenu( bids, 'label', 'Validate BIDS dataset', 'separator', 'on', 'callback', @validatebidsCB, 'userdata', 'startup:on;study:on');
    
    function validatebidsCB(src,event)
        if plugin_status('bids-validator') == 0
            plugin_askinstall('bids-validator');
        else
            pop_validatebids()
         end
    end
end
