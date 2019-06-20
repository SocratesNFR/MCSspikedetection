% --- Reads data from file, applies filter, performs spike detection with
% user-input number of standard deviations (Nsig) below the median. Spike
% trains are output in numerical order. Compatible with .h5 files generated
% by MultiChannel Systems software suite from recordings with the
% 60-electrode MEA2100-System.

% INPUTS
% loc: file location
% filename: name of data file
% Nsig: number of standard deviations for event detection
% OUTPUTS
% spikeMatrix: binary matrix, where 0 indicates no spike and 1 indicates
% spike; matrix dimension is m x n, where m is the number of samples and n
% is the number of electrodes (60)
% .mat file containing the spike matrix, the sampling rate, the thresholds
% for event detection on each electrode in microvolts, the number of
% standard deviations used for event detection, and the filename of the
% original data file

function spikeMatrix = ReadFilterSpikes(loc, filename, Nsig)

% Set up

% Array of electrode numbers in order
elecNum = [12:17 21:28 31:38 41:48 51:58 61:68 71:78 82:87].';
elecStr = string(elecNum);

% File info
fullfile = [loc, filename];
[rate, durSec, label, exponent, conver, info] = h5fileinfo(fullfile);
h5path = info.Groups.Groups(1).Groups(1).Groups(1).Name;
h5path = [h5path, '/ChannelData'];

% Butterworth filter
Hd = o2ButterBP300to3k(rate);

% Time array
tStart = 0;
deltaT = 1/rate;
tEnd = durSec-deltaT;
time = tStart:deltaT:tEnd;
time = time.';


% Read file and get spike trains

% Initialize variables
events = cell(60, 1);
numEvents = zeros(60, 1);
threshold = zeros(60, 1);
spikeMatrix = zeros(length(time), 60);

% Read data, filter, and apply event detection
for i = 1:60
    if i == 4
        index = find(strcmp('Ref', label));
    else
        e = elecStr(i);
        index = find(strcmp(e, label));
    end
    data = h5read(fullfile, h5path, [1 index], [length(time) 1]);
    voltRaw = double(data)*conver*10^(double(exponent))*1e6;         % µV
    volt = filter(Hd, voltRaw);
    [ev, c, thresh] = SpikeDetector(rate, Nsig, volt, 1);
    events{i} = ev;
    numEvents(i) = c;
    threshold(i) = thresh;
    if c > 0
        spikeMatrix(events{i}(:,3), i) = 1;
    end
end


% Save

% Save .mat file
savefile = char(filename(1:(length(filename)-3)));
save(savefile, 'spikeMatrix', 'rate', 'threshold', 'Nsig', 'filename');