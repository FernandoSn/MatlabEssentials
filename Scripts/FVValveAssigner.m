function [FVSwitchTimesOn, FVSwitchTimesOff] = FVValveAssigner (FVOpens, FVCloses, VLOpens, NV)

FVSwitchTimesOn = cell(size(VLOpens));
FVSwitchTimesOff = cell(size(VLOpens));

for i = 1:length(VLOpens)
    if ~isempty(VLOpens{i})
        [~,FVSwitchTimesOn{i},~,FVSTOnAssignDist{i}] = CrossExamineMatrix(VLOpens{i},FVOpens,'next');
        [~,FVSwitchTimesOff{i},~] = CrossExamineMatrix(VLOpens{i},FVCloses,'next');
        
        % If the final valve doesn't switch we have a problem where a VL
        % exists but no FV. It gets assigned to the next FV so we get a
        % double sample. If the last valve switch dosn't have an FV opening
        % its distance will be infinity I think. So that's taken care of
        % here too.
        NoFV = abs(FVSTOnAssignDist{i}-median(FVSTOnAssignDist{i}))>2;
        FVSwitchTimesOn{i}(NoFV) = [];
        FVSwitchTimesOff{i}(NoFV) = [];
    end
end

%
% AssignedFVSwitchTimesOn = cat(2,FVSwitchTimesOn{:});
% AssignedFVSwitchTimesOff = cat(2,FVSwitchTimesOff{:});

UnassignedFVSwitchTimesOn = FVOpens(~ismember(FVOpens, cat(2,FVSwitchTimesOn{:})));
UnassignedFVSwitchTimesOff = FVCloses(~ismember(FVCloses, cat(2,FVSwitchTimesOff{:})));

%only assign Unassigned FV switches if there are any (valve 1 or 9 is used)
if ~isempty(UnassignedFVSwitchTimesOn)
   
    if NV(2)<8 %if not all 8 valves on VL 2 are used, there is only one blank (should
    %never use 9)
        EmptyValves=1;
    else %kevin's old files where valve 9 was used as a blank trial as well
        EmptyValves=[1,9];
    end
    
    NumValves=length(EmptyValves);
    for j=1:NumValves
        FVSwitchTimesOn{EmptyValves(j)} = UnassignedFVSwitchTimesOn(j:NumValves:end);
        FVSwitchTimesOff{EmptyValves(j)} = UnassignedFVSwitchTimesOff(j:NumValves:end);
    end
end



end