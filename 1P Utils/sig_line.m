function sig_line(xs, ys, pv)

yr = range(get(gca,'YLim'));

if pv<.05
    plot(xs,.05*yr+[max(ys), max(ys)],'k')
    text(mean(xs),.07*yr+max(ys),'*','HorizontalAlignment','Center','BackGroundColor','none')
    text(mean(xs),max(ys)-.07*yr,num2str(pv,'%0.3f'),'HorizontalAlignment','Center','BackGroundColor','none','fontsize',6)
end