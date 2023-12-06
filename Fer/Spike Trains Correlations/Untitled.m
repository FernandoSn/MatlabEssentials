a = [1 534 67845 9 765];

amean = mean(a);

variance = 0;

for ii = 1:length(a)
    
    variance = variance + (a(ii) - amean) * (a(ii) - amean);
    
end

variance = variance / 4;

astd = sqrt(variance)

std(a)