function [S label_ch artifact recDur_samples sf successFlag] = CONV_mcd_data_sm(mcdFileName, param)
% S: n x 3 matrix, with rows [ #channel tspike value(uV)].
% For conversion of MCD (stream Spikes) data. It loads the selected spikes stream into
% the S matrix
% PL Baljon, October 2008 (based on CONV_nbt_data())
% VP, March 2009

% TTL_THRESHOLD  = 1e+6; %uV
% MIN_ART_DIST = 0.5; %s
% initializing results
S = zeros(0,2);
label_ch = [];
artifact = [];
recDur_samples = [];
successFlag = 0;
sf = [];
% opening the mcdFileName header
try
    warning off 'MCS:unknownUnitSign';
    h_mcd = datastrm(mcdFileName);
    warning on 'MCS:unknownUnitSign';
catch
    fprintf('Error in opening [%s].\nError was [%s].\n\n',mcdFileName,lasterr);
    return
end
% retrieving information from the header
streamNames     = getfield(h_mcd,'StreamNames');
n_channels      = getfield(h_mcd,'NChannels2');     % number or channels recorded (either 60 or 120, or less if some channels are closed)
totalChannels  	= getfield(h_mcd,'TotalChannels');  % total number of channels of the setup (either 64 or 128)
HardwareChannelNames2 = getfield(h_mcd,'HardwareChannelNames2');    % channel definitions (for recorded channels) sorted in recording order
MillisamplesPerSecond2 = getfield(h_mcd,'MillisamplesPerSecond2'); 
uVperAD = getfield(h_mcd,'MicrovoltsPerAD2');
zeroADValue = getfield(h_mcd,'ZeroADValue2');
if isempty(param.amplifier) && totalChannels == 128
    warning('Error! You should select an amplifier (A or B).'); %#ok<WNTAG>
    return
else if ~isempty(param.amplifier) && totalChannels == 64
        warning('Error! You should not select an amplifier (A or B), because there is only one'); %#ok<WNTAG>
        return
    end
end
% looking for the selected stream
spikesStream = strmatch(param.streamName,streamNames);
if(~isempty(spikesStream))
    id_ch = zeros(n_channels(spikesStream),1);
    sf = MillisamplesPerSecond2(spikesStream)/1000; %sampling frequency
    convFactor = 1e-3*sf;
    recDur = getfield(h_mcd,'sweepStopTime');  %#ok<GFLD> % ms
    recDur_samples = recDur.*convFactor;
    HwChannelNames2Char = char(HardwareChannelNames2{spikesStream});
    if totalChannels == 128
        [rows, cols] = find(HwChannelNames2Char==param.amplifier);
        label_ch = str2num(HwChannelNames2Char(rows,1:2)); %#ok<ST2NM>
        id_ch(rows) = 1;
    else if totalChannels == 64
            label_ch = str2num(HwChannelNames2Char); %#ok<ST2NM>
            id_ch(find(label_ch)) = 1;
        end
    end
    spikes_data = nextdata(h_mcd,'startend',[0 recDur],'streamname',param.streamName,'originorder','on');
    spikesTimes = spikes_data.spiketimes(find(id_ch),:);            %#ok<FNDSB>
    %     spikesValues = spikes_data.spikevalues(find(id_ch),:);  %#ok<FNDSB>
    for k=1:length(label_ch)
        %         values = ad2muvolt(h_mcd, spikesValues{k}, param.streamName);
        %         values = values';
        %         S = [S; [label_ch(k) .* ones(size(spikesTimes{k},1),1) ...
        %             convFactor.*spikesTimes{k}(:) ...
        %             values]];
        S = [S; [label_ch(k) .* ones(size(spikesTimes{k},1),1) ...
            convFactor.*spikesTimes{k}(:)]];
    end
    S          = sortrows(S,2);
%     last_spike = max(S(:,2));
    clear spikes_data;
else
    warning('%s contains no %s stream\n',mcdFileName,param.streamName); %#ok<WNTAG>
    return
end

analog_stream = strmatch('Analog Raw Data',streamNames);
if(~isempty(analog_stream))
%     nAnalogChannels = n_channels(analog_stream);
    step_size = 5000; ti = 0;
    anaData = [];
    while(ti + step_size < recDur)
        A = nextdata(h_mcd,'startend',[ti ti+step_size],'streamname','Analog Raw Data','originorder','on');
        anaData = [anaData A.data];
        ti = ti + step_size;
    end
    A = nextdata(h_mcd,'startend',[ti recDur],'streamname','Analog Raw Data','originorder','on');
    anaData = [anaData A.data];
    % anaData contains the 'Analog Raw Data' stream  [nAnalogChannels x
    % #samples]
    anaData_mV = (anaData-zeroADValue(analog_stream)).*uVperAD(analog_stream)/1000;
    % it chooses the channel with the maximum range
    [max_dif channel] = max(abs(max(anaData_mV,[],2)-min(anaData_mV,[],2)));
    clear max_dif;
    chosAnaCh = anaData_mV(channel,:);
    temp = [0 diff(chosAnaCh >= param.artThresh)];
    pksIdx = find(temp == 1);
%     mpd_samples = param.artDist.*sf;
%     pksIdx(find(diff(pksIdx)<=mpd_samples)+1)=[];
    artifact = pksIdx;
else
    warning('[%s] contains no ''Analog Raw Data'' stream\n',mcdFileName); %#ok<WNTAG>
    artifact = [];
end
successFlag = 1;