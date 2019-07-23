function [RasterAlign] = VSRasterAlign_Beast(ValveTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,1)
        for Conc = 1:size(ValveTimes.PREXTimes,2)
            if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
                [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve,Conc},st','hist');
                RasterAlign{Valve,Conc,Unit} = num2cell(CEM,2);
                for k = 1:size(RasterAlign{Valve,Conc,Unit},1)
                    RasterAlign{Valve,Conc,Unit}{k} = RasterAlign{Valve,Conc,Unit}{k}(RasterAlign{Valve,Conc,Unit}{k}>-5 & RasterAlign{Valve,Conc,Unit}{k} < 10);
                end
            end
        end
    end
    
end