%{
cont.Motion (computed) # Motion tracking data

-> cont.MotionParams
-> acq.Sessions
---

dist_var:   longblob   #variance of the distance from the origin
t       :   longblob   #middle bin time (s)
%}

classdef Motion < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cont.Motion');
        popRel = acq.Sessions * cont.MotionParams;
    end
    
    methods
        function self = Motion(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            tuple = key;
            bws = key.bw; % sec bin width for motion analysis
            bw = bws*1e6;
            fn = fullfile(fetch1(acq.Sessions(key),'session_path'),'VT1.nvt');
            ets = double(fetchn(acq.Events(key,'event_ttl in (1,128)'),'event_ts'));
            tmin = min(ets);
            tmax = max(ets);
            nSeg = floor((tmax-tmin)/bw);
            for iSeg = 1:nSeg
                t1 = (iSeg-1)*bw;
                t2 = (iSeg * bw);
                tbound = tmin + [t1 t2];
                [t, x, y] = Nlx2MatVT(char(fn),[1 1 1 0 0 0], 0, 4, tbound);
                posvar = (std_robust(x))^2 + (std_robust(y))^2;
                tuple.t(iSeg) = mean(t);
                tuple.dist_var(iSeg) = posvar;
                displayProgress(iSeg,nSeg, 'Populating cont.Motion')
            end
            self.insert(tuple);
        end
        
    end
end

