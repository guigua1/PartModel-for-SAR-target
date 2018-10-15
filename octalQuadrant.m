function direcLocation = octalQuadrant(direction)
x = direction(1); y = direction(2); direcLocation = 1;

if x < 0
    direcLocation = direcLocation + 4;
elseif x ==0
    direcLocation = [direcLocation direcLocation+4];
end
if y < 0
    direcLocation = direcLocation + 2;
elseif y ==0
    direcLocation = [direcLocation+1 direcLocation+3];
end
if y ~= 0 && abs(x/y) > 1
    direcLocation = direcLocation + 1;
elseif  y ~= 0 && abs(x/y) == 1
    direcLocation = [direcLocation direcLocation+1];
end
