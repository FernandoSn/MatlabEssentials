function PlotMeanHistCpp(Matrix, Interval,BinSize)
figure
First = 4;
epoch = Interval/2;
NoCorrs = size(Matrix,1);
ZValOffset = 5.5;

Blue = [0, 0.4470, 0.7410];
Red = [0.8500, 0.3250, 0.0980];
Orange = [0.9290, 0.6940, 0.1250];
Green = [0.4660, 0.6740, 0.1880];
SC = Red;

ZMatrix = zscore(Matrix(:,First:First + Interval - 1),0,2)+ZValOffset;
%ZMatrix = Matrix(:,First:First + Interval - 1) ./ Matrix(:,189);
%ZMatrix = Matrix(:,First:First + Interval - 1) ./ mean(Matrix(:,First:First + Interval - 1),2);
%ZMatrix = Matrix(:,First:First + Interval - 1) ./ max(Matrix(:,First:First + Interval - 1),[],2);

MeanCorr = mean(ZMatrix,1);
StdErrCorr = std(ZMatrix,1);% ./ sqrt(NoCorrs);


%Histcorr(MeanCorr,BinSize,epoch,1);
XAxis = (-epoch:BinSize:epoch-BinSize)+.5;
hold on


for ii = 1: NoCorrs
   
    plot(XAxis,ZMatrix(ii,:),'Color',[200/255,200/255,200/255],'LineStyle',':','LineWidth',0.5);
    
end
plot(XAxis,MeanCorr + StdErrCorr,'Color',SC,'LineWidth',1.5);
plot(XAxis,MeanCorr - StdErrCorr,'Color',SC,'LineWidth',1.5);
Histcorr(MeanCorr,BinSize,epoch,2,SC);

% yticklabels({num2str(-ZValOffset),num2str(-ZValOffset+2),...
%     num2str(-ZValOffset+4),num2str(-ZValOffset+6),num2str(-ZValOffset+8)...
%     num2str(-ZValOffset+10),num2str(-ZValOffset+12),num2str(-ZValOffset+14)})