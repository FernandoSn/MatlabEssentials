function HistosCpp(Matrix,Interval,BinSize)

m = ceil(sqrt(size(Matrix,1)));

for ii = 1:size(Matrix,1)
   
    subplot(m,m,ii);
    
    HistCpp(Matrix,ii,Interval,BinSize)
    
end