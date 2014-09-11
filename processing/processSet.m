function processSet(key, spikesCb, spikesFile, lfpCb)
% TODO: write documentation


parToolbox = logical(exist('matlabpool', 'file'));

assert(isfield(key, 'session_start_time') && isfield(key, 'ephys_start_time') && isfield(key, 'detect_method_num'), 'Incomplete primary key!')
assert(count(detect.Params(key)) == 1, 'Did not find a detection that matches this key!')
assert(~count(detect.Sets(key)), 'This set is already processsed. Delete it first if you want to reprocess.')

% determine folder and file names
sourceFile = fullfile(fetch1(acq.Ephys(key), 'ephys_path'),'t*c*.ncs');
processedDir = fetch1(detect.Params(key), 'ephys_processed_path');
localProcessedDir = processedDir;
detectMethod = fetch1(detect.Methods & detect.Params(key), 'detect_method_name');
spikesDir = fullfile('spikes', detectMethod);
lfpDir = 'lfp';
lfpFile = 'lfp%d';


% stage the files
destDir = localProcessedDir;

% If we need to process an LFP kick of these jobs now on a thread
if ~count(cont.Lfp(key)) && ~isempty(lfpCb)
    outDir = fullfilefs(destDir, lfpDir);
    createOrEmpty(outDir)
    
    lfpCb(sourceFile, fullfilefs(outDir, lfpFile));
    muaCb(sourceFile, fullfilefs(outDir, muaFile));
end


% create or clear output directory for spikes
outDir = fullfilefs(destDir, spikesDir);
createOrEmpty(outDir)

% run callback for spike detection
outFile = fullfilefs(outDir, spikesFile);
[electrodes, artifacts] = spikesCb(sourceFile, outFile);

% wait for LFP & MUA jobs to finish
if ~count(cont.Lfp(key)) && ~isempty(lfpCb)
    if parToolbox
        disp('Waiting on LFP');
        while ~wait(lfpJob, 'finished', 60);
            fprintf('.');
        end
        diary(lfpJob)
        assert(isempty(lfpJob.Tasks.Error), 'Error extracting LFP: %s', lfpJob.Tasks.Error.message);
    end
    
    lfpCb = rmfield(key, 'detect_method_num');
    lfpCb.lfp_file = fullfilefs(processedDir, lfpDir, lfpFile);
    insert(cont.Lfp, lfpCb);
end

% populate database tables
tuple = key;
tuple.detect_set_path = fullfilefs(processedDir, spikesDir);
insert(detect.Sets, tuple);
n = numel(electrodes);
for i = 1 : n
    e = electrodes(i);
    tuple = key;
    tuple.electrode_num = e;
    tuple.detect_electrode_file = fullfilefs(processedDir, spikesDir, sprintf(spikesFile, electrodes(i)));
    insert(detect.Electrodes, tuple);
    tuple = key;
    tuple.electrode_num = e;
    a = artifacts{i};
    m = size(a, 1);
    for j = 1 : m
        tuple.artifact_start = a(j, 1);
        tuple.artifact_end = a(j, 2);
        insert(detect.NoiseArtifacts, tuple);
    end
end



function createOrEmpty(outDir)
% Creates a directory. If it already exists, files in it are deleted.

if exist(outDir, 'file')
    rmdir(outDir, 's');
end
mkdir(outDir);


function f = fullfilefs(varargin)
% fullfile with forward slashes instead of os-specific slashes

f = strrep(fullfile(varargin{:}), '\', '/');
