%{
acq.Resistors (manual) # list of resistors used for measuring DC current stim

-> acq.Sessions
ohms: double              # resistance in ohms
---
resistors_ts=CURRENT_TIMESTAMP: timestamp             # automatic timestamp. Do not edit

%}

classdef Resistors < dj.Relvar
    properties(Constant)
        table = dj.Table('acq.Resistors');
    end
    
    methods
        function self = Resistors(varargin)
            self.restrict(varargin{:})
        end
    end
end
