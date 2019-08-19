function HistCpp(Matrix,Index, Interval,BinSize)

First = 4;
epoch = Interval/2;

Histcorr(Matrix(Index,First:First + Interval - 1),BinSize,epoch);
MaxVal = max(Matrix(Index,First:First + Interval - 1));
ExtraL = max(Matrix(Index,First:First + Interval - 1)) .* 0.05;


XAxis = (-epoch:BinSize:epoch-BinSize)+.5;
hold on
First = First + Interval + 1;
plot(XAxis,Matrix(Index,First:First + Interval - 1),'Color',[24/255, 8/255, 196/255],'LineStyle',':','LineWidth',2);
First = First + Interval + 1;
plot(XAxis,Matrix(Index,First:First + Interval - 1),'Color',[24/255, 8/255, 196/255],'LineStyle',':','LineWidth',2);
plot(XAxis,ones(1,Interval) * Matrix(Index,end-3),'Color',[168/255, 50/255, 83/255],'LineStyle','--','LineWidth',2);
plot(XAxis,ones(1,Interval) * Matrix(Index,end-2),'Color',[168/255, 50/255, 83/255],'LineStyle','--','LineWidth',2);



YL = ['Target Spikes Count (Unit ', num2str(Matrix(Index,3)), ')'];
XL = ['Reference Spikes Count (Unit ', num2str(Matrix(Index,2)), ')'];
ylabel(YL);
xlabel(XL);
ylim([0 MaxVal + ExtraL]);

switch Matrix(Index,1)
    case 1
        title('Lead and Lag Excitatory C');
    case 2
        title('Lead Excitatory C');
    case 3
        title('Lag Excitatory C');
    case 4
        title('Lead and Lag Inhibitory C');
    case 5
        title('Lead Inhibitory C');
    case 6
        title('Lag Inhibitory C');
    case 7
        title('Lead and Lag Ex/In C');
end