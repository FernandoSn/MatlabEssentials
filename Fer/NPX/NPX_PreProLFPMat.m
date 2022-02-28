function dat = NPX_PreProLFPMat(dat)

%Remove DC, CAR and smoothing of LFP data before doing other analyses (coherence, CSD, etc.)

dat = bsxfun(@minus, dat, mean(dat,2)); % subtract median of each channel
tm = median(dat,1);
dat = bsxfun(@minus, dat, tm);

