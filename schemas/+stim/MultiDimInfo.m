%{
stimulation.MultiDimInfo (computed) # A scan site

->stimulation.StimTrialGroup
---
num_orientations     : int unsigned   # number of orientations
orientations         : longblob       # number of orientations
speed                : double         # speed of the grating
sinusoidal           : bool           # if it is a sinusoidal grating
block_design         : bool           # if it is a block design
%}

classdef MultiDimInfo < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('stimulation.MultiDimInfo');
        popRel = pro(stimulation.StimTrialGroup & acq.Stimulation('exp_type="MultDimExperiment" OR exp_type="MouseMultiDim"'), stimulation.StimTrials, 'count(1) -> num_trials') & 'num_trials >= 10';
    end
    
    methods 
        function self = MultiDimInfo(varargin)
            self.restrict(varargin{:})
        end
        
        function [sorted conditions time] = trialAodTraces( this, traces )
            
            pre_time = 1000;
            assert(count(this & acq.AodStimulationLink(traces)) == 1, 'Need one MultiDimInfo matching the traces');
            
            event = fetch(stimulation.StimTrialEvents(this, 'event_type="showSubStimulus"'),'*');
            trials = fetch(stimulation.StimTrials(this));
            trial_conditions = fetch(stimulation.StimTrials(trials),'*');
            trial_conditions = arrayfun(@(x) x.trial_params.conditions, trial_conditions);
            
            conditions = fetch(stimulation.StimConditions(this),'*');
            assert(length(event) == length(trials), 'Code not written for multiple presentations');
            
            fs = traces(1).fs;
            trace_t = traces(1).t0 + 1000 * (0:length(traces(1).trace)-1) / fs;            
            trace_data = cat(2,traces.trace);
                        
            for i = 1:length(conditions)
                
                trial_idx = find(trial_conditions == conditions(i).condition_num);

                for j = 1:length(trial_idx)
                    this_trial = fetch(stimulation.StimTrials(trials(trial_idx(j))));
                	on_time = fetch1(stimulation.StimTrialEvents(this_trial, 'event_type="showStimulus"'),'event_time') - pre_time;
                    off_time = fetch1(stimulation.StimTrialEvents(this_trial, 'event_type="endStimulus"'),'event_time');
    
                    idx = find(trace_t >= on_time & trace_t <= off_time);
                    t = (0:length(idx)-1) / fs; % in seconds
                
                    if off_time > trace_t(end) || on_time < trace_t(1), continue; end
                    sorted{i}{j} = trace_data(idx,:);
                end
                
                % Remove any trials that weren't populated
                sorted{i}(cellfun(@isempty, sorted{i})) = [];
                
                min_len = min(cellfun(@(x) size(x,1), sorted{i}));
                sorted{i} = cellfun(@(x) x(1:min_len, :), sorted{i}, 'UniformOutput', false);
                sorted{i} = cat(3,sorted{i}{:});
            end
            
            conditions = [conditions.condition_info];
            time = -pre_time + (0:min_len-1) / fs;
        end
    end
    
    methods (Access=protected)
        function makeTuples( this, key )
            % Import a spike set
            tuple = key;
            
            stimInfo = fetch(stimulation.StimTrialGroup(key), '*');
            tuple.orientations = stimInfo.stim_constants.orientation;
            tuple.num_orientations = length(tuple.orientations);
            tuple.speed = stimInfo.stim_constants.speed;
            sub_stim = fetch(pro(stimulation.StimTrials, stimulation.StimTrialEvents(key, 'event_type="showSubStimulus"'),'COUNT(trial_num)->num_sub_stim'),'*');
            
            tuple.block_design = max([sub_stim.num_sub_stim]) == 1;
            if ~isfield(stimInfo.stim_constants, 'sinusoidal')
                tuple.sinusoidal = 1;
            else
                tuple.sinusoidal = stimInfo.stim_constants.sinusoidal;
            end

            insert(this,tuple);         
        end
    end
    
    methods
        function [G startTime endTime oris] = makeDesignMatrix(self, times)
            % This method needs an array of stimulus condition numbers and
            % onset/offset times
            
            assert(count(self) == 1, 'Only for one stimulus');
                        
            trials = fetch(stimulation.StimTrials & self);
            conditions = fetch(stimulation.StimConditions & self,'*');
            
            oris = unique(arrayfun(@(x) x.orientation, [conditions.condition_info]));
            
            disp 'constructing design matrix...'
                        
            stimTime = 100;
            numSplines = 10;
            G = zeros(length(times), length(oris) * numSplines);

            for i = 1:length(trials)
                trial_info = fetch1(stimulation.StimTrials(trials(i)), 'trial_params');
                event = fetch(stimulation.StimTrialEvents(trials(i), 'event_type="showSubStimulus"'),'*');
                onsets = double(sort([event.event_time]));
                for j = 1:length(onsets)
                    cond = trial_info.conditions(j);
                    onset = onsets(j);
                    ori = conditions(cond).condition_info.orientation;
                    condIdx = find(ori == oris);
                    
                    for k = 1:numSplines
                        idx = times >= onset + stimTime*(k-1) & times < onset + stimTime*k;
                        G(idx, k+(condIdx-1)*numSplines) = 1;
                    end
                end
            end
            
            startTime = fetch1(pro(stimulation.StimTrialEvents, stimulation.StimTrialGroup & self, 'MIN(event_time)->time'),'time');
            endTime = fetch1(pro(stimulation.StimTrialEvents, stimulation.StimTrialGroup & self, 'MAX(event_time)->time'),'time');
        end
    end
    
end
