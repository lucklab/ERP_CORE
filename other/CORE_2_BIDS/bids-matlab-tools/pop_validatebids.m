% pop_validatebids() - Validate BIDS dataset. Validation result will be
%                      printed on command window
%                      Adopting Openneuro's command-line bids-validator
%                      https://github.com/bids-standard/bids-validator
%
% Usage:
%   >> pop_validatebids(); % open new window to input/select BIDS dataset
%   >> pop_validatebids(datasetPath); % validate dataset given provided path
%
function pop_validatebids(varargin)
    if ~plugin_status('bids-validator')
        plugin_askinstall('bids-validator',[],true);
    end
    if ismac
        validator = 'bids-validator-macos';  
    elseif isunix
        validator = 'bids-validator-linux';
    elseif ispc
        validator = 'bids-validator-win.exe';
    end
    filepath = fullfile(fileparts(which('eegplugin_bidsvalidator')), validator);
    if ismac || isunix
        system(['chmod u+x ' filepath]);
    end
    if ~exist(filepath,'file')
        supergui('geomhoriz', {[1] [1] [1]}, 'geomvert', [1 1 1], 'uilist', {{'Style','text','string','No validator found. Abort'},...
                                                                              {}, ...
                                                                              { 'Style', 'pushbutton', 'string', 'Ok' 'callback' 'close(gcf)' }}, 'title','Error -- pop_validatebids()');
        waitfor(gcf);
    else
        if nargin == 1 && ischar(varargin{1}) && isfolder(varargin{1})
            system([filepath ' ' varargin{1}]);
        else
            com = [ 'bidsFolderxx = uigetdir(''Pick a BIDS output folder'');' ...
                'if ~isequal(bidsFolderxx, 0), set(findobj(gcbf, ''tag'', ''outputfolder''), ''string'', bidsFolderxx); end;' ...
                'clear bidsFolderxx;' ];
            uilist = { ...
            { 'Style', 'text', 'string', 'Validate BIDS dataset', 'fontweight', 'bold'  }, ...
            { 'Style', 'text', 'string', 'BIDS folder:' }, ...
            { 'Style', 'edit', 'string',   fullfile('.', 'BIDS_EXPORT') 'tag' 'outputfolder' }, ...
            { 'Style', 'pushbutton', 'string', '...' 'callback' com }, ...
            { 'Style', 'text', 'string', '' }, ...
            { 'Style', 'pushbutton', 'string', 'Validate' 'tag' 'validateBtn' 'callback' @validateCB }, ...
            { 'Style', 'text', 'string', ''}, ...
            };
            geometry = { [1] [0.2 0.7 0.1] [1 1 1] };
            geomvert =   [1  1  1];
            supergui( 'geomhoriz', geometry, 'geomvert', geomvert, 'uilist', uilist, 'title', 'Validate BIDS dataset-- pop_validatebids()');
        end            
    end
    function validateCB(src, event)
        obj = findobj('Tag','outputfolder');
        dir = obj.String;
        system([filepath ' ' dir]);
        close(gcf);
    end
end
