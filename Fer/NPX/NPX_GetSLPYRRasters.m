function [SLR, PYRR, ALLR] = NPX_GetSLPYRRasters(RasterCell, session, probes)

SLR = [];
PYRR = [];
if isfield(RasterCell,'l')
    for probe = probes

        SLR = cat(3,SLR,RasterCell.r{session,probe}(:,:,RasterCell.l{session,probe}));
        PYRR = cat(3,PYRR,RasterCell.r{session,probe}(:,:,~RasterCell.l{session,probe}));

    end
    ALLR = cat(3,PYRR,SLR);
else
    ALLR = [];
    for probe = probes
        ALLR = cat(3,ALLR,RasterCell.r{session,probe});
    end
end