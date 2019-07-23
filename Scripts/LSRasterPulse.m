function [RasterPulse] = LSRasterPulse(LaserTimes,SpikeTimes)

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
%     for Valve = 1:size(LaserTimes.PREXTimes,2)
        [CEM,~,~] = CrossExamineMatrix(LaserTimes.LaserOn{1},st','hist');
        RasterPulse{1,Unit} = num2cell(CEM,2);
        for k = 1:size(RasterPulse{1,Unit},1)
            RasterPulse{1,Unit}{k} = RasterPulse{1,Unit}{k}(RasterPulse{1,Unit}{k}>-5 & RasterPulse{1,Unit}{k} < 10);
%             RasterPulse{1,Unit}{k} = RasterPulse{1,Unit}{k}(RasterPulse{1,Unit}{k}>0.005 | RasterPulse{1,Unit}{k} < -0.001);
        end
%     end
end

end