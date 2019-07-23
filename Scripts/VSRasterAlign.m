function [RasterAlign] = VSRasterAlign(ValveTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,2)
        if ~isempty(ValveTimes.PREXTimes{Valve})
            [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve},st','hist');
            RasterAlign{Valve,Unit} = num2cell(CEM,2);
            for k = 1:size(RasterAlign{Valve,Unit},1)
                RasterAlign{Valve,Unit}{k} = RasterAlign{Valve,Unit}{k}(RasterAlign{Valve,Unit}{k}>-5 & RasterAlign{Valve,Unit}{k} < 10);
            end
        end
    end
end

end