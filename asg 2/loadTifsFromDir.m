function [file_cell] = loadTifsFromDir(d, filetype)
%UNTITLED2 Summary of this function goes here
    files = dir([d '*.' filetype]);
    file_cell = cell(length(files),1);
    
    for i = 1:length(files)
        im = double(imread([d files(i).name]));
        maxpx = max(im, [], 'all');
        im = im/maxpx;
        file_cell{i} = 255*(1-histeq(im, 256));
    end
end

