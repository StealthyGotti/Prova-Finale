function numberFormatted = formatNumber(number, totalLength)
i = 1;
if number>1
    i = 0;
    while number > 1
        number = number/10;
        i = i+1;
    end
end

number = round( number , totalLength);
if i > 1
    number = number*10^i;
end

numberFormatted = sprintf(['%.' num2str(totalLength-i) 'f'], number);

end
