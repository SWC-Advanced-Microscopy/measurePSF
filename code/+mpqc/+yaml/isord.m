function result = isord(obj)
import mpqc.yaml.*;
result = ~iscell(obj) && any(size(obj) > 1);
end
