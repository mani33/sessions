%{
acq.Events (imported)       # events from Neuralynx Events.nev file

->acq.Sessions
event_ts       : bigint       # event timestamp
event_ttl: double # value of the TTL pulse
---
event_port: double # port number
event_str: varchar(512) # event string
%}

classdef Events < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('acq.Events');
        popRel = acq.Sessions
    end
    
    methods
        function self = Events(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            ep = fetch1(acq.Sessions(key),'session_path');
            events_file = fullfile(ep,'Events.nev');
            FieldSelectionFlags = [1 0 1 0 1];
            [ts,ttl,es] = Nlx2MatEV(events_file,FieldSelectionFlags,0,1,[]);
            n = length(ts);  
            
            for i = 1:n
                pn = regexp(es{i},'port ([0-9])','tokens');
                if ~isempty(pn)
                    pn = str2double([pn{:}]);
                end
                if isempty(pn)
                    pn = -1;
                elseif pn==0
                    continue
                else
                    assert((pn==1)|(pn==2),'wrong port')
                end
                tuple = key;
                tuple.event_ts = ts(i);
                tuple.event_ttl = ttl(i);
                tuple.event_str = es{i};
                tuple.event_port = pn;
                self.insert(tuple);
            end
        end
    end
end

