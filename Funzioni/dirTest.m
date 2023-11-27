function D = dirTest (stepth, thm1min, thm1max, thm2min, thm2max, stepe, etmin, etmax)

thm1 = thm1min:stepth:thm1max;
thm2 = thm2min:stepth:thm2max;
et = etmin:stepe:etmax;
fprintf('Total combinations requested: %d\n', length(thm1)*length(thm2)*length(et))
[h, m, s] = time2esa(length(thm1)*length(thm2)*length(et)/10000*10);
fprintf('Estimated time to complete: %.0f hr %.0f min %.0f s\n', h, m, s)
D = zeros(length(thm1)*length(thm2)*length(et), 5);
tic
comb = 0;
for thm1 = thm1min:stepth:thm1max
    for thm2 = thm2min:stepth:thm2max
        for et = etmin:stepe:etmax
            [dvdir, dtdir] = directOrb (kepEli, kepElf, et, thm1, thm2, 'off');
            comb = comb + 1;
            D(comb, 1) = thm1;
            D(comb, 2) = thm2;
            D(comb, 3) = et;
            D(comb, 4) = dvdir;
            D(comb, 5) = dtdir;
        end
    end
end
elapsed = toc;
[h, m, s] = time2esa(elapsed);
dvmin = min(D(:, 4));
posv = find(D(:, 4) == dvmin);
thm1v = D(posv, 1);
thm2v = D(posv, 2);
etv = D(posv, 3);
dtv = D(posv, 5);
[hv, mv, sv] = time2esa(dtv);
dtmin = min(D(:, 5));
[ht, mt, st] = time2esa(dtmin);
post = find(D(:, 5) == dtmin);
thm1t = D(post, 1);
thm2t = D(post, 2);
ett = D(post, 3);
dvt = D(post, 4);
fprintf('Absolute most velocity-wise convenient maneuver: %cv = %.2f km/s | (%c1 = %.2f°, %c2 = %.2f°, e = %.4f, %ct = %.0f s (%.0f hr %.0f min %.0f s))\n', 916, dvmin, 952, thm1v, 952, thm2v, etv, 916, dtv, hv, mv, sv)
fprintf('Absolute most time-wise convenient maneuver: %ct = %.0f s (%.0f hr %.0f min %.0f s) | (%c1 = %.2f°, %c2 = %.2f°, e = %.4f, %cv = %.2f km/s)\n', 916, dtmin, ht, mt, st, 952, thm1t, 952, thm2t, ett, 916, dvt)
fprintf('Total combinations analyzed: %d\n', comb)
fprintf('Time elapsed: %.0f hr %.0f min %.0f s\n', h, m, s)