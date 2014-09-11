%{
acq.Subjects (manual)       # list of subjects
subject_id   : int unsigned # unique identifier for subject
---
subject_type: enum('mouse','rat') # mouse or rat
%}

classdef Subjects < dj.Relvar
    properties(Constant)
        table = dj.Table('acq.Subjects');
    end
    
    methods 
        function self = Subjects(varargin)
            self.restrict(varargin{:})
        end
    end
end
