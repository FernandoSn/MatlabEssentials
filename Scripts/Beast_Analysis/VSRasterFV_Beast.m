function [RasterFV] = VSRasterFV_Beast(ValveTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,1)
        for Conc = 1:size(ValveTimes.PREXTimes,2)
            if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
                [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve,Conc},st','hist');
                RasterFV{Valve,Conc,Unit} = num2cell(CEM,2);
                for k = 1:size(RasterFV{Valve,Conc,Unit},1)
                    RasterFV{Valve,Conc,Unit}{k} = RasterFV{Valve,Conc,Unit}{k}(RasterFV{Valve,Conc,Unit}{k}>-5 & RasterFV{Valve,Conc,Unit}{k} < 10);
                end
            end
        end
    end
    
end