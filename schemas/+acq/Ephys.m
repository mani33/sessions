%{
acq.Ephys (manual)       # electrophysiology recordings

->acq.Sessions
ephys_start_time       : bigint       # start session timestamp
---
ephys_stop_time        : bigint       # end of session timestamp
ephys_path             : varchar(256) # path to the ephys data
recording_software     : varchar(256) # name of the recording software with version number
%}



classdef Ephys < dj.Relvar
    properties(Constant)
        table = dj.Table('acq.Ephys');
    end
    
    methods 
        function self = Ephys(varargin)
            self.restrict(varargin{:})
        end
        
        function fn = getFileName(self)
            % Return name of data file matching the tuple in relvar self.
            %   fn = getFileName(self)
            ephysPath = fetch1(acq.Sessions * self, 'ephys_path');
            fn = findFile(RawPathMap, ephysPath);
        end
        
        function br = getFile(self, varargin)
            % Open a reader for the ephys file matching the tuple in self.
            %   br = getFile(self)
            br = baseReader(getFileName(self), varargin{:});
        end
        
        function time = getHardwareStartTime(self)
            % Get the hardware start time for the tuple in relvar
            %   time = getHardwareStartTime(self)
            cond = sprintf('ABS(timestamper_time - %ld) < 5000', fetch1(self, 'ephys_start_time'));
            rel = acq.SessionTimestamps(cond) & acq.TimestampSources('source = "Ephys"') & (acq.Sessions * self);
            time = acq.SessionTimestamps.getRealTimes(rel);
        end
    end
end
