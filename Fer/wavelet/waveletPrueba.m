function wav = waveletPrueba(scale,timeshift)
%dt = 0.001;

%timeshift=-4:0.01:4;
timeshift=-5.12:0.01:5.12;

t= timeshift;

x=t/scale;
%x = zeros(1,length(t));
wo = 6;

wav = pi.^(-1/4) .* exp(1i*wo.*x) .* exp(-x.^2/2);

%fun = @(x) pi.^(-1/4) .* exp(1i.*wo.*x) .* exp(-x.^2/2);

%q = integral(fun,-inf,inf);