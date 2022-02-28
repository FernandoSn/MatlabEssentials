function NPX_PlotEigenVProjection(rho,ltd,Vidx)

figure
hold on

proj = NPX_EigenProjection(rho,Vidx);

odors = unique(ltd);
Colors = winter;
%Colors = cool;
Colors = Colors(1:floor(256./(length(odors)-1)):end,:);
%Colors = [0,0,0;Colors];

for ii = 1:length(odors)
    idx = ltd == odors(ii);       
    scatter(proj(idx,1),proj(idx,2),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'SizeData',30)       
end