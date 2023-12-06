function plotTrace(registro,Fs)

t=0:1/Fs:(size(registro,1)/Fs)-(1/Fs);

for ii = 1:size(registro,2)
    
    figure;plot(t,registro(:,ii),'Color','k','LineWidth',1.0);
    
    ylim([-2 2])
    
    set(gca,'ytick',[])
    set(gca,'xtick',[])

end
