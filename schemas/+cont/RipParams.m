%{
cont.RipParams (manual) # Parameters being used ripple detection

cutoff_low=600: double # low cutoff frequency
cutoff_high=6000: double # high cutoff frequency
transband_low = 200: double # transition band size in Hz on the low side
transband_high = 200: double # transition band size in Hz on the high side
---
%}

classdef RipParams < dj.Relvar
    properties(Constant)
        table = dj.Table('cont.RipParams');
    end
    
    methods 
        function self = RipParams(varargin)
            self.restrict(varargin{:})
        end
    end
end
