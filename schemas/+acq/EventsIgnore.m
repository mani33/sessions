%{
acq.EventsIgnore (manual)       # events to ignore for whatever reason
->acq.Events
%}

classdef EventsIgnore < dj.Relvar
    properties(Constant)
        table = dj.Table('acq.EventsIgnore');
    end
    
    methods 
        function self = EventsIgnore(varargin)
            self.restrict(varargin{:})
        end
    end
end
