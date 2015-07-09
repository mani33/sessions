%{
cont.FpParams (manual) # Parameters being used field potential filtering

cutoff_freq: double # low pass cutoff frequency

---
%}

classdef FpParams < dj.Relvar
    properties(Constant)
        table = dj.Table('cont.FpParams');
    end
    
    methods 
        function self = FpParams(varargin)
            self.restrict(varargin{:})
        end
    end
end
