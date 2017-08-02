%{
cont.MotionParams (manual) # params for computing motion index

bw = 5: double  # window in sec for computing motion index
---

%}

classdef MotionParams < dj.Relvar
    properties(Constant)
        table = dj.Table('cont.MotionParams');
    end
    
    methods
        function self = MotionParams(varargin)
            self.restrict(varargin{:})
        end
    end
end