function NPXSpikes = NPX_UnwhitenTemplates(NPXSpikes,wrot,scaleproc)

    whiteningMatrix = wrot/scaleproc;
    whiteningMatrixInv = whiteningMatrix^-1;

    % here we compute the amplitude of every template...
    % unwhiten all the templates
    NPXSpikes.uwtemps = zeros(size(NPXSpikes.temps));
    for t = 1:size(NPXSpikes.temps,1)
        NPXSpikes.uwtemps(t,:,:) = squeeze(NPXSpikes.temps(t,:,:))*whiteningMatrixInv;
    end