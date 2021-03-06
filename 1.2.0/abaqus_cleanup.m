function [] = abaqus_cleanup(varargin)
%abaqus_cleanup.m
%Harry Coules 2014
%
%This function is used for deleting the files generated by Abaqus output.
%It can accept 0-2 input arguments, as follows:
% - If no input arguments are provided, abaqus_cleanup deletes all Abaqus-
%related filetypes *except .inp and .for or .f* in the current directory.
%Filetype list is given below.
% - If one input is provided and it is a string, abaqus_cleanup deletes all
%Abaqus-related filetypes *except .inp and .for* with the name given by
%the string (in the current directory).
% - If one input is provided and it is a cell array, abaqus_cleanup deletes
% all files (in the current directory) with the file extensions specified
% in this array.
% - If two inputs are provided, these should be a string and a cell array
% of strings. In this case, abaqus_cleanup deletes all files which have the
% filename specified by the string AND one of the extensions specified in
% the cell array (in the current directory).
%
%Filetype list: .com, .dat, .inp, .for., .log, .mdl, .msg, .odb, .prt, .sim, .sta
%
%INPUT ARGUMENTS
%   OPTIONAL - Filename (as a string) of the abaqus job for which the files
%       are to be deleted. If this input is omitted ALL files with the given
%       file extensions will be deleted.
%   OPTIONAL - Cell array of strings, each one defining a file extension to
%       be deleted. If this input is omitted, ALL Abaqus-related filetypes 
%       for the given filename will be deleted.
%
%OUTPUT ARGUMENTS
%   *none*
%
%Notes:
% - When removing directories, this function removes the directory and all
%  contained files and subdirectories.
% - Abaqus can sometimes prevent the scratch directory from being deleted
%  due to file permissions. If there is ever a problem with directory
%  deletion in this function, does three attempts at 2-minute intervals.
 
if nargin == 0; %No input arguments - delete all Abaqus associated filetypes *except .inp and .for* regardless of filename
    warning('off');
    delete('*.com');
    delete('*.dat');
    delete('*.log');
    delete('*.msg');
    delete('*.odb');
    delete('*.prt');
    delete('*.sim');
    delete('*.sta');
    warning('on');

    %Robust delete of .mdl file
    if any(size(dir('*.mdl'),1))
        delete('*.mdl');
        pause(10)
        if any(size(dir('*.mdl'),1))
            delete('*.mdl');
            pause(30)
            if any(size(dir('*.mdl'),1))
                delete('*.mdl');
                pause(90)
                if any(size(dir('*.mdl'),1))
                    delete('*.mdl');
                end
            end
        end
    end

    %Robust delete of scratch directory
    if exist('scratch','dir')
        try
            rmdir('scratch','s');
        catch
            pause(120)
            if exist('scratch','dir')
                try
                    rmdir('scratch','s');
                catch
                    pause(120)
                    if exist('scratch','dir')
                        rmdir('scratch','s');
                    end
                end
            end
        end
    end
    
elseif nargin == 1; %One input argument. Might be a filename or a cell array of file extensions
    if strcmpi(class(varargin{1}),'char')||strcmpi(class(varargin{1}),'str')  %Filename (without extension) as a string
        filename = varargin{1};
        warning('off');
        delete(strcat(filename,'.com'));   %Delete all Abaqus associated filetypes *except .inp and .for* with this filename
        delete(strcat(filename,'.dat'));
        delete(strcat(filename,'.log'));
        delete(strcat(filename,'.msg'));
        delete(strcat(filename,'.odb'));
        delete(strcat(filename,'.prt'));
        delete(strcat(filename,'.sim'));
        delete(strcat(filename,'.sta'));
        warning('on');
        
        %Robust delete of .mdl file
        if any(size(dir(strcat(filename,'.mdl')),1))
            delete('*.mdl');
            pause(10)
            if any(size(dir(strcat(filename,'.mdl')),1))
                delete('*.mdl');
                pause(30)
                if any(size(dir(strcat(filename,'.mdl')),1))
                    delete('*.mdl');
                    pause(90)
                    if any(size(dir(strcat(filename,'.mdl')),1))
                        delete('*.mdl');
                    end
                end
            end
        end
        
        %Robust delete of scratch directory
        if exist('scratch','dir')
            try
                rmdir('scratch','s');
            catch
                pause(120)
                if exist('scratch','dir')
                    try
                        rmdir('scratch','s');
                    catch
                        pause(120)
                        if exist('scratch','dir')
                            rmdir('scratch','s');
                        end
                    end
                end
            end
        end
        
    elseif strcmpi(class(varargin{1}),'cell') %Cell array of file extensions
        fext = varargin{1};
        for k = 1:length(fext)
            if strfind(fext{k},'.')
                warning('off');
                delete(strcat('*',fext{k}));    %If the string contains a '.' it describes a file extension, so remove the file
                warning('on');

                %Robust delete of .mdl file
                if strcmpi(fext{k},'.mdl')
                    if any(size(dir('*.mdl'),1))
                        delete('*.mdl');
                        pause(10)
                        if any(size(dir('*.mdl'),1))
                            delete('*.mdl');
                            pause(30)
                            if any(size(dir('*.mdl'),1))
                                delete('*.mdl');
                                pause(90)
                                if any(size(dir('*.mdl'),1))
                                    delete('*.mdl');
                                end
                            end
                        end
                    end
                end

            else  %Otherwise it describes a directory (probably 'scratch'), so remove this
                if exist(fext{k},'dir')
                    try
                        rmdir(fext{k},'s');
                    catch
                        pause(120)
                        if exist(fext{k},'dir')
                            try
                                rmdir(fext{k},'s');
                            catch
                                pause(120)
                                if exist(fext{k},'dir')
                                    rmdir(fext{k},'s');
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        error('Unexpected single input type. Must be a filename or a cell array of file extensions.');
    end
elseif nargin == 2; %Two input arguments. Filename AND cell array of file extensions have been provided
    %Find out which of the two inputs is the filename and which is the cell
    %array of extensions.
    warning('Two input arguments (filename AND cell array of extensions) specified.')
    warning('Note this method does not provide for robust cleanup of .mdl files.')
    if strcmpi(class(varargin{1}),'cell')
        if strcmpi(class(varargin{2}),'char')||strcmpi(class(varargin{2}),'str')
            fext = varargin{1};
            filename = varargin{2};
        else
            error('One of the optional inputs is an unexpected class. There should be one cell, one char or str.')
        end
    elseif strcmpi(class(varargin{1}),'char')||strcmpi(class(varargin{1}),'str')
        if strcmpi(class(varargin{2}),'cell')
            filename = varargin{1};
            fext = varargin{2};
        else
            error('One of the optional inputs is an unexpected class. There should be one cell, one char or str.')
        end
    else
        error('Neither of the optional inputs is the correct class. There should be one cell, one char or str.')
    end
    %Now delete the files accordingly.
    for k = 1:length(fext)
        if strfind(fext{k},'.')
            warning('off');
            delete(strcat(filename,fext{k}));    %If the string contains a '.' it describes a file extension, so remove the file
            warning('on');
        else  %Otherwise it describes a directory (probably 'scratch'), so remove this (note this is regardless of the abaqus filename provided).
            if exist(fext{k},'dir')
                try
                    rmdir(fext{k},'s');
                catch
                    pause(120)
                    if exist(fext{k},'dir')
                        try
                            rmdir(fext{k},'s');
                        catch
                            pause(120)
                            if exist(fext{k},'dir')
                                rmdir(fext{k},'s');
                            end
                        end
                    end
                end
            end
        end     
    end
else
    error('Unexpected number of input arguments. Must be 0-2 (optional filename, optional cell array of file extensions).');
end

end

