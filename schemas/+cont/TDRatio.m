%{
cont.TDRatio (computed) # Theta-Delta Ratio

-> cont.Chan
-> acq.Sessions
---

theta_data:   longblob   #theta wave activity
delta_data:   longblob   #delta wave activity
td_ratio:     longblob   #ration of theta wave to delta wave activity
t       :   longblob     #collected time
%}

classdef TDRatio < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cont.TDRatio');
        popRel = acq.Sessions * cont.Chan;
    end
    
    methods
        function self = TDRatio(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            tuple = key;
            br = baseReaderNeuralynx(fetch1(cont.Chan(key), 'chan_filename'));
            i = 1;
            tdr = [];
            t = [];
            theta = [];
            delta = [];
            sam_int = getSamplingRate(br)*5;
            n = getNbSamples(br);
            while i + sam_int < n - sam_int
                x = br(i: i + sam_int, 1);
                delta(end + 1) = bandpower(x,32000,[1 4]);
                theta(end + 1) = bandpower(x, 32000, [4,8]);
                tdr(end + 1) = theta(end)/delta(end);
                t(end + 1) = br(i, 't') ;
                displayProgress(i, n/sam_int)
                i = i + sam_int;
            end
            tuple.theta_data = theta;
            tuple.delta_data = delta;
            tuple.t = t;
            tuple.td_ratio = tdr;   
            self.insert(tuple);
        end
        
    end
end
