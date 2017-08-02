function [chan_nums, artifacts] = spikesSingleElectrode(sourceFile, spikesFile)
% Spike detection callback for silicon probes.
% AE 2011-10-26


% determine which tetrodes were recorded
br = baseReaderNeuralynx(sourceFile);
% [tetrodes,channels] = getTetrodes(br);
% refs = getRefs(br);
% channels = [arrayfun(@(x) sprintf('t%dc*', x), tetrodes, 'uni', false), ...
%               arrayfun(@(x) sprintf('ref%d', x), refs, 'uni', false)];
sourceDir = fileparts(sourceFile);
dd = dir(fullfile(sourceDir,'t*c*.ncs'));
electrodes = {dd.name};
close(br);

n = numel(electrodes);
artifacts = cell(1, 1);
chan_nums = nan(1,n);
for i = 1:n
    chan_nums(i) = run(spikesFile, sourceDir, electrodes{i});
end

chan_nums(isnan(chan_nums)) = [];

function chan_num = run(spikesFile, sourceDir, electrode)


fprintf('Extracting spikes on electrode %s\n', electrode);
fn = fullfile(sourceDir,electrode);
br = baseReaderNeuralynx(fn);
% Convert channel name to number
[~,d] = fileparts(sourceDir);
[~,c] = fileparts(electrode);
if count(cont.Chan(sprintf('chan_filename like "%%%s%%%s%%"',d,c)))~=0
    chan_num = fetch1(cont.Chan(sprintf('chan_filename like "%%%s%%%s%%"',d,c)),'chan_num');
    outFile = sprintf(spikesFile, chan_num);
    detectSpikesSingleElectrode(br, outFile);
else
    chan_num = nan;
end




