function Histcorr(CorrVec,BinSize,epoch)

XAxis = -epoch:BinSize:epoch-BinSize;
figure
a = bar(XAxis,CorrVec,'histc');

% set(a,'FaceColor','r','EdgeColor','r');
% set(a,'FaceColor',[48/255,88/255,230/255],'EdgeColor',[48/255,88/255,230/255]);

% hold on

% plot([XAxis,1000],ones(1,81) * 6.23, 'Color','k','LineStyle','--','LineWidth',1);

% plot([XAxis,1000],ones(1,81) * 0.73, 'Color','k','LineStyle','--','LineWidth',1.2);

%  yticklabels({'-4','-3','2','1','0','1','2'})
%  yticklabels({'-3','-1','1','3','5','7','9'})
 
  ylabel('Target Spikes count')
  xlabel('Time from reference spikes (ms)')
%  title('Excitatory AON - PfCx cross-correlation')
%  title('Inhibitory AON - PfCx cross-correlation')
 
 %Parejas excitatorias 2 y 33. inhibitoora 2 y 22
