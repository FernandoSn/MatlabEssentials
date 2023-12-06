function [RT,LT] = GetLickorNoLick(OM)

%Lick or no lick for every trial. This helps to see if mice are licking to
%just one odor.
Right = 2;
Left = 3;


OMR = OM(OM(:,6) == Right,:);

RT = OMR(:,7);
RT(RT == Right | RT == Left) = 1;
RT(RT == Right+2 | RT == Left+2) = 1; %to include bad early trials

RT = smooth(RT,30);
RT = RT(2:end-1);

OML = OM(OM(:,6) == Left,:);

LT = OML(:,7);
LT(LT == Right | LT == Left) = 1;
LT(LT == Right+2 | LT == Left+2) = 1; %to include bad early trials

LT = smooth(LT,30);
LT = LT(2:end-1);

figure
hold on
plot(RT)
plot(LT)
yticklabels({'No Lick','','','','','','','','','','Lick'})
xlabel('trial');
legend('Right trials','Left trials')
ylim([0,1]);
makepretty;
