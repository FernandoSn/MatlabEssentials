function ClusterDepth = NPX_GetClusterDepth(NPXSpikes,TotalClusters)

%To run this func you must be in the Kilosort2 output folder (myKsDir).

%NPXSpikes is the output struct of loadKSdirGoodUnits(myKsDir);

%Returns a N by 2 Matrix. N is the number of good units or clusters. Column
%1 is the cluster/unit id, column 2 is the depth.


%clusterInfo = dlmread('cluster_info.tsv');

% [~,~,clusterInfo] = xlsread('cluster_info.xls','A:A') ;
% %[clusterInfo] = xlsread('cluster_info.xls') ;
% 
% %TotalClusters = zeros(size(clusterInfo.textdata,1) - 1,2);
% TotalClusters = zeros(size(clusterInfo,1) - 1,2);
% 
% for ii = 1 : size(TotalClusters ,1)
% 
%     %TotalClusters(ii,1) = str2double(clusterInfo.textdata{ii + 1,1});
%     %TotalClusters(ii,2) = str2double(clusterInfo.textdata{ii + 1,7});
%     
%     TotalClusters(ii,1) = (clusterInfo{ii + 1,1});
%     TotalClusters(ii,2) = (clusterInfo{ii + 1,7});
%     
% end

ClusterDepth = zeros(length(NPXSpikes.cids),2);
for ii = 1 : size(ClusterDepth,1)
    
    ClusterDepth(ii,:) = TotalClusters(TotalClusters(:,1)...
        == NPXSpikes.cids(ii),:);
    
end