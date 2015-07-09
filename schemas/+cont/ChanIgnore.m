%{
cont.ChanIgnore (manual) # channels to ignore because of their uselessness
-> cont.Chan
-----
%}

classdef ChanIgnore < dj.Relvar
    properties(Constant)
        table = dj.Table('cstim.PeriEventTimes');
    end
     methods
        function self = ChanIgnore(varargin)
            self.restrict(varargin{:})
        end
    end
end