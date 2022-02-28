function plotPairCorrelograms(NPXSpikes,RefUnit,TarUnit,TimeRanges)

for ii = 1:2:length(TimeRanges)

    PlotCorrFromKS2StructStatic(NPXSpikes,RefUnit,TarUnit,TimeRanges(ii:ii+1));

end