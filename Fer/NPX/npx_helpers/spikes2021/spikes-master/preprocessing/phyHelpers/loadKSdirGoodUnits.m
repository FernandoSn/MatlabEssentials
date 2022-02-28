function spikeStruct = loadKSdirGoodUnits(ksDir, varargin)

if ~isempty(varargin)
    params = varargin{1};
else
    params = [];
end

if ~isfield(params, 'excludeNoise')
    params.excludeNoise = true;
end
if ~isfield(params, 'loadPCs')
    params.loadPCs = false;
end
if ~isfield(params, 'excludeMUA')%%%FER
    params.excludeMUA = true;
end

% load spike data

spikeStruct = loadParamsPy(fullfile(ksDir, 'params.py'));

ss = readNPY(fullfile(ksDir, 'spike_times.npy'));
st = double(ss)/spikeStruct.sample_rate;
spikeTemplates = readNPY(fullfile(ksDir, 'spike_templates.npy')); % note: zero-indexed

if exist(fullfile(ksDir, 'spike_clusters.npy'))
    clu = readNPY(fullfile(ksDir, 'spike_clusters.npy'));
else
    clu = spikeTemplates;
end

tempScalingAmps = readNPY(fullfile(ksDir, 'amplitudes.npy'));

if params.loadPCs
    pcFeat = readNPY(fullfile(ksDir,'pc_features.npy')); % nSpikes x nFeatures x nLocalChannels
    pcFeatInd = readNPY(fullfile(ksDir,'pc_feature_ind.npy')); % nTemplates x nLocalChannels
else
    pcFeat = [];
    pcFeatInd = [];
end

cgsFile = '';
if exist(fullfile(ksDir, 'cluster_groups.csv')) 
    cgsFile = fullfile(ksDir, 'cluster_groups.csv');
end
if exist(fullfile(ksDir, 'cluster_group.tsv')) 
   cgsFile = fullfile(ksDir, 'cluster_group.tsv');
end
if exist(fullfile(ksDir, 'cluster_info.tsv')) 
   cinfoFile = fullfile(ksDir, 'cluster_info.tsv');
end
if ~isempty(cgsFile)
    [cids, cgs] = readClusterGroupsCSV(cgsFile);

    if params.excludeMUA
        MUAClusters = cids(cgs==1);

        st = st(~ismember(clu, MUAClusters));
        ss = ss(~ismember(clu, MUAClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, MUAClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, MUAClusters));        
        
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, MUAClusters), :,:);
            %pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, MUAClusters));
        cgs = cgs(~ismember(cids, MUAClusters));
        cids = cids(~ismember(cids, MUAClusters));
        
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%FER%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%
    if params.excludeNoise
        noiseClusters = cids(cgs==0);

        st = st(~ismember(clu, noiseClusters));
        ss = ss(~ismember(clu, noiseClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, noiseClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, noiseClusters));        
        
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, noiseClusters), :,:);
            %pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, noiseClusters));
        cgs = cgs(~ismember(cids, noiseClusters));
        cids = cids(~ismember(cids, noiseClusters));
        
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    clu = spikeTemplates;
    
    cids = unique(spikeTemplates);
    cgs = 3*ones(size(cids));
end
    

coords = readNPY(fullfile(ksDir, 'channel_positions.npy'));
ycoords = coords(:,2); xcoords = coords(:,1);
temps = readNPY(fullfile(ksDir, 'templates.npy'));

winv = readNPY(fullfile(ksDir, 'whitening_mat_inv.npy'));


%%REading depths and firing rates.

if ~isempty(cinfoFile)

    [ClusterInfoMat] = readClusterInfoTSV(cinfoFile);
    
    CluDepth = zeros(1,length(cids));
    CluFreq = zeros(1,length(cids));
    CluAmp = zeros(1,length(cids));
    CluContamPct = zeros(1,length(cids));
    
    for ii = 1 : length(cids)

        CluDepth(ii) = ClusterInfoMat(2,ClusterInfoMat(1,:) == cids(ii));
        CluFreq(ii) = ClusterInfoMat(3,ClusterInfoMat(1,:) == cids(ii));
        CluAmp(ii) = ClusterInfoMat(4,ClusterInfoMat(1,:) == cids(ii));
        CluContamPct(ii) = ClusterInfoMat(5,ClusterInfoMat(1,:) == cids(ii));

    end
    
    %Sorting by depth
    TempDepth = [cids;CluDepth;CluFreq;CluAmp;CluContamPct]';

    TempDepth = sortrows(TempDepth,2);
    cids = TempDepth(:,1)';
    CluDepth = TempDepth(:,2)';
    CluFreq = TempDepth(:,3)';
    CluAmp = TempDepth(:,4)';
    CluContamPct = TempDepth(:,5)';

end
spikeStruct.st = st;
spikeStruct.ss = ss;
spikeStruct.spikeTemplates = spikeTemplates;
spikeStruct.clu = clu;
spikeStruct.tempScalingAmps = tempScalingAmps;
spikeStruct.cgs = cgs;
spikeStruct.cids = cids;
spikeStruct.xcoords = xcoords;
spikeStruct.ycoords = ycoords;
spikeStruct.temps = temps;
spikeStruct.winv = winv;
spikeStruct.pcFeat = pcFeat;
spikeStruct.pcFeatInd = pcFeatInd;
spikeStruct.CluDepth = CluDepth;
spikeStruct.CluFreq = CluFreq;
spikeStruct.CluAmp = CluAmp;
spikeStruct.CluContamPct = CluContamPct;