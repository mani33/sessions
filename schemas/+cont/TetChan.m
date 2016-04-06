%{
cont.TetChan (manual) # specify which channels belong to a given tetrode
-> acq.Ephys
tet_num : tinyint unsigned # tetrode number 1,2,...
-----
chan_nums: blob # channel numbers that make up a tetrode eg. [1 2 3 4]
%}

classdef TetChan < dj.Relvar
    properties(Constant)
        table = dj.Table('cont.TetChan');
    end
    
    methods
        function self = TetChan(varargin)
            self.restrict(varargin{:})
        end
    end
end