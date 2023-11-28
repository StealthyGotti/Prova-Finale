function dv = dirOrbv (kepEli, kepElf, et, thm1, thm2, warnings)

dv = directOrb (kepEli, kepElf, et, thm1, thm2, warnings);
if isnan(dv)
    dv = 100;
end

end