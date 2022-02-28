function NPX_SpikeTrialCountspdf(RasterCell,PST,NamePDF)

BinSize = PST(2) - PST(1);
offset1 = 1;
offset2 = 2;


trials1 = 1:length(RasterCell{1}{1,1,1});
trials2 = 1:length(RasterCell{2}{1,1,1});

difftr = length(trials1) - length(trials2);

[~, traindata1] = BinRearranger(RasterCell{1}, PST, BinSize, trials1);
[~, traindata2] = BinRearranger(RasterCell{2}, PST, BinSize, trials2);

stimuli2 = 2:size(RasterCell{2},1);

%traindata = (traindata(2:end,:) ./ max(traindata(2:end,:)));

Columns = 7;
Rows = 7;

Units = size(traindata1,2);

TotalFigures = ceil(Units./(Columns * Rows));

unit = 1;

for CurrFig = 1:TotalFigures
    
    figure
    hold on
    
   for pos = 1:(Columns * Rows)

       subplot(Rows,Columns,pos);
       hold on
       
       for odor = stimuli2
           
           if odor == 2
              
               idx1 = offset1*length(trials1) + 1;
               idx2 = (offset1+ 1)*length(trials1);
               plot(traindata1(idx1:idx2,unit))
               
           elseif odor == 8
              
               idx1 = offset2*length(trials1) + 1;
               idx2 = (offset2+ 1)*length(trials1);
               plot(traindata1(idx1:idx2,unit))
               
%            elseif odor == 2 || odor == 8
%               
%                offset = odor - 1;
%                idx1 = offset*length(trials2) + 1;
%                idx2 = (offset+ 1)*length(trials2);
%                plot([zeros(difftr,1);traindata2(idx1:idx2,unit)])
               
           end
               
           
       end
       
       
       %xlim([0.5, size(traindata,1) + 0.5])
       %ylim([0 1])
       if unit == 1
           
           %xticklabels({'R-Carvone','90/10','70/30','50/50','30/70','10/90','S-Carvone'})
           %xticklabels({'Etbu','90/10','70/30','50/50','30/70','10/90','Val'})
           %xticklabels({'R-Carv','','S-Carv'})
           %yticklabels({'0','','1'})
           ylabel('Counts');
           xlabel('Trials');
           
       else
           
          %xticks([])
          %yticks([]) 
       end
       
       a = get(gca,'XTickLabel');
       set(gca,'XTickLabel',a,'FontName','Times','fontsize',5)
       
       
       
       unit = unit + 1;
       
       if unit == Units; break; end

   end
    
end

names = cell(TotalFigures,1);

for kk = TotalFigures:-1:1

    names{kk} = [num2str(kk),'.pdf'];
    saveas(gcf,names{kk});
    close
end


append_pdfs([NamePDF,'.pdf'],names);

for kk = 1:TotalFigures

    delete(names{kk});

end