function NPX_SUCorrMatpdf(SUcell,NamePDF,SigUnits)

%Correlation matrices for each unit plotted and saved as pdf 


Columns = 7;
Rows = 7;

Units = size(SUcell,1);

TotalFigures = ceil(Units./(Columns * Rows));

unit = 1;

for CurrFig = 1:TotalFigures
    
    figure
    hold on
    
   for pos = 1:(Columns * Rows)

       subplot(Rows,Columns,pos);
       
       
       
       %imagesc(corr(reshape(SUcell(:,unit),[20,8])))
       imagesc(corr(SUcell{unit}'));
       colormap(parula)
       caxis([0,1])
       xticks([])
       yticks([])
       
       if (nargin > 2) && (SigUnits(unit)); title('*');end
       
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

