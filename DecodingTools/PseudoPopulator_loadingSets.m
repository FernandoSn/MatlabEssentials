function [X,Y,n_bins] = PseudoPopulator_loadingSets(Catalog, efds, BinSizes, PST)

%% Read that catalog
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

%% Concatenate the catalogued data [X,Y,n_bins]
% We need equal number of trials for each experiment
min_trials = min(LT-FT)+1;

% Preallocate
traindata = cell(length(KWIKfiles),length(BinSizes));
n_bins = nan(size(BinSizes));

% Collect binned data, flattened into a column
for R = 1:length(KWIKfiles)
    efd = efds(R);
    Trials = FT(R):FT(R)+min_trials-1;
    
    if strcmp(T.VOI(R),'A')
        VOI = [4,7,8,12,15,16];
    elseif strcmp(T.VOI(R),'B')
        VOI = [2,3,4,5,7,8];
    elseif strcmp(T.VOI(R),'C')
        VOI = [11,7,8,6,12,10];
    end
    
    for BS = 1:length(BinSizes)
        [Y,traindata{R,BS},n_bins(BS)] = BinRearranger(efd.ValveSpikes.RasterAlign([1,VOI],:,:),PST,BinSizes(BS),Trials);
    end
end

% Concatenate across experiments.
for BS = 1:length(BinSizes)
    X{BS} = cat(2,traindata{:,BS});
end

end