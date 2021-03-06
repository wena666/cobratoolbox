% The COBRAToolbox: testAddKeyToKnownHosts.m
%
% Purpose:
%     - test if a key can be added to known hosts
%
% Authors:
%     - Laurent Heirendt, February 2018
%

global CBTDIR

% save the current path
currentDir = pwd;

% test for a failure of an unknown host
assert(verifyCobraFunctionError(@() addKeyToKnownHosts('github123.co')));

% find the keyscan
[status_keyscan, result_keyscan] = system('ssh-keyscan');

if status_keyscan == 1 && ~isempty(strfind(result_keyscan, 'usage:'))
    % get the user directory
    if ispc
        homeDir = getenv('userprofile');
    else
        homeDir = getenv('HOME');
    end

    % define the name of the file
    khFile = [homeDir, filesep, '.ssh', filesep, 'known_hosts'];
    khFile_bk = [khFile, '_bk'];

    % backup the existing known hosts file if it exists
    [status, ~, ~] = copyfile(khFile, khFile_bk);

    % remove the key first from the known hosts file
    [status, result] = system('ssh-keygen -R github.com');

    % run the function to add the github.com key
    statusAddKey = addKeyToKnownHosts();

    % check if the key has been added succesfully
    assert(statusAddKey);

    % verify that the key has been added to the known hosts file
    [~, result_grep] = system(['grep "^github.com " ', khFile]);

    % test whether the resulting string is not empty (site has been found)
    assert(~strcmp(result_grep, ''))

    % test if the host is already known
    assert(addKeyToKnownHosts('github.com'));

    % remove the old host file generated by running ssh-keygen -R
    delete([khFile '.old']);

    % remove the changed file and restore the backup file
    delete(khFile);
    [status, ~, ~] = movefile(khFile_bk, khFile);
    if status
        fprintf(' > Original known hosts file restored.\n');
    end

    % print a success message
    fprintf(' > Test to add a key passed.\n');
end

% change the directory
cd(currentDir)
