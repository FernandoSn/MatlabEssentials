function NPX_SpikeTrialInhCountspdf(traindata,inhamp,NamePDF)

%traindata = (traindata(2:end,:) ./ max(traindata(2:end,:)));

Columns = 7;
Rows = 7;

Units = size(traindata,2);

%TotalFigures = ceil(Units./(Columns * Rows));

%unit = 1;
pos = (Columns*Rows) + 1;
for unit = 1:Units
    
   if pos > (Columns*Rows)
      figure
      hold on
      pos = 1;
   end
   
   subplot(Rows,Columns,pos);
   hold on

   plot(zscore(traindata(:,unit)))
   if ~isempty(inhamp)
       plot(zscore(traindata(:,unit)./inhamp))
   end
   


   %xticks([])
   yticks([]) 
   title(num2str(unit))

   a = get(gca,'XTickLabel');
   set(gca,'XTickLabel',a,'FontName','Times','fontsize',5)
   
   pos = pos + 1;
    
end

Figs2PDF(NamePDF);