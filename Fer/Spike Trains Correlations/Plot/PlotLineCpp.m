function PlotLineCpp(Matrix,Index, Interval)

%Plot lines instead of Histograms. Not fully implemented.
%Not recommended.

First = 4;

figure
hold on
plot(Matrix(Index,First:First + Interval - 1))
First = First + Interval + 1;
plot(Matrix(Index,First:First + Interval - 1))
First = First + Interval + 1;
plot(Matrix(Index,First:First + Interval - 1))
plot(ones(1,Interval) * Matrix(Index,end-3))
plot(ones(1,Interval) * Matrix(Index,end-2))