%{
cont.Fp (computed) # local field filtered at 0.1-5000Hz
-> acq.Ephys
-> cont.Chan
-> cont.FpParams
---
fp_file                     : varchar(255)                  # name of file containg field potential
sampling_rate               : double                        # sampling rate of trace
%}

classdef Fp < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cont.Fp');
        popRel = acq.Ephys * cont.FpParams * (cont.Chan-cont.ChanIgnore);
    end
    
    methods
        function self = Fp(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            tuple = key;
            sourceFolder = fetch1(acq.Ephys(key), 'ephys_path');
            [~,ephysFolder] = fileparts(sourceFolder);
            chName = fetch1(cont.Chan(key),'chan_name');
            tuple.fp_file = fullfile('y:\ephys\processed\',ephysFolder,[sprintf('cont/fp_%s',chName) '_%d']);
            outFile = getLocalPath(tuple.fp_file);           
            
            cscFile = fullfile(sourceFolder,[chName,'.ncs']);
            Fs = extractSingleChanFp(baseReaderNeuralynx(cscFile), key.cutoff_freq, outFile, chName );
            tuple.sampling_rate = Fs;
            self.insert(tuple);
        end
    end
end
