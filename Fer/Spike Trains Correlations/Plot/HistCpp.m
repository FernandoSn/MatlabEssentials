function str = HistCpp(Matrix,Index, Interval,BinSize,varargin)

%Plot the histogram with its bands.
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
First = First + Interval + 1;
plot(XAxis,ones(1,Interval) * Matrix(Index,First),'Color',[168/255, 50/255, 83/255],'LineStyle','--','LineWidth',2);
plot(XAxis,ones(1,Interval) * Matrix(Index,First+1),'Color',[168/255, 50/255, 83/255],'LineStyle','--','LineWidth',2);

MaxVal = max([MaxVal,Matrix(Index,First+1)]);

YL = ['Target Spikes Count (Unit ', num2str(Matrix(Index,3)), ')'];
XL = ['Time from Reference Spikes in ms (Unit ', num2str(Matrix(Index,2)), ')'];

% YL = [' (Unit ', num2str(Matrix(Index,3)), ')'];
% XL = [' (Unit ', num2str(Matrix(Index,2)), ')'];

ylabel(YL);
xlabel(XL);
ylim([0 MaxVal + ExtraL]);

switch Matrix(Index,1)
    case 1
        str = 'Lead and Lag Excitatory C';
        title(str);
    case 2
        str = 'Lead Excitatory C';
        title(str);
    case 3
        str = 'Lag Excitatory C';
        title(str);
    case 4
        str = 'Lead and Lag Inhibitory C';
        title(str);
    case 5
        str = 'Lead Inhibitory C';
        title(str);
    case 6
        str = 'Lag Inhibitory C';
        title(str);
    case 7
        str = 'Lead and Lag Ex/In C';
        title(str);
end