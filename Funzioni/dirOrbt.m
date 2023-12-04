function dt = dirOrbt (kepEli, kepElf, et, thm1, thm2, option, warnings)

if nargin == 5
    option = 'best';
    warnings = 'off';
end
if nargin == 6
    warnings = 'off';
end
[~, dt] = directOrb (kepEli, kepElf, et, thm1, thm2, option, warnings);
if isnan(dt)
    dt = +Inf;
end

end