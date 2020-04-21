function PlotHistCpp(Matrix,Index, Interval,BinSize)

figure;
str = HistCpp(Matrix,Index, Interval,BinSize);

title([str,'  ',num2str(Matrix(Index,192)), ',', num2str(Matrix(Index,194)), ' diff ' num2str(Matrix(Index,195)),'microm']);