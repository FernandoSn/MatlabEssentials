function [X,Y,n_bins] = PseudoPopulator(Catalog, efds, BinSizes, PST)

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
    
    for BS = 1:length(BinSizes)
        [Y,traindata{R,BS},n_bins(BS)] = BinRearranger(efd.ValveSpikes.RasterAlign,PST,BinSizes(BS),Trials);
    end
end

% Concatenate across experiments.
for BS = 1:length(BinSizes)
    X{BS} = cat(2,traindata{:,BS});
end

end