function [RasterAlign] = NPX_RasterAlign(ValveTimes,SpikeTimes,Units)

if nargin < 3
    Units = 1:size(SpikeTimes.tsec,1);    
end

for Unit = Units
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,1)
        for Conc = 1:size(ValveTimes.PREXTimes,2)
            if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
                
                if size(st,1) > size(st,2); st=st'; end
                
                [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve,Conc},st,'hist');
                RasterAlign{Valve,Conc,Unit} = num2cell(CEM,2);
                for k = 1:size(RasterAlign{Valve,Conc,Unit},1)
                    RasterAlign{Valve,Conc,Unit}{k} = RasterAlign{Valve,Conc,Unit}{k}(RasterAlign{Valve,Conc,Unit}{k}>-5 & RasterAlign{Valve,Conc,Unit}{k} < 10);
                end
            end
        end
    end
    
end