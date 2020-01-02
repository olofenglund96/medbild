function [info,im] = mydicomread(filename)
%[info,im] = mydicomread(filename)
%Simple DICOM image reader as part in the course Medical Image Analysis
%FMAN30, Centre of Mathematical Sciences, Engineering Faculty, Lund University.
%
%To get this function working you need to add code to:
%
%1) Calculate size of image
%2) Reshape data to an image
%3) Rescale the data into true image intensities
%
%See also MYDICOMINFO.
%
%Einar Heiberg, 2014

info = mydicominfo(filename);

%--- Open the file
fid=fopen(filename,'r','l');
if fid == -1
  error('Could not open the file');
end;

%%%% Calculate datasize (i.e elements in image) %%%%
datasize = info.Rows*info.Columns; %%%% Change here based on information in info struct. %%%%

%Find right part of the file
fseek(fid,info.StartOfPixelData,'bof');

%Read image data
switch info.BitsAllocated
  case 8
    im = fread(fid,datasize,'*uint8'); %8 bit reader
  case 16
    im = fread(fid,datasize,'*int16'); %16 bit reader
  otherwise
    fclose(fid);
    error('Wrong bit-depth.');
end;

%Close the file
fclose(fid);

%%%% Reshape the image. Add code here %%%%

im = reshape(im, [info.Columns, info.Rows]);
im = im';
%%%% Rescale image to true intensities. Add code here %%%%
m = info.RescaleSlope;
b = info.RescaleIntercept;

if isa(m, 'char')
    m = str2double(m);
end

if isa(b, 'char')
    b = str2double(b);
end
    
im = m*im + b;

