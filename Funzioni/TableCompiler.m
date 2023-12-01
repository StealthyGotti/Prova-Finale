function [] = TableCompiler(KepOrb, dv, dt)

% Function TableCompiler create a .txt file and append all the data needed
% to correctly compile the table of maneuvers.
%
% INPUT:
% - KepOrb: keplerian data of the orbit, in a KepEli-style standard
% - dv:     delta v of the maneuver
% - dt:     delta t of the maneuver
%
% OUTPUT:
% - none but it will display a message if a new file is created or an error
%   if the input format of the Keplerian vector is not ok
% 
% N.B.: 
% every row in the table, has two keplerian data for each dv and dt, so it
% is normal to have two identical dt and dv on two rows, one next to
% another

if length(KepOrb) ~= 6
    error('Check the size of the Keplerian element vector!');
end

file1 = fopen('ReportTable.txt', 'r');
if file1 == -1
    file1 = fopen('ReportTable.txt', 'w');
    fclose(file1);
    fprintf('\nA new file has been created!\n')
end

% Numbers Formatting
desiredLength = 9;      % Numbers of total digits

% Format numbers with the desired total length
dt = formatNumber(dt, desiredLength);
dv = formatNumber(dv, desiredLength);
a = formatNumber(KepOrb(1), desiredLength);
e = formatNumber(KepOrb(2), desiredLength);
i = formatNumber(KepOrb(3), desiredLength);
OM = formatNumber(KepOrb(4), desiredLength);
om = formatNumber(KepOrb(5), desiredLength);
th = formatNumber(KepOrb(6), desiredLength);

% First opening situation
file1 = fopen('ReportTable.txt', 'r');
fseek(file1, 0, 'eof');
fileSize = ftell(file1);
fclose(file1);

desiredLength = desiredLength + 3;  %. and '' counting

if fileSize == 0
    file1 = fopen('ReportTable.txt', 'a');
    fprintf(file1, 'Table of analyzed maneuvers\n\n');
     fprintf(file1, '%-*s|%-*s|%-*s|%-*s|%-*s|%-*s|%-*s|%-*s\n', ...
        desiredLength, 't(s)', desiredLength, 'a(km)', desiredLength, 'e', desiredLength, 'i(deg)', ...
        desiredLength, 'Ω(deg)', desiredLength, 'ω(deg)', desiredLength, 'θ(deg)', desiredLength, 'Δv(m/s)');
    fprintf(file1, repmat('-', 1, 8*desiredLength+6));
    fprintf(file1, '\n');
end

% Data append
file1 = fopen('ReportTable.txt', 'a');
fprintf(file1, '%-s  |', dt);
fprintf(file1, '%-s  |', a);
fprintf(file1, '%-s  |', e);
fprintf(file1, '%-s  |', i);
fprintf(file1, '%-s  |', OM);
fprintf(file1, '%-s  |', om);
fprintf(file1, '%-s  |', th);
fprintf(file1, '%-s', dv);
fprintf(file1, '\n');
fprintf(file1, repmat('-', 1, 8*desiredLength+6));
fprintf(file1, '\n');

% File closing
fclose(file1);
end
