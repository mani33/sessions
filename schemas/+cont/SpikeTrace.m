%{
cont.SpikeTrace (computed) # spike trace filtered usually between 600-6000Hz

->acq.Ephys
->cont.StParams
->cont.Chan
---
spike_tr_file : VARCHAR(255) # name of file containg spike trace
%}

classdef SpikeTrace < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cont.SpikeTrace');
        popRel = acq.Ephys * cont.StParams * cont.Chan;
    end
    
    methods
        function self = SpikeTrace(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            tuple = key;
            sourceFolder = fetch1(acq.Ephys(key), 'ephys_path');
            [~,ephysFolder] = fileparts(sourceFolder);
            chName = fetch1(cont.Chan(key),'chan_name');
            tuple.spike_tr_file = fullfile('y:\ephys\processed\',ephysFolder,[sprintf('cont/spike_tr_%s',chName) '_%d']);
            outFile = getLocalPath(tuple.spike_tr_file);           
            
            cscFile = fullfile(sourceFolder,[chName,'.ncs']);
            extractSingleChanSpikeTrace(baseReaderNeuralynx(cscFile), key, outFile, chName )
            self.insert(tuple);
        end
    end
end