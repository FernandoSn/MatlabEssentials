function NPX_VideoSimMat(td,ltd,FileName)

BlockSize = 49;
figure
%axis tight manual 
%set(gca,'nextplot','replacechildren');


v = VideoWriter([FileName,'.avi']);
open(v);

ii = 1;
while (ii+BlockSize)<=size(td,2)
    
    units = ii:(ii+BlockSize);
%     rho = NPX_GetSimMatrix(td(:,units), 'corr');
%     imagesc(rho)
    TACorrMat = NPX_GetTrialAveragedVecSimMat(td(:,units),ltd);
    imagesc(TACorrMat)
    xticks([])
    yticks([])
    caxis([-0.5,0.5]);
    colorbar
    
    frame = getframe(gcf);
    
    writeVideo(v,frame);
    
    ii = ii+1;
end

close(v);
close all