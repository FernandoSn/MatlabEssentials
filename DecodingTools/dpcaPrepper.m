function [SpikeMat,PSTHt] = dpcaPrepper(Catalog, efds, BinSize, PST)

%% Read that catalog
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

%% Concatenate the catalogued data [X,Y,n_bins]
% We need equal number of trials for each experiment
min_trials = min(LT-FT)+1;

% Preallocate
traindata = cell(length(KWIKfiles),length(BinSize));
n_bins = nan(size(BinSize));

% Collect binned data, flattened into a column
for R = 1:length(KWIKfiles)
    efd = efds(R);
    Trials = FT(R):FT(R)+min_trials-1;
    
        [~, PSTHtrials, PSTHt] = PSTHmaker(efd.ValveSpikes.RasterAlign, PST, BinSize, Trials);
        
        for N = 1:size(PSTHtrials,2)
            for S = 1:size(PSTHtrials,1)
                for T = 1:size(PSTHtrials,3)
                    Spikes{R}(N,S,:,T) = PSTHtrials{S,N,T};
                end
            end
        end
        
%         [Y,traindata{R,BS},n_bins(BS)] = BinRearranger(efd.ValveSpikes.RasterAlign,PST,BinSizes(BS),Trials);
   
end

%% Concatentate across experiments
SpikeMat = cat(1,Spikes{:});

%% Do celltyping.
    Type = 'Sorted';
    specialparams = [];
    [~, TypeStack] = CellTyper(Catalog, Type, specialparams);
    
    SpikeMat = SpikeMat(TypeStack{1},:,:,:,:);

% Concatenate across experiments.
% for BS = 1:length(BinSizes)
%     X{BS} = cat(2,traindata{:,BS});
% end

end