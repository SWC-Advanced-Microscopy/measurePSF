function result = ismymatrix(obj)
import mpqc.yaml.*;
result = ndims(obj) == 2 && all(size(obj) > 1);
end
