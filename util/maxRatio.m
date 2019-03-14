function r = maxRatio(a, b)

try
    r = a/b;
    if r < 1
        r = 1/r;
    end
catch
    r = b;
end