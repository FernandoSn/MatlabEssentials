function vScales = waveletScales(subOctaves,signal,deltaT)

%Contruye un vector de escalas con una función exponencial de base 2 (2^x)
%Si se desea graficar desmarcar la 10 y 12 linea y marcar la 6 y 8.


%%%%%%%%%%%%%%%%%%%%%ANALISIS%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%maxScale = ((subOctaves).^-1) .* log2(((length(signal)*deltaT)/2)); %calcula las escalas (octavas y suboctavas).

%limit = round(maxScale);

%%%%%%%%%%%%%%%%%%%%GRAFICA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxScale =(length(signal)*.17)*2;

limit = round(log2(maxScale/2)/subOctaves);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


vScales = 2*2.^((0:limit)*subOctaves);  %vector con las escalas para morlet.