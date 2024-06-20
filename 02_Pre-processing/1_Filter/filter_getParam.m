% filter_getParam.m
% Get algorithm parameters from user input
function [filterParam, flag] = filter_getParam()
% initialize variables (in case they are not assigned)
filterParam = struct('filterType',[],'cutOffFreq',[],'sf',[]);
flag = 0;
% user inputs
PopupPrompt  = {'Filter type [lowpass/highpass]',...
    'Cut-off frequency [Hz]',...
    'Sampling rate [Hz]'};
PopupTitle   = 'Filter';
PopupLines   = 1;
PopupDefault = {'high','200','10000'};
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
    flag = 1;
end