function [FVOpens, FVCloses] = FVSwitchFinder(FVO,t)
%% If FVO is flat, then FVOpens and FVCloses will be empty.
 FVO = FVO-max(FVO)/2;
 SignSwitch = FVO(1:end-1).*FVO(2:end);
 dFVO = diff(FVO);
 if isempty(SignSwitch)|isempty(dFVO)
     O=[];
     C=[];
 else
 O = dFVO>0 & SignSwitch<0;
 C = dFVO<0 & SignSwitch<0;
 end
 
 FVOpens = t(O);
 FVCloses = t(C);
end