function [ClusterInfoMat] = readClusterInfoTSV(filename)

fid = fopen(filename);
C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s');
fclose(fid);

%Provisinal trick to check if cluster Ids are missing fields (Bug in phy2)
WeirdIds = cellfun(@str2num, C{10}(2:end), 'uni', false); 
WeirdIds = cellfun(@isempty, WeirdIds);

%WeirdAmp = cellfun(@str2num, C{2}(2:end), 'uni', false); 
WeirdDepth = cellfun(@str2num, C{4}(2:end), 'uni', false); 
WeirdRates = cellfun(@str2num, C{5}(2:end), 'uni', false);

cids = cellfun(@str2num, C{1}(2:end), 'uni', false);
ContamPct = cellfun(@str2num, C{3}(2:end), 'uni', false);
Amp = cellfun(@str2num, C{2}(2:end), 'uni', false);
ClusterDepth = cellfun(@str2num, C{7}(2:end), 'uni', false);
Rates = cellfun(@str2num, C{8}(2:end), 'uni', false);

ContamPct(WeirdIds) = {nan};
%Amp(WeirdIds) = WeirdAmp(WeirdIds);
Amp(WeirdIds) = {nan};
ClusterDepth(WeirdIds) = WeirdDepth(WeirdIds);
Rates(WeirdIds) = WeirdRates(WeirdIds);



ise = cellfun(@isempty, cids);
cids = [cids{~ise}];
ise = cellfun(@isempty, ContamPct);
ContamPct = [ContamPct{~ise}];
ise = cellfun(@isempty, Amp);
Amp = [Amp{~ise}];
ise = cellfun(@isempty, ClusterDepth);
ClusterDepth = [ClusterDepth{~ise}];
ise = cellfun(@isempty, Rates);
Rates = [Rates{~ise}];

ClusterInfoMat = [cids;ClusterDepth;Rates;Amp;ContamPct];