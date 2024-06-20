% filter_getParam.m
% Get algorithm parameters from user input
function [filterParam, flag] = filterSALPA_getParam()
% initialize variables (in case they are not assigned)
filterParam = struct('filterType',[],'cutOffFreq',[],'sf',[],'N',[],'win',[],'D',[],'hw',[],'art_thresh_analog',[]);
flag = 0;
% user inputs
PopupPrompt  = {'Filter type [lowpass/highpass]',...
    'Cut-off frequency [Hz]',...
    'Sampling rate [Hz]','SALPA - N [ms]','SALPA - win [ms]','SALPA - d','SALPA - hw [ms]','Artefact threshold (Analog Raw Data) [mV]'};
PopupTitle   = 'Filter - SALPA';
PopupLines   = 1;
PopupDefault = {'high','70','10000','3','50','3','2','10'};
%----------------------------------- PARAMETER CONVERSION
Ianswer = inputdlg(PopupPrompt,PopupTitle,PopupLines,PopupDefault,'on');
if isempty(Ianswer) % halt condition
    return
else
    filterType = Ianswer{1,1};
    if ~(strcmp(filterType,'high') || strcmp(filterType,'low'))
        errordlg('The filter type must be ''low'' or ''high''.','!!Error!!')
        return
    end
    filterParam.filterType = Ianswer{1,1};
    filterParam.cutOffFreq = str2double(Ianswer{2,1});
    filterParam.sf = str2double(Ianswer{3,1});
    filterParam.art_thresh_analog = str2double(Ianswer{8,1});
    % salpa parameters
    filterParam.N   = single(str2num(Ianswer{4,1})*filterParam.sf/1000); % 3ms -> 30 samples at 10 kHz
    filterParam.win = single(str2num(Ianswer{5,1})*filterParam.sf/1000);% 50ms -> 500 samples at 10 kHz  
    filterParam.d   = single(str2num(Ianswer{6,1}));  % 5 (as DAW)
    filterParam.hw  = single(str2num(Ianswer{7,1})*filterParam.sf/1000);   % 2 ms -> 20 samples at 10 kHz
    flag = 1;
end