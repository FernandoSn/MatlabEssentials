function HistosCppW(data,Interval)

%Histograms in 3d not fully implemented. Do not use

max_val = 0;

First = 4;
NoHist = size(data,1);

data = data(:,First:First + Interval - 1);

for i=1:NoHist
  g = hgtransform('Matrix',makehgtform('translate',[0 i 0], ...
                                       'xrotate',pi/2));
  if i==1
      hold on
  end
  data(i,:) = data(i,:)./min(data(i,:));
  %h = histogram(data(i,:),'BinWidth',1,'FaceAlpha',1);
  h = Histcorr(data(i,:),1,Interval/2,1);
  h.Parent = g;
  max_val = max(max_val,max(data(i,:)));
%     max_val = 1.2;
end
% Setup axes correctly
set(gca,'SortMethod','depth')
xlim([-Interval/2+10 , Interval/2-10])
ylim([1 NoHist])
zlim([0.75 max_val])
view(3)
xlabel('Value')
ylabel('Series')
zlabel('Probability')
box on
axis fill