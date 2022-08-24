function result = makematrices(r, makeords)
import stitchit.yaml.*;
result = recurse(r, 0, [], makeords);
end
function result = recurse(data, level, addit, makeords)
import stitchit.yaml.*;
if iscell(data)
        result = iter_cell(data, level, addit, makeords);
    elseif isstruct(data)
        result = iter_struct(data, level, addit, makeords);
    else
        result = scan_data(data, level, addit);
    end;
end
function result = iter_cell(data, level, addit, makeords)
import stitchit.yaml.*;
if  isvector(data) &&         iscell_all(data) &&         isvector_all(data) &&         isaligned_all(data) &&         ismatrixrow_all(data)
        tmp = data;
        tmp = cellfun(@cell2mat, tmp, 'UniformOutput', 0);
        tmp = cellfun(@torow, tmp, 'UniformOutput', 0);
        tmp = tocolumn(tmp);
        tmp = cell2mat(tmp);
        if ~makeords
            tmp = num2cell(tmp);
        end;
        result = tmp;
    elseif isempty(data)
        result = [];
    else   
        result = {};
        for i = 1:length(data)
            result{i} = recurse(data{i}, level + 1, addit, makeords);
        end;
    end;
end
function result = iter_struct(data, level, addit, makeords)
import stitchit.yaml.*;
result = struct();
    for i = fields(data)'
        fld = char(i);
        result.(fld) = recurse(data.(fld), level + 1, addit, makeords);
    end;
end
function result = scan_data(data, level, addit)
import stitchit.yaml.*;
result = data;
end
function result = iscell_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@iscell, cellvec));
end
function result = isaligned_all(cellvec)
import stitchit.yaml.*;
siz = numel(cellvec{1});
    result = all(cellfun(@numel, cellvec) ==  siz);
end
function result = ismatrixrow_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@ismatrixrow, cellvec));
end
function result = ismatrixrow(cellvec)
import stitchit.yaml.*;
result =         (isnumeric_all(cellvec) || islogical_all(cellvec) || isstruct_all(cellvec)) &&         issingle_all(cellvec) &&         iscompatible_all(cellvec);
end
function result = isnumeric_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@isnumeric, cellvec));
end
function result = islogical_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@islogical, cellvec));
end
function result = issingle_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@issingle, cellvec));
end
function result = iscompatible_all(cellvec)
import stitchit.yaml.*;
result = true;
    for i = 1:(length(cellvec) - 1)
        result = result && iscompatible(cellvec{i}, cellvec{i + 1});
    end
end
function result = iscompatible(obj1, obj2)
import stitchit.yaml.*;
result = isequal(class(obj1), class(obj2));
end
function result = isvector_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@isvector, cellvec));
end
function result = isstruct_all(cellvec)
import stitchit.yaml.*;
result = all(cellfun(@isstruct, cellvec));
end
function result = torow(vec)
import stitchit.yaml.*;
result = tocolumn(vec).';
end
function result = tocolumn(vec)
import stitchit.yaml.*;
result = vec(:);
end
