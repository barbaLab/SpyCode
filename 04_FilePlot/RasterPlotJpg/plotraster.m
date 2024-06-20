function [dispwarn]= plotraster(start_folder, end_folder, fs, starttime, endtime, startend, filetype)
%       start_folder = complete path of the folder containing the data to display
%       end_folder   = complete path for the final folder
%       fs           = sampling frequency [#samples/sec]
%       starttime    = beginning of the raster - time displayed [# samples]
%       endtime      = end of the raster - time displayed [# samples]
%       startend     = strcat(starttime/fs, '-', endtime/fs, 'sec'); [char]
%       filetype     = 1 ---> MAT

% by M. Chiappalone (15 febbraio 2006)
% BUG on the length of the output files (endtime not updated for all the
% experimental phases) - Corrected by M. Chiappalone (January 16, 2009)

%% initialise
first=3; %avoid '.' and '..'
dispwarn=0;
cd(start_folder)
peakfolderdir= dir;                   % Struct containing the peak-det folders
NumPeakFolder= length(peakfolderdir); % Number of experimental phases

%% create figure
scrsz = get(0,'ScreenSize');
fh = figure('Position',[1+100 scrsz(1)+100 scrsz(3)-200 scrsz(4)-200]);
set(gcf,'Color','w')
xlabel('Time [sec]')
ylabel('Electrode')
grid on; hold on

%% loop through files and plot
for f=first:NumPeakFolder            % FOR cycle on the phase directories
    cd(peakfolderdir(f).name)
    phasefiles = dir;
    numphasefiles=length(phasefiles);
    figure(fh)
    cla %clean graph
    evector = []; %vector with electrode numbers
    
    for i=first:numphasefiles
        load(phasefiles(i).name);     % peak_train and artifact are loaded
        electrode = str2double(phasefiles(i).name(end-5:end-4));
        evector=[evector; electrode];
        spiketimes= find(peak_train(starttime:end))+starttime;
        if ~isempty(spiketimes)
            spiketimes = spiketimes/fs;
            %plot(spiketimes, i,'.b','markersize',5);
            plot(spiketimes, electrode,'.b','markersize',5); %27/05/22 subistitued i with electrode
            hold on
        end
    end
    
    hold off

    if starttime > length(peak_train)
        disp(['for data in folder: ' peakfolderdir(f).name ' the starttime longer than filelength! Empty plot produced'])
    else
        if endtime<0 %automatic endtime depends on filelength
            xlim([starttime/fs length(peak_train)/fs])
        else %endtime is specified
            xlim([starttime/fs endtime/fs])
        end
    end
    
    %set(gca,'ytick',first:1:numphasefiles,'yticklabel',num2str(evector),'ylim',[1 numphasefiles]);   
    cd(end_folder)
    %saveas(gcf,strcat('Raster_', startend, '_', peakfolderdir(f).name),'fig')
    %saveas(gcf,strcat('Raster_', startend, '_', peakfolderdir(f).name),'jpg')
    cd(start_folder)
end
end