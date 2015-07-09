%{
cont.StParams (manual) # Parameters being used spike trace filtering

cutoff_low=600: double # low cutoff frequency
cutoff_high=6000: double # high cutoff frequency
transband_low = 200: double # transition band size in Hz on the low side
transband_high = 200: double # transition band size in Hz on the high side
---
%}

classdef StParams < dj.Relvar
    properties(Constant)
        table = dj.Table('cont.StParams');
    end
    
    methods 
        function self = StParams(varargin)
            self.restrict(varargin{:})
        end
    end
end
