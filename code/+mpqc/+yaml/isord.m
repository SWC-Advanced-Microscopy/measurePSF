function result = isord(obj)
import mpsf.yaml.*;
result = ~iscell(obj) && any(size(obj) > 1);
end
