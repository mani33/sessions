%{
aod.Traces (imported) # A scan site

->aod.TraceSet
cell_num        : int unsigned      # The cell number
---
x               : float             # X coordinate
y               : float             # Y coordinate
z               : float             # Z coordinate
trace           : longblob          # The unfiltered trace
t0              : double            # The starting time
fs              : double            # Sampling rate
%}

classdef Traces < dj.Relvar
    properties(Constant)
        table = dj.Table('aod.Traces');
        offset = -800 * 600;
    end
    
    methods 
        function self = Traces(varargin)
            self.restrict(varargin{:})
        end
        
        function makeTuples( this, key, asr )
            % Import a spike set
            
            disp(sprintf('Importing traces from %d cells', size(asr,2)));

            dat = asr(:,:);
            dat = dat - this.offset;
            coordinates = asr.coordinates;
            
            m = mean(dat,1);
            v = var(dat,[],1);
            r = robustfit(m,v);
            
            % Make sure the parameters are something reasonable
            if abs(r(2) - 500) > 200 || abs(r(1) / r(2)^2) > 50
                r = [0 500];
            end
            
            dat  =( dat + r(1)/r(2) ) / r(2);
                        
            for i = 1:size(dat,2)
                tuple = key;
                
                tuple.cell_num = i;
                tuple.x = double(coordinates(i,1));
                tuple.y = double(coordinates(i,2));
                tuple.z = double(coordinates(i,3));
                tuple.trace = dat(:,i); % - this.offset;
                tuple.t0 = asr(1,'t');
                tuple.fs = getSamplingRate(asr);
            
                insert(this,tuple);
            end

        end
        function times = getTimes( this )
            % Get the times for the selected traces, ensuring they are
            % identical
            
            assert(count(this) >= 1, 'No traces selected');

            [t0 fs] = fetchn(this, 't0', 'fs');
            assert(unique(t0) == t0(1) && unique(fs) == fs(1), 'Traces with different times selected');
            t0 = unique(t0);
            fs = unique(fs);
            keys = fetch(this);
            trace = fetch1(this & keys(1), 'trace');
            
            times = t0 + (0:length(trace)-1) * 1000 / fs;
        end
                
    end
end
