function [dir_to_folder, file_list] = getHALOfileList(site,DATE,processlev,measmode,typeof)
%getHALOfileList generates a list of HALO file names measured with a given
% measurement mode and with a given processing level. Also outputs full path to files.
%
% Usage:
% [~, file_list] = getHALOfilelist(site,DATE,processlev,measmode)
% [dir_to_folder,~] = getHALOfileList(site,DATE,processlev,measmode)
% [dir_to_folder, file_list] = getHALOfileList(site,DATE,processlev,measmode)
% [dir_to_folder, file_list] = getHALOfileList(site,DATE,processlev,measmode,typeof)
%
% Inputs:
% - site            string, name of the site, e.g. 'kuopio'
% - DATE            scalar, numerical date, e.g. 20171231
% - processlev      string, 'corrected','original','calibrated','background','product'
% - measmode        string, 'stare','vad','rhi','co','custom','windvad','winddbs','txt','nc','wstats',
%                   'TKE','sigma2vad','windshear','LLJ','ABLclassification','cloud'
% - typeof          string, 'co', 'eleXX', 'aziXXX'
%
% Outputs:
% - dir_to_folder   full path to the folder 
% - fille_list      cell array of string,  file names for the site,
%                   measurement mode and processing level
%
% Created 2017-10-20
% Antti Manninen
% antti.j.manninen(at)helsinki.fi
% University of Helsinki, Finland

% Check inputs
if nargin < 4
    error(sprintf(['At least inputs ''site'', ''DATE'', ''processlev'', and ''measmode'''...
        ' are required for the products: \n''TKE'', ''wstats'', ''wstats4precipfilter'', ''sigma2vad''',...
        '''windshear'', ''LLJ'', ''ABLclassification'', ''cloud''']))
end
if nargin == 4 && (strcmp(processlev,'product') && any(strcmp(measmode,{'TKE',...
        'wstats','wstats4precipfilter','sigma2vad','windshear','LLJ','ABLclassification','cloud','betavelocovariance'})) || ...
        strcmp(processlev,'background'))
    if ~ischar(site)
        error('The 1st input ''site'' must be a string.')
    end
    if ~isnumeric(DATE) || length(num2str(DATE))~=8
        error(['The 2nd input ''DATE'' must be a numerical date in' ...
            ' YYYYMMDD format.'])
    end
    if ~ischar(processlev) || ~any(strcmp(processlev,{'original','corrected','calibrated','background','product'}))
        error(['The 3rd input ''processlev'' must be a string and can be:'...
            ' ''original'', ''corrected'', ''calibrated'', ''background'', or ''product''.'])
    end
    if ~ischar(measmode) || ~any(strcmp(measmode,{'stare','vad','dbs','rhi','custom','co','windvad','winddbs',...
            'txt','nc','wstats','wstats4precipfilter','TKE','sigma2vad','windshear','LLJ','ABLclassification','cloud','betavelocovariance'}))
        error(sprintf(['The 4th input ''measmode'' must be a string and can be:\n'...
            '''stare'',''vad'',''dbs'',''rhi'',''co'',''custom'',''windvad'',''winddbs'',''txt'',''nc'',''wstats''\n'...
            '''wstats4precipfilter'',''TKE'',''sigma2vad'',''windshear'',''LLJ'',''ABLclassification'',''cloud'',''betavelocovariance''.']))
    end
end
if nargin < 5 && (~strcmp(processlev,'product') && ~any(strcmp(measmode,{'TKE',...
        'wstats','wstats4precipfilter','sigma2vad','windshear','LLJ','ABLclassification','cloud','betavelocovariance'})) && ...
        ~strcmp(processlev,'background'))
        error(sprintf(['Inputs ''site'', ''DATE'', ''processlev'', ''measmode'', and ''typeof'''...
            ' are required for ANY OTHER products than: \n''TKE'', ''wstats'', ''wstats4precipfilter'', ''sigma2vad'','...
            ' ''windshear'', ''LLJ'', ''ABLclassification'', ''cloud'',''betavelocovariance''']))
end
if nargin == 5
        if ~ischar(site)
            error('The 1st input ''site'' must be a string.')
        end
        if ~isnumeric(DATE) || length(num2str(DATE))~=8
            error(['The 2nd input ''DATE'' must be a numerical date in' ...
                ' YYYYMMDD format.'])
        end
        if ~ischar(processlev) || ~any(strcmp(processlev,{'original','corrected','calibrated','background','product'}))
            error(['The 3rd input ''processlev'' must be a string and can be:'...
                ' ''original'', ''corrected'', ''calibrated'', ''background'', or ''product''.'])
        end
        if ~ischar(measmode) || ~any(strcmp(measmode,{'stare','vad','dbs','rhi','co','custom','windvad','winddbs',...
                'txt','nc','wstats','wstats4precipfilter','TKE','sigma2vad','windshear','LLJ','ABLclassification','cloud','betavelocovariance'}))
            error(sprintf(['The 4th input ''measmode'' must be a string and can be:\n'...
                '''stare'',''vad'',''rhi'',''dbs'',''co'',''custom'',''windvad'',''winddbs'',''txt'',''nc'',''wstats''\n'...
                '''wstats4precipfilter'',''TKE'',''sigma2vad'',''windshear'',''LLJ'',''ABLclassification'',''cloud'',''betavelocovariance''.']))
        end        
end
% Get default and site/unit specific parameters
C = getconfig(site,DATE);

% Initialize
file_list = {};

% Convert the date into character array
thedate = num2str(DATE);

% check if path for given combination of 'processlev' and 'measmode' exist
switch nargin
  case 5
    cpmt = ['dir_' processlev '_' measmode '_' typeof]; % -C-.-p-rocesslev_-m-easmode -t-ypeof
  case 4
    cpmt = ['dir_' processlev '_' measmode]; % -C-.-p-rocesslev_-m-easmode -t-ypeof
end
if ~isfield(C,cpmt)
    error(['Can''t find parameter ''%s'' for the site ''%s'' \nand'...
        ' which would be valid for the date ''%s'' from halo_config.txt'...
        ' file.'], cpmt,site,num2str(DATE))
end

% Get directory to the folder
dir_to_folder = C.(cpmt);

% Replace/expand dates subdirectories as required
% find year, month, day wildcards
dir_to_folder = strrep(dir_to_folder,'+YYYY+',thedate(1:4));
dir_to_folder = strrep(dir_to_folder,'+MM+',thedate(5:6));
dir_to_folder = strrep(dir_to_folder,'+DD+',thedate(7:8));


% Generate path
switch processlev
 case 'original'
     file_naming = C.(['file_naming_original_' measmode '_' typeof]);
     file_format = C.file_format_after_hpl2netcdf;
     %   switch ~isempty(findstr(site,'arm-'))
     %    case 1 % ARM site
     %     file_names_2look4 = ['*' file_naming '*' thedate '*' file_format];
     %    case 0 % non-ARM site
     file_names_2look4 = ['*' thedate '*' file_naming  '*' file_format];
     % Check if empty , try other pattern     
     if isempty(dir([dir_to_folder,file_names_2look4]))
         file_names_2look4 = ['*' file_naming '*' thedate '*' file_format];
     end
     %    end
  case 'background'
    switch measmode
      case 'txt'
        file_format = '.txt';
        file_names_2look4 = ['*' thedate([7:8 5:6 3:4]) '*' ...
                            file_format];
      case 'nc'
        file_format = '.nc';
        file_names_2look4 = ['*' thedate '*' file_format];
    end
 otherwise
  % blindly assume that there are no other type of files
  % with the same naming in the same directory
  file_format = '.nc';
  file_names_2look4 = ['*' thedate '*' file_format];
end

direc = dir([dir_to_folder,file_names_2look4]);
if isempty(direc)
  file_list = [];
  if nargin < 5 && nargout == 1
      warning(['Can''t find ' processlev ' ' measmode ' Halo files for site ' site ' and date ' num2str(DATE) '!'])
  elseif nargout == 1
      warning(['Can''t find ' processlev ' ' measmode ' ' typeof ' Halo files for site ' site ' and date ' num2str(DATE) '!'])
  end      
else
    % Get list of files
    [file_list{1:length(direc),1}] = deal(direc.name);
    switch processlev
        case 'original'
            % More complex for AMR naming scheme..
            if length(site)>3 && strcmp(site(1:4),'arm-')
                % assume ARM file naming scheme, find data level indicator from the name
                b = cellfun(@(x) strfind(x,'.'),file_list,'UniformOutput',false);
                b1sts = cellfun(@(x) x(1),b)+2; % location of 1st dot plus 2 is data level
                fnids = nan(length(b1sts),1); % initialize
                for i = 1:length(b1sts),fnids(i) = str2double(file_list{i}(b1sts(i))); end
                % Select the files with lowest data level, i.e. original
                theuniqs = unique(fnids);
                if numel(theuniqs)>1
                    [~,imin] = min(theuniqs);
                    file_list = file_list(fnids == theuniqs(imin));
                end
                i_file = ~cellfun('isempty',strfind(file_list,...
                    C.(['file_naming_original_' measmode '_' typeof])));
                file_list = file_list(i_file);
                file_list = sort(file_list);
            else
                %Look for specific files based on the naming
                i_file = ~cellfun('isempty',strfind(file_list,...
                    file_naming));
                file_list = file_list(i_file);
                file_list = sort(file_list);
            end
        case 'corrected'
            % More complex for AMR naming scheme..
            if length(site)>3 && strcmp(site(1:4),'arm-')
                % assume ARM file naming scheme, find data level indicator from the name
                b = cellfun(@(x) strfind(x,'.'),file_list,'UniformOutput',false);
                b1sts = cellfun(@(x) x(1),b)+2; % location of 1st dot plus 2 is data level
                fnids = nan(length(b1sts),1); % initialize
                for i = 1:length(b1sts), fnids(i) = str2double(file_list{i}(b1sts(i))); end
                % Select the files with highest data level, i.e. latest
                theuniqs = unique(fnids);
                if numel(theuniqs)>1
                    [~,imax] = max(theuniqs);
                    file_list = file_list(fnids == theuniqs(imax));
                end
                i_file = ~cellfun('isempty',strfind(file_list,...
                    C.(['file_naming_original_' measmode '_' typeof])));
                file_list = file_list(i_file);
                file_list = sort(file_list);
            else
                %Look for specific files based on the naming
                i_file = ~cellfun('isempty',strfind(file_list,...
                    file_naming));
                file_list = file_list(i_file);
                file_list = sort(file_list);
            end
        otherwise
            % blindly assume that there are no other type of files
            % with the same naming in the same directory
            file_list = sort(file_list);
    end
end
end
