function NPX_CellOdorPairDistOLD(Scores,PVal,depthclu,DepthRange)

%Deprecated
%get the distribution of signifcant activatd and supressed cells.

if nargin == 4
    
    depthclu = sortrows(depthclu,2);
    
    NPXdepthRangeIdx = find(depthclu(:,2) >= DepthRange(1)...
        & depthclu(:,2)<=DepthRange(2));
    NPXdepthRangeIdx = [NPXdepthRangeIdx(1),NPXdepthRangeIdx(end)];
    
    Scores.AURp = Scores.AURp(:,NPXdepthRangeIdx(1):NPXdepthRangeIdx(2));
    Scores.ZScore = Scores.ZScore(:,NPXdepthRangeIdx(1):NPXdepthRangeIdx(2));
    
end

Valves = size(Scores.AURp,1) - 1; %Number of Valves/odors minus blank.
Units = size(Scores.AURp,2);

BoolInh = (Scores.ZScore < 0) & (Scores.AURp < PVal);
BoolInh = BoolInh(2:end,:);
InhVec = sort(sum(BoolInh,1));

BoolExc = (Scores.ZScore > 0) & (Scores.AURp < PVal);
BoolExc = BoolExc(2:end,:);
ExcVec = sort(sum(BoolExc,1));

InhPer = zeros(1,Valves); %Proportrion vectors.
ExcPer = zeros(1,Valves);

for ii = 1:Valves
   
    InhPer(ii) = sum(InhVec == ii) / Units * 100;
    ExcPer(ii) = sum(ExcVec == ii) / Units * 100;
    
end

figure
plot(InhPer);
figure
plot(ExcPer);

