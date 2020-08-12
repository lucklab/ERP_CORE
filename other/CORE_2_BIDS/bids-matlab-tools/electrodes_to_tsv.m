% electrodes_to_tsv   - From an EEG structure export the EEG.channel
%                       locations as tsv file and initiate the json file  
%                       following the BIDS specification
%
% Usage: 
%             >>  electrodes_to_tsv(EEG)
%             >>  electrodes_to_tsv(EEG,material,{'Ag/AgCl', 'Ag/AgCl', 'Ag/AgCl',...})
%
% Inputs :
%    EEG              -  EEG structure
% 
% Optional inputs:
%   'material'        - Cell array with dimensions of number of channels in
%                       EEG set by one. Material of the electrode, e.g., Tin,
%                        Ag/AgCl, Gold. Default: None
%   'impedance'       - Array or cell array with dimensions of number of channels
%                       in EEG set by one. Impedance for each electrode in
%                       kOhm. Default: None
%   'coordsystem'     - String. Refers to the coordinate system in which the 
%                       EEG electrode positions are to be interpreted 
%                       (EEGCoordinateSystem in BIDS specification). Default: 'RAS'
%   'coordunits'      - String. Units in which the coordinates that are listed
%                       in the field EEGCoordinateSystem are represented 
%                       (e.g., "mm", "cm").(EEGCoordinateUnits in BIDS specification).
%                       Default: 'mm'
%  'coorsystdescript' - String.Free-form text description of the coordinate . 
%                       system. May also include a link to a documentation page
%                       or paper describing the system in greater detail.
%                       Default: 'Right-Anterior-Superior corresponding to X, Y and Z'
%
% Outputs: None
%   
% Authors: Cyril Pernet - LIMO Team, University of Edinburgh
%
function electrodes_to_tsv(EEG,varargin)

% FORMAT electrodes_to_tsv(EEG,varargin)
% electrode.tsv

try
    options = varargin;
    if ~isempty( varargin )
        if ~ischar(options{1}), options = options{1}; end
        for i = 1:2:numel(options)
            g.(options{i}) = options{i+1};
        end
    else, g= []; end
catch
    disp('electrodes_to_tsv() error: calling convention {''key'', value, ... } error'); return;
end
SystDefault = 'Right-Anterior-Superior corresponding to X, Y and Z';

try g.material;              catch, g.material         = '';           end % material
try g.impedance;             catch, g.impedance        = '';           end % impedance
try g.coordsystem;           catch, g.coordsystem      = 'RAS';        end % EEGCoordinateSystem
try g.coordunits;            catch, g.coordunits       = 'mm';         end % EEGCoordinateUnits
try g.coorsystdescript;      catch, g.coorsystdescript = SystDefault;  end % EEGCoordinateSystemDescription

ename = cell(1,size(EEG.chanlocs,2));  ename(:) = {'n/a'};
x = ename; y = ename; z = ename; type = ename; 
for electrode = 1:size(EEG.chanlocs,2)
    if ~isempty(EEG.chanlocs(electrode).labels),ename{electrode} = EEG.chanlocs(electrode).labels;  end
    if ~isempty(EEG.chanlocs(electrode).X),     x{electrode}     = EEG.chanlocs(electrode).X;       end
    if ~isempty(EEG.chanlocs(electrode).Y),     y{electrode}     = EEG.chanlocs(electrode).Y;       end
    if ~isempty(EEG.chanlocs(electrode).Z),     z{electrode}     = EEG.chanlocs(electrode).Z;       end
    if ~isempty(EEG.chanlocs(electrode).type),  type{electrode}  = EEG.chanlocs(electrode).type;    end
end

% Updating with optional fields
optfields = {'material', 'impedance'};
string1   = 't = table(ename'',x'',y'',z'',type''';
for i=1:length(optfields)
    if ~isempty(g.(optfields{i})) && length(g.(optfields{i})) == length(x)
        string1 = [string1 ',g.' optfields{i}];
    end
end

string2    = ',''VariableNames'',{''name'',''x'',''y'',''z'',''type''';
for i=1:length(optfields)
    if ~isempty(g.(optfields{i})) && length(g.(optfields{i})) == length(x)
        string2 = [string2 ',''' optfields{i} ''''];
    end
end

% Creating table and writing files
evalstring = [string1 string2 '});'];
eval(evalstring); % t = table(ename',x',y',z',type','VariableNames',{'name','x','y','z','type'});

electrodes_tsv_name = [EEG.filepath filesep EEG.filename(1:strfind(EEG.filename,'run-')-1) 'electrodes.tsv'];
writetable(t,electrodes_tsv_name,'FileType','text','Delimiter','\t');

% coordsystem.json
json = struct('EEGCoordinateSystem',g.coordsystem, 'EEGCoordinateUnits',g.coordunits, 'EEGCoordinateSystemDescription',g.coorsystdescript);
jsonwrite([EEG.filepath filesep EEG.filename(1:strfind(EEG.filename,'run-')-1) 'electrodes.json'],json,struct('indent','  '));