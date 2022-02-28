function NPX_PlotCorrFromMatrix(rho)

%Colors = winter;
Colors = summer;
Colors = Colors(1:42:end,:);
x = [0,1,3,5,7,9,10] + 1;

figure
hold on

plot(x,rho(:,1),'color',Colors(1,:),'LineWidth',2);
plot(x,rho(:,7),'color',Colors(7,:),'LineWidth',2);


xticklabels({'100','90/10','','70/30','','50/50','','30/70','','10/90','100'});
xlabel('mixture ratio')
ylabel('correlation')
%title('Activated')
xlim([0.5,11+0.5])
%ylim([0.7,1])
makepretty;