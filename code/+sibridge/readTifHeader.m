function header = readTiffHeader(fname)
    % Return ScanImage TIFF header as a structure
    %
    % H = sibridge.readTiffHeader(fname)
    %
    % Purpose
    % Return ScanImage TIFF header as a structure. Returns empty
    % in the event of failure.
    %
    % Inputs
    % fname - relative or absolute path to a ScanImage TIFF stack on disk
    %
    % Outputs
    % header - sturcture containing the data. Returns only data from the first frame. 
    %
    %
    % Rob Campbell - January 2020, SWC, London


    header=[];
    if ~exist(fname,'file')
        return
    end

    tmp=imfinfo(fname);

    if isempty(tmp) || ~isstruct(tmp) || ~isfield(tmp,'Software')
        return
    end

    header = parse_si_header(tmp(1),'Software');
end


function si_metadata = parse_si_header(tiff_header, si_fields)
    % PARSE_SI_HEADER extract ScanImage related information from TIFF headers
    %
    % si_metadata = isbridge.parse_si_header(tiff_header)
    %
    % This function filters a field of TIFF frames header where ScanImage dumps
    % its metadata.
    %
    % INPUTS
    %   tiff_header - TIFF images header, as a structure array
    %   si_fields - (optional) default: 'ImageDescription'
    %       field(s) of 'tiff_header' used to retrieve ScanImage metadata, as a
    %       string or a cellarray of strings
    %
    % OUTPUTS
    %   si_metadata - ScanImage metadata, as a structure array with the same
    %       shape as 'tiff_header' or empty
    %
    % REMARKS
    %   Fields of the returned structure highly depend on the version of
    %   ScanImage and the TIFF header field parsed (e.g. ImageDescription or
    %   Software).
    %
    %   This function will fail if several parsed fields contain one sub-field
    %   with the same name.
    %
    % EXAMPLES:
    % Read the "Software" field
    % A=sibridge.parse_si_header(T(1),'Software');
    %
    % Read both the 'ImageDescription' and  `Software` fields
    % sibridge.parse_si_header(T(1),{'ImageDescription','Software'})



    % check inputs
    if ~exist('tiff_header', 'var')
        error('Missing stacks argument');
    else
        validateattributes(tiff_header, {'struct'}, {}, '', 'tiff_header');
    end

    if ~exist('si_fields', 'var')
        si_fields = {'ImageDescription'};
    elseif ~iscell(si_fields)
        si_fields = {si_fields};
    end

    nfields = numel(si_fields);
    for ii = 1:nfields
        validateattributes( ...
            si_fields{ii}, {'char'}, {'nonempty'}, '', 'si_fields');
    end

    % parse each field
    si_metadata = cell(1, nfields);
    for ii = 1:nfields
        si_field = si_fields{ii};

        if ~isfield(tiff_header, si_field)
            warning('Input TIFF headers have no field named ''%s''', si_field);
            continue;
        end

        si_metadata{ii} = parse_field(tiff_header, si_field);
    end

    % remove empty elements
    mask = ~cellfun(@isempty, si_metadata);
    si_metadata = si_metadata(mask);

    % return empty structure if no field were parsed
    if isempty(si_metadata)
        si_metadata = struct();

    % or merge retrieved metadata into one structure
    else
        metadata_fields = cellfun(@fieldnames, si_metadata, 'un', false);
        metadata_fields = cat(1, metadata_fields{:});
        metadata_values = cellfun(@struct2cell, si_metadata, 'un', false);
        metadata_values = cat(1, metadata_values{:});
        si_metadata = cell2struct(metadata_values, metadata_fields, 1);
    end
end

function si_metadata = parse_field(tiff_header, si_field)
    % parse one field of TIFF headers to populate a structure

    % create a struct and fill fields for each frame
    si_metadata = struct([]);

    for i_img = 1:numel(tiff_header)
        % split fields (key = value) of each line
        tokens = regexp(tiff_header(i_img).(si_field), ...
            '([a-zA-Z]\w+?) = ([^<]+?)\n', 'tokens');

        % create empty structure if some frames have already been parsed
        if isempty(tokens) && ~isempty(si_metadata)
            si_fields = fieldnames(si_metadata);
            si_metadata(i_img).(si_fields{1}) = [];
        end

        % convert field value and add it to the structure
        for i_tok = 1:numel(tokens)
            fieldname = tokens{i_tok}{1};
            string_value = tokens{i_tok}{2};

            if startsWith(string_value,'scanimage')
                % Avoids certain errors
                si_metadata(i_img).(fieldname) = string_value;
            else
                si_metadata(i_img).(fieldname) = eval(string_value);
            end
        end
    end

    si_metadata = reshape(si_metadata, size(tiff_header));
end
