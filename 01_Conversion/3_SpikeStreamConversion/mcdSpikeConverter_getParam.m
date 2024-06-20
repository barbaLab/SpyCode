% mcdSpikeConverter_getParam.m
% Get algorithm parameters from user input
function [mcdSCParam, flag] = mcdSpikeConverter_getParam()
% initialize variables (in case they are not assigned)
mcdSCParam = struct('streamName',[],'amplifier',[],'artThresh',[]);
flag = 0;
% user inputs
PopupPrompt  = {'Stream Name', 'Amplifier (A or B for MCS120, empty string for MCS60)','Artefact threshold (based on Analog Raw Data stream) [V]'};
PopupTitle   = 'MCD Spike Converter';
PopupLines   = 1;
PopupDefault = {'Spikes 1','A','0.2'};
%----------------------------------- PARAMETER CONVERSION
Ianswer = inputdlg(PopupPrompt,PopupTitle,PopupLines,PopupDefault,'on');
if isempty(Ianswer) % halt condition
    return
else
    mcdSCParam.streamName = Ianswer{1,1};
    mcdSCParam.amplifier = Ianswer{2,1};
    mcdSCParam.artThresh = str2double(Ianswer{3,1}).*1e+3; % mV
    flag = 1;
end