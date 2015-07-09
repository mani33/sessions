%{
cont.Chan (imported) # select channels for extracting continuous traces

->acq.Ephys
chan_num: tinyint unsigned # A/D channel number starts from 0
---
chan_name: varchar(24) # name of the channel such as t1c1
chan_filename: varchar(256) # file location of raw data
%}

classdef Chan < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cont.Chan');
        popRel = acq.Ephys;
    end
    
    methods
        function self = Chan(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)            
            % Get all tetrode channels
            ep = fetch1(acq.Ephys(key),'ephys_path');
            d = dir(fullfile(ep,'t*c*.ncs'));
            d = {d.name};
            cnames = regexp(d,'(t[0-9]{1}c[0-9]{1})','tokens');
            cnames = [cnames{:}]; cnames = [cnames{:}];
            n = length(cnames);
            for i = 1:n
                tuple = key;
                cna = cnames{i};
                fn = fullfile(ep,[cna '.ncs']);
                % Get the A/D channel number from header
                [~, h] = Nlx2MatCSC(fn, [1 0 0 0 0],1, 3, 1);
                cnum = regexp(h,'-ADChannel[\s]+([0-9]{1,3})','tokens');
                cnum = [cnum{:}]; cnum = str2double([cnum{:}]);
                tuple.chan_num = cnum;
                tuple.chan_name = cna;
                tuple.chan_filename = fn;
                self.insert(tuple);
            end
        end
    end
end