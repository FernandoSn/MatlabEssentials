function [RasterAlign] = VSRasterAlignLaser(LaserTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
        [CEM,~,~] = CrossExamineMatrix(LaserTimes.LaserOn{1},st','hist');
        RasterAlign{1,Unit} = num2cell(CEM,2);
        for k = 1:size(RasterAlign{1,Unit},1)
            RasterAlign{1,Unit}{k} = RasterAlign{1,Unit}{k}(RasterAlign{1,Unit}{k}>-5 & RasterAlign{1,Unit}{k} < 10);
        end
end

end