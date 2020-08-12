% pop_taskinfo() - BIDS task information
%
% Usage:
%     EEG = pop_taskinfo(EEG);
%
% Inputs:
%     EEG - EEGLAB dataset or group of dataset
%
%
% Authors: Arnaud Delorme, Dung Truong SCCN, INC, UCSD, 2020

% Copyright (C) Arnaud Delorme, 2020
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

function [EEG,com] = pop_taskinfo(EEG)
    %% Default settings
    bg = [0.65 0.76 1];
    fg = [0 0 0.4];
    fontSize = 11;
    tfHeight = 0.04;
    
    f = figure('MenuBar', 'None', 'ToolBar', 'None', 'Name', 'BIDS task information -- pop_taskinfo()', 'Color', bg, 'IntegerHandle','off');
    f.Position(3) = 1200;
    f.Position(4) = 900;
    halfWidth = 0.5;

    %% Generic task info
    leftMargin = 0.02;
    fullWidth = halfWidth - leftMargin - 0.04;
    tfWidth = 0.35*fullWidth;
    efWidth = 0.63*fullWidth;
    efLeftMargin = leftMargin + tfWidth + 0.01;
    top = 0.92;
    uicontrol('Style', 'text', 'string', 'BIDS task information', 'fontweight', 'bold', 'fontsize',13,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top halfWidth 0.05]);
    top = top - 0.03;
    uicontrol('Style', 'text', 'string', 'Dataset name*','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'Name','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]); 
    top = top - tfHeight - 0.01;
    uicontrol('Style', 'text', 'string', 'Task name (no space)','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'TaskName','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]); 
    top = top - tfHeight - 0.01;
    uicontrol('Style', 'text', 'string', 'README (short introduction to the experiment):','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top fullWidth tfHeight]);
    top = top - tfHeight*2.2;
    uicontrol('Style', 'edit', 'string', '', 'tag', 'README','fontsize',fontSize, 'HorizontalAlignment', 'left', 'max', 3,'Units', 'normalized', 'Position', [leftMargin top fullWidth tfHeight*2.5]);
    top = top - tfHeight - 0.01;
    uicontrol('Style', 'text', 'string', 'Participant task description (description of the experiment):','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top fullWidth tfHeight]);
    top = top - tfHeight*2.7;
    uicontrol('Style', 'edit', 'string', '', 'tag', 'TaskDescription','fontsize',fontSize, 'HorizontalAlignment', 'left', 'max', 3,'Units', 'normalized', 'Position', [leftMargin top fullWidth tfHeight*3]);
    top = top - tfHeight - 0.01;
    uicontrol('Style', 'text', 'string', 'Participant instructions (as exact as possible):','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top fullWidth tfHeight]);
    top = top - tfHeight*2.7;
    uicontrol('Style', 'edit', 'string', '', 'tag', 'Instructions', 'HorizontalAlignment', 'left', 'max', 3,'Units', 'normalized', 'Position', [leftMargin top fullWidth tfHeight*3]);
    top = top - tfHeight - 0.02;
    uicontrol('Style', 'text', 'string', 'Authors','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'Authors','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]); 
    top = top - tfHeight - 0.005;
    uicontrol('Style', 'text', 'string', 'References and links','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'ReferencesAndLinks','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]); 
    top = top - tfHeight - 0.005;
    cm = uicontextmenu(f);
    m1 = uimenu(cm,'Text','Lookup CognitiveAtlas TermURL','MenuSelectedFcn',{@btnCB,'http://www.cognitiveatlas.org/tasks/a/'});
    tooltip = sprintf('URL of the corresponding Cognitive Atlas term that describes the task.\nRight click to lookup.');
    uicontrol('Style', 'text', 'string', 'Task-relevant Cognitive Atlas term', 'Tooltip',tooltip,'UIContextMenu', cm,'fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top-0.005 tfWidth tfHeight+0.01]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'CogAtlasID','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]);
    top = top - tfHeight - 0.005;
    cm = uicontextmenu(f);
    m1 = uimenu(cm,'Text','Lookup CogPO TermURL','MenuSelectedFcn',{@btnCB,'http://wiki.cogpo.org/index.php?title=Main_Page'});
    tooltip = sprintf('URL of the corresponding CogPO term that describes the task.\nRight click to lookup.');
    uicontrol('Style', 'text', 'string', 'Task-relevant CogPO term', 'Tooltip',tooltip,'UIContextMenu', cm,'fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top 0.35*fullWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'CogPOID','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]);
    top = top - tfHeight - 0.005;
    uicontrol('Style', 'text', 'string', 'Institution','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'InstitutionName','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]); 
    top = top - tfHeight - 0.005;
    uicontrol('Style', 'text', 'string', 'Department','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'InstitutionalDepartmentName','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]);    
    top = top - tfHeight - 0.005;    
    uicontrol('Style', 'text', 'string', 'Institution location','fontsize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg, 'HorizontalAlignment','left','Units', 'normalized', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '', 'tag', 'InstitutionAddress','fontsize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight]);        
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Help', 'FontSize',fontSize, 'Units', 'normalized', 'Position', [0.05 0.01 0.15 0.04], 'Callback', @helpCB); 
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Ok', 'FontSize',fontSize, 'Units', 'normalized', 'Position', [0.80 0.01 0.15 0.04], 'Callback', @okCB); 
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Cancel', 'FontSize',fontSize, 'Units', 'normalized', 'Position', [0.64 0.01 0.15 0.04], 'Callback', @cancelCB); 

    %% EEG specific info
    leftMargin = halfWidth;
    fullWidth = halfWidth - 0.03;
    tfWidth = 0.4*fullWidth;
    efWidth = 0.6*fullWidth;
    efLeftMargin = leftMargin + tfWidth + 0.01;
    top = 0.92;
    uicontrol('Style', 'text', 'string', 'BIDS EEG acquisition information', 'Units', 'normalized','FontSize',13,'FontWeight','bold','BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top 0.4 0.05]);
    top = top-0.03;
    uicontrol('Style', 'text', 'string', 'Cap manufacturer', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'CapManufacturer', 'FontSize',fontSize, 'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'Cap model', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'CapManufacturersModelName', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'EEG reference location*', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'EEGReference', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'EEG ground electrode location', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'EEGGround', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'EEG montage system (10-20, 10-10, custom)', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'EEGPlacementScheme', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'EEG amplifier maker', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'Manufacturer', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB); 
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'EEG amplifier model', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight], 'Callback', @editedCB);
    uicontrol('Style', 'edit', 'string', '','tag', 'ManufacturersModelName', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB); 
    top = top-0.06;    
    uicontrol('Style', 'text', 'string', 'EEG amplifier serial #', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'DeviceSerialNumber', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);    
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'EEG acquisition software version', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    uicontrol('Style', 'edit', 'string', '','tag', 'SoftwareVersions', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);    
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'Hardware filters', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight+0.002]);
    uicontrol('Style', 'edit', 'string', '','tag', 'HardwareFilters','FontSize',fontSize, 'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB);   
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'Software filters*', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight+0.002]);
    uicontrol('Style', 'edit', 'string', '','tag', 'SoftwareFilters', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth tfHeight], 'Callback', @editedCB); 
    top = top-0.06;
    uicontrol('Style', 'text', 'string', 'Line frequency (Hz)*', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth 0.05]);
    uicontrol('Style', 'popupmenu', 'string', {'Select','50','60'},'tag', 'PowerLineFrequency', 'FontSize',fontSize,'Units', 'normalized', 'Position', [efLeftMargin top efWidth 0.05], 'Callback', @editedCB);
    top = top-0.06;
    uicontrol('Style','text','string','* Required field', 'Units', 'normalized','FontSize',fontSize,'BackgroundColor',bg,'ForegroundColor',fg,'HorizontalAlignment','left', 'Position', [leftMargin top tfWidth tfHeight]);
    % prefill data
    preFill();
    
    % wait
    waitfor(f);
    
    %% history
    com = sprintf('pop_taskinfo(ALLEG);');


%% Helper functions
    function btnCB(src,event, url)
       web(url);
    end
    function helpCB(src,event)
        pophelp('pop_taskinfo');
    end
    function okCB(src,event)
        for a=1:numel(EEG)
            bids = [];
            tInfo = [];
            gInfo = [];
            % preserve current BIDS info if have
            if isfield(EEG(a), 'BIDS')
                bids = EEG(a).BIDS;
                if isfield(bids, 'tInfo')
                    tInfo = bids.tInfo;
                end
                if isfield(bids, 'gInfo')
                    gInfo = bids.gInfo;
                end
            end
            % update tInfo and gInfo from input fields
            objs = findall(f);
            for i=1:numel(objs)
                if ~isempty(objs(i).Tag)
                    if ~isempty(objs(i).String)
                        if strcmp(objs(i).Tag, 'TaskName')
                            gInfo.(objs(i).Tag) = strrep(objs(i).String,' ',''); % no space allowed for task name
                        elseif strcmp(objs(i).Tag, 'README') || strcmp(objs(i).Tag, 'Name') || strcmp(objs(i).Tag, 'ReferencesAndLinks') || strcmp(objs(i).Tag, 'Authors')
                            if strcmp(objs(i).Tag, 'ReferencesAndLinks') || strcmp(objs(i).Tag, 'Authors')
                                gInfo.(objs(i).Tag) = {objs(i).String};
                            else
                                gInfo.(objs(i).Tag) = objs(i).String;
                            end
                        else
                            if strcmp(objs(i).Style, 'popupmenu')
                                if objs(i).Value > 1 % dropdown
                                    if strcmp(objs(i).Tag, 'PowerLineFrequency')
                                        tInfo.(objs(i).Tag) = str2double(objs(i).String{objs(i).Value});
                                    else
                                        tInfo.(objs(i).Tag) = objs(i).String{objs(i).Value};
                                    end
                                end
                            else
                                if strcmp(objs(i).Tag, 'HardwareFilters') || strcmp(objs(i).Tag, 'SoftwareFilters')
                                    tmp = [];
                                    tmp.FilterDescription = [];
                                    tmp.FilterDescription.Description = objs(i).String;
                                    tInfo.(objs(i).Tag) = tmp;
                                else
                                    tInfo.(objs(i).Tag) = objs(i).String;
                                end
                            end
                        end
                    elseif isfield(tInfo,objs(i).Tag) % remove field if no longer has value
                        tInfo = rmfield(tInfo, objs(i).Tag);
                    end
                end
            end
            % update BIDS structure
            bids.tInfo = tInfo;
            bids.gInfo = gInfo;
            EEG(a).BIDS = bids;
            EEG(a).saved = 'no';
        end
        close(f);
    end
    function cancelCB(src, event)
        close(f);
    end
    function preFill()
        prevtInfo = gettInfo(EEG);
        if ~isempty(prevtInfo)
            objs = findall(f);
            for i=1:numel(objs)
                if ~isempty(objs(i).Tag) && isfield(prevtInfo, objs(i).Tag)
                    if strcmp(objs(i).Style, 'popupmenu') % dropdown
                        objs(i).Value = find(strcmp(objs(i).String, num2str(prevtInfo.(objs(i).Tag)))); % set position of dropdown menu to the appropriate string
                    elseif strcmp(objs(i).Tag, 'HardwareFilters') || strcmp(objs(i).Tag, 'SoftwareFilters')
                        if ischar(prevtInfo.(objs(i).Tag)) % accommodate previous code
                            objs(i).String = prevtInfo.(objs(i).Tag);
                        else
                            objs(i).String = prevtInfo.(objs(i).Tag).FilterDescription.Description;
                        end
                    else
                        objs(i).String = char(prevtInfo.(objs(i).Tag));
                    end
                end
            end
        end
        
        prevgInfo = getgInfo(EEG);
        if ~isempty(prevgInfo)
            objs = findall(f);
            for i=1:numel(objs)
                if ~isempty(objs(i).Tag) && isfield(prevgInfo, objs(i).Tag)
                    if strcmp(objs(i).Style, 'popupmenu') % dropdown
                        objs(i).Value = find(strcmp(objs(i).String, prevgInfo.(objs(i).Tag))); % set position of dropdown menu to the appropriate string
                    else
                        if iscell(prevgInfo.(objs(i).Tag))
                            objs(i).String = prevgInfo.(objs(i).Tag){1}; % e.g., Authors & ReferencesAndLinks
                        else
                            objs(i).String = prevgInfo.(objs(i).Tag);
                        end
                    end
                end
            end
        end
    end

    function tInfo = gettInfo(EEG)
        hasBIDS = arrayfun(@(x) isfield(x,'BIDS') && ~isempty(x.BIDS),EEG);
        if sum(hasBIDS) == 0 %if no BIDS found for any EEG
            tInfo = [];
        else % at least one EEG has BIDS
            if sum(hasBIDS) < numel(EEG) % not all have BIDS
                warning('Not all EEG contains BIDS information.');
            end
            hastInfo = arrayfun(@(x) isfield(x,'BIDS') && isfield(x.BIDS,'tInfo') && ~isempty(x.BIDS.tInfo),EEG);
            if sum(hastInfo) == 0
                tInfo = [];
            else % at least one EEG has BIDS.tInfo
                try
                    bids = [EEG(hastInfo).BIDS];
                    alltInfo = [bids.tInfo];
                    if numel(alltInfo) < numel(EEG)
                        tInfo = EEG(find(hastInfo,1)).BIDS.tInfo;
                        warning('Not all EEG contains tInfo structure. Using tInfo of EEG(%d)...',find(hastInfo,1));
                    else
                        tInfo = alltInfo(1);
                        fprintf('Using tInfo of EEG(1)...\n');
                    end
                catch % field inconsistent
                    tInfo = EEG(find(hastInfo,1)).BIDS.tInfo;
                    warning('Inconsistence found in tInfo structures. Using tInfo of EEG(%d)...',find(hastInfo,1));
                end
            end
        end
    end
    function gInfo = getgInfo(EEG)
        hasBIDS = arrayfun(@(x) isfield(x,'BIDS') && ~isempty(x.BIDS),EEG);
        if sum(hasBIDS) == 0 %if no BIDS found for any EEG
            gInfo = [];
        else % at least one EEG has BIDS
            if sum(hasBIDS) < numel(EEG) % not all have BIDS
                warning('Not all EEG contains BIDS information.');
            end
            hasgInfo = arrayfun(@(x) isfield(x,'BIDS') && isfield(x.BIDS,'gInfo') && ~isempty(x.BIDS.gInfo),EEG);
            if sum(hasgInfo) == 0
                gInfo = [];
            else % at least one EEG has BIDS.gInfo
                try
                    bids = [EEG(hasgInfo).BIDS];
                    allgInfo = [bids.gInfo];
                    if numel(allgInfo) < numel(EEG)
                        gInfo = EEG(find(hasgInfo,1)).BIDS.gInfo;
                        warning('Not all EEG contains gInfo structure. Using gInfo of EEG(%d)...',find(hasgInfo,1));
                    else
                        gInfo = allgInfo(1);
                        fprintf('Using tInfo of EEG(1)...\n');
                    end
                catch % field inconsistent
                    gInfo = EEG(find(hasgInfo,1)).BIDS.gInfo;
                    warning('Inconsistence found in gInfo structures. Using gInfo of EEG(%d)...',find(hasgInfo,1));
                end
            end
        end
    end

    function editedCB(src,event)
    end
end