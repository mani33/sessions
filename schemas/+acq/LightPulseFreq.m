%{
acq.LightPulseFreq (manual) # light pulse frequency used
-> acq.Sessions
light_pulse_freq: double              # light pulse freqency in Hz
---

%}

classdef LightPulseFreq < dj.Relvar
    properties(Constant)
        table = dj.Table('acq.LightPulseFreq');
    end
    
    methods
        function self = LightPulseFreq(varargin)
            self.restrict(varargin{:})
        end
    end
end