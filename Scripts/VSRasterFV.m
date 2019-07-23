function [RasterFV] = VSRasterFV(ValveTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,2)
        if ~isempty(ValveTimes.PREXTimes{Valve})
            [CEM,~,~] = CrossExamineMatrix(ValveTimes.FVSwitchTimesOn{Valve},st','hist');
            RasterFV{Valve,Unit} = num2cell(CEM,2);
            for k = 1:size(RasterFV{Valve,Unit},1)
                RasterFV{Valve,Unit}{k} = RasterFV{Valve,Unit}{k}(RasterFV{Valve,Unit}{k}>-5 & RasterFV{Valve,Unit}{k} < 10);
            end
        end
    end
end

end