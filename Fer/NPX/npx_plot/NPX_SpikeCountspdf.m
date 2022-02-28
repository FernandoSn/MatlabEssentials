function NPX_SpikeCountspdf(Raster,PST,Trials,NamePDF,PREX,POSTX)


if nargin == 4
    [~,traindata] = NPX_GetTAtraindata(Raster, PST, Trials);
elseif nargin == 6
    
    %PST should be a ValveTimes struct for this condition.
    
    [~,traindata] = NPX_GetTAtraindata(Raster,PST,Trials,PREX,POSTX);
end

%traindata = (traindata(2:end,:) ./ max(traindata(2:end,:)));
traindata = traindata(2:end,:);

Columns = 7;
Rows = 7;

Units = size(traindata,2);

TotalFigures = ceil(Units./(Columns * Rows));

unit = 1;

for CurrFig = 1:TotalFigures
    
    figure
    hold on
    
   for pos = 1:(Columns * Rows)

       subplot(Rows,Columns,pos);
       
       
       
       %imagesc(corr(reshape(SUcell(:,unit),[20,8])))
       plot(traindata(:,unit),'LineWidth',1.2)
       xlim([0.5, size(traindata,1) + 0.5])
       %ylim([0 1])
       if unit == 1
           
           %xticklabels({'R-Carvone','90/10','70/30','50/50','30/70','10/90','S-Carvone'})
           %xticklabels({'Etbu','90/10','70/30','50/50','30/70','10/90','Val'})
           xticklabels({'Odor A','','Odor B'})
           %yticklabels({'0','','1'})
           ylabel('Rate');
           xlabel('Odor mixtures');
           
       else
           
          xticks([])
          %yticks([]) 
       end
       
       a = get(gca,'XTickLabel');
       set(gca,'XTickLabel',a,'FontName','Times','fontsize',5)
       
       
       if unit == Units; break; end
       
       unit = unit + 1;

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

