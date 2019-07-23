function meanlinemarkerplot(Xs, Ydata, spread, err, colores)

for d = 1:length(Ydata)
    m = nanmean(Ydata{d});
    plot([Xs(d)-spread/2 Xs(d)+spread/2],[m m],'color',colores(d,:));
    if err
       errbar(Xs(d),m,nansem(Ydata{d}),'color',colores(d,:))
    end
end

%%meanlinemarkerplot([2,2.5,3],{v(I_D),v(~I_S & ~I_D & ~E),v(I_S)},.2)