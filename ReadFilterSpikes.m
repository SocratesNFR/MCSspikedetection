%% Reads data from file, applies filter, performs spike detection

function spikeMatrix = ReadFilterSpikes(loc, filename, Nsig)

%% Set up stuff

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


%% Read and spike trains
% Initialize variables
events = cell(60, 1);
numEvents = zeros(60, 1);
threshold = zeros(60, 1);
spikeMatrix = zeros(length(time), 60);

% Read data, filter, and apply event detection
data_labels = h5read(filename, h5path, [1 1], [length(time) 60]);
for i = 1:60
    if i == 4
        index = find(strcmp('Ref', label));
    else
        e = elecStr(i);
        index = find(strcmp(e, label));
    end
    data = data_labels(:,index);
    voltRaw = double(data)*conver*10^(double(exponent))*1e6;      % µV
    volt(:,i) = filter(Hd, voltRaw);
    [ev, c, thresh, spikeRate] = EventDetector(rate, Nsig, volt(:,i), isNeg);
    events{i} = ev;
    numEvents(i) = c;
    threshold(i) = thresh;
    FR(i) = spikeRate;
end

%% Save
% Save .mat file
savefile = char(filename(1:(length(filename)-3)));
save(savefile, 'spikeMatrix', 'events', 'rate', 'threshold', 'Nsig');