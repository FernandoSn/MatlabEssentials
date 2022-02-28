function Figs2PDF(NamePDF)

h =  findobj('type','figure');
TotalFigures = length(h);
tempname = 'Rndigpdffsvfig2pdffunc';

names = cell(TotalFigures,1);

r = randi(1000000,[1,TotalFigures * 100]);
r = unique(r);
r = sort(r(1:TotalFigures));

for kk = TotalFigures:-1:1

    names{kk} = [tempname,num2str(r(kk)),'.pdf'];
    saveas(gcf,names{kk});
    close
end


append_pdfs([NamePDF,'.pdf'],names);

for kk = 1:TotalFigures

    delete(names{kk});

end