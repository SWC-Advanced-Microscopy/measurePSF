function result = isord(obj)
import stitchit.yaml.*;
result = ~iscell(obj) && any(size(obj) > 1);
end
