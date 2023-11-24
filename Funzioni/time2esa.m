function [hr, min, sec] = time2esa (t)

hr = floor(t/3600);
min = floor((t-hr*3600)/60);
sec = t-hr*3600-min*60;

end