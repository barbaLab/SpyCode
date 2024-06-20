% MAIN_rasterplot_pdf.m
% Script for creating the rasterplot files (jpg format) from the peak
% detection files of one experiment. It allows to select specific
% electrodes and specific window of the datastream

% TO DO:
% 1 - Save JPG or FIG Files or other format...
% 3 - select a subset of electrodes

% by Michela Chiappalone (2 Febbraio 2006)

clr
% --------- USER INPUT
[start_folder]= selectfolder('Select the PeakDetectionMAT_files folder');
if strcmp(num2str(start_folder),'0')
    errordlg('Selection Failed - End of Session', 'Error');
    return
end
% [fs, starttime, endtime, startend, cancelFlag]=uigetRASTERinfo;
fs = 10000;

% if cancelFlag
%     errordlg('Selection Failed - End of Session', 'Error');
% else
    end_folder = get_rasterplot_folder(start_folder);
    
    % --------- FOLDER MANAGEMENT
    [dispwarn]=plotraster_pdf(start_folder, end_folder, fs,1);

    if (dispwarn==1)
        EndOfProcessing (start_folder, 'An error occured.');
    else
        EndOfProcessing (start_folder, 'Successfully accomplished.');
    end
% end
clear all
