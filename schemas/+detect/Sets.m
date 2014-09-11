%{
detect.Sets (imported) # Set of electrodes to detect spikes

-> detect.Params
---
detect_set_path : VARCHAR(255) # folder containing spike files
%}

classdef Sets < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('detect.Sets');
        popRel = detect.Params;
    end
    
    methods
        function self = Sets(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(~, key)
            switch fetch1(detect.Params(key) * detect.Methods, 'detect_method_name')
                case 'TetrodesV2'
                    spikesCb = @spikesTetrodesV2;
                    spikesFile = 'Sc%d.Htt';
                    %                     lfpCb = @extractLfpTetrodes;
                    lfpCb = [];
            end
            
            
            % if not in toolchain mode, don't extract LFP
            if ~fetch1(detect.Params(key), 'use_toolchain')
                lfpCb = [];
            end
            
            processSet(key, spikesCb, spikesFile, lfpCb);
        end
    end
end
