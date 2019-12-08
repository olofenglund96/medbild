function [file_cell] = loadFilesFromDir(d, filetype)
%UNTITLED2 Summary of this function goes here
    files = dir([d '*.' filetype]);
    file_cell = cell(length(files),1);
    
    for i = 1:length(files)
        file_cell{i} = imread([d files(i).name]);
    end
end

