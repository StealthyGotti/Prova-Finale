function dt = dirOrbt (kepEli, kepElf, et, thm1, thm2, warnings)

[~, dt] = directOrb (kepEli, kepElf, et, thm1, thm2, warnings);
if isnan(dt)
    dt = 100000;
end

end