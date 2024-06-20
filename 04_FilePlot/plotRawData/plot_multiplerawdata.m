% plot_multiplerawdata.m
% by Noriaki (25 Maggio 2006)
% modified by Luca Leonardo Bologna 28 May 2007 (changed the way the name of the window is chosen and displayed)

function [] = plot_multiplerawdata (id_ch,matrawdatapath,end_folderplot)
% INPUT VARIBALES
%       ID_CH = list of channels to plot
%       MATRAWDATAPAH = directory containing MAT-files for raw data
%
% This function plots raw data in different figures according to the
% channels listed on ID_CH.
close
Rawpath = matrawdatapath;      % directory containing MAT-files for raw data

% MCMEA channels
label_ch=[  11 12 13 14 15 16 17 18 21 22 23 24 25 26 27 28 ...
            31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 ...
            51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 ...
            71 72 73 74 75 76 77 78 81 82 83 84 85 86 87 88 ]';

label_ch=label_ch(find(id_ch),:);   % just channels selected to plot
nch = size(label_ch,1);  % number of selected channels to plot

cd (matrawdatapath)
files = dir;

% --------------- USER information
prompt  = {'X-axis Lim (sec)', 'fs'};
title   = 'Plot multiple MAT file';
lines   = 1;
def     = {'300', '10000'};
Ianswer = inputdlg(prompt,title,lines,def);

if isempty(Ianswer)
    errordlg('Selection Failed - End of Session', 'Error');
    return
end
for i=1:nch
    Rawfile = strcat(files(3).name(1:end-6),int2str(label_ch(i)),'.mat');

    if exist(fullfile(Rawpath, Rawfile))
        load (fullfile(Rawpath, Rawfile)) % array 'data' is loaded
        [r,c]=size(data);

        % --------------- PLOT parameters
        xlim  =  str2double(Ianswer{1,1}); % X-axis limit for the plot
        fs    =  str2double(Ianswer{2,1}); % sampling frequency
        x=[1:r]/fs; % [sec]

        %clear title prompt lines def Ianswer binindex1 binindex2
        % --------------- PLOT phase
        figure
        y=plot(x, data, 'LineStyle', '-', 'col', 'b');
        ylimplus= ceil(max(data));
        ylimminus= floor(min(data));
        axis ([0 xlim ylimminus ylimplus])
        Rawfile=strcat(Rawfile,'_',filesep,'_');
        nome=Rawfile(1:end-7);
        set(gca,'Title',text('String',Rawfile,'Color','k'))
        xlabel('Time [sec]');
        ylabel('Amplitude [uV]');
    end
    cd(end_folderplot)
    saveas(y,nome,'jpg');
    saveas(y,nome,'fig');
    %close;
end

EndOfProcessing (Rawpath, 'Successfully accomplished');
clear all