function [SpikeMat,PSTHt] = dpcaPrepper_smooth_loadingSets(Catalog, efds, BinSize, PST)

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
    
    if strcmp(T.VOI(R),'A')
        VOI = [4,7,8,12,15,16];
    elseif strcmp(T.VOI(R),'B')
        VOI = [2,3,4,5,7,8];
    elseif strcmp(T.VOI(R),'C')
        VOI = [11,7,8,6,12,10];
    end
    
    [~, PSTHtrials, PSTHt] = PSTHmaker(efd.ValveSpikes.RasterAlign([1,VOI],:,:), PST, BinSize, Trials);

        realPST = PSTHt>PST(1) & PSTHt<PST(2);
        
        for N = 1:size(PSTHtrials,2)
            for S = 1:size(PSTHtrials,1)
                for Tr = 1:size(PSTHtrials,3)
                    Spikes{R}(N,S,:,Tr) = PSTHtrials{S,N,Tr}(realPST);
                end
            end
        end
        
%         [Y,traindata{R,BS},n_bins(BS)] = BinRearranger(efd.ValveSpikes.RasterAlign,PST,BinSizes(BS),Trials);
   
end
PSTHt = PSTHt(realPST);

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