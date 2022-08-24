function result = ismymatrix(obj)
import stitchit.yaml.*;
result = ndims(obj) == 2 && all(size(obj) > 1);
end
