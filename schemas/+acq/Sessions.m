%{
acq.Sessions (manual) # list of sessions

-> acq.Animals

session_start_time: bigint              # start session timestamp

---

session_stop_time           : bigint                        # end of session timestamp
experimenter                : enum('Mani','Theo','Billy')# name of person running exp
session_path                : varchar(255)                  # path to the data
session_datetime=null       : datetime                      # readable format of session start
room_num                    : varchar(24)      # room number where exp happened
acq_system="Neuralynx": enum('Neuralynx','Plexon') # data acq system

%}

classdef Sessions < dj.Relvar
    properties(Constant)
        table = dj.Table('acq.Sessions');
    end
    
    methods
        function self = Sessions(varargin)
            self.restrict(varargin{:})
        end
        
        function offset = getTimeOffset(self)
            % Timezone offset (in ms) between session_start_time (in UTC)
            % and local time for session matching the tuple in relvar self.
            [utc, local] = fetch1(self, 'session_start_time', 'session_datetime');
            utc = datenum('01-Jan-1904') + double(utc) / 1000 / 60 / 60 / 24;
            local = datenum(local);
            offset = round((local - utc) * 24) * 60 * 60 * 1000;
        end
    end
end
