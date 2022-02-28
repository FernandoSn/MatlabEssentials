function [p_correct, TAp_correct]= NPX_decodingMNR(Raster,RasterPr,TrTrials,TsTrials,TrValves,TestValves)

%In progress...

if strcmp(TsTrials,'cv')
    
    if ~isempty(TestValves)
        error('For cross-validation TestValves should be empty');
    end
    
    option = 2;
    
    TsTrials = TrTrials;
    TestValves = TrValves;
    
    %TrTrials = 1:size(Raster{1,1,1});
%     if ~isempty(TsTrials)
%        error('TestTrials should be empty'); 
%     end
      if isstruct(Raster)
          error('Raster should be a cell array'); 
      end

else

    option = 1;
end



if isstruct(Raster)
    
    RasterTr = Raster.training;
    RasterTs = Raster.testing;
    
    
    if isstruct(RasterPr)
        
        RasterTrPr = RasterPr.training;
        RasterTsPr = RasterPr.testing;
        
    elseif ~isempty(RasterPr)
       
        error('RasterPr should be a struct')
        
    end

else
   
    RasterTr = Raster;
    RasterTs = Raster;
    
    if ~isempty(RasterPr)
       
        RasterTrPr = RasterPr;
        RasterTsPr = RasterPr;
        
    end
    
    
end




if (nargin < 5) || (isempty(TrValves) && isempty(TestValves))
    
    TrValves = 1:size(RasterTr,1);
    TestValves = 1:size(RasterTs,1);
    
end




TotalTrialTr = 1:size(RasterTr{1,1,1});

TotalTrialTs = 1:size(RasterTs{1,1,1});



[trlabel, trdata] = BinRearranger(RasterTr, [0 1], 1, TotalTrialTr);
[tslabel, tsdata] = BinRearranger(RasterTs, [0 1], 1, TotalTrialTs);

if ~isempty(RasterPr)

    [~ , trdataPr] = BinRearranger(RasterTrPr, [0 1], 1, TotalTrialTr);
    trdata = NPX_GetZScoredPseudoMat(trdata',length(TotalTrialTr),0,trdataPr')';
    
    [~ , tsdataPr] = BinRearranger(RasterTsPr, [0 1], 1, TotalTrialTs);
    tsdata = NPX_GetZScoredPseudoMat(tsdata',length(TotalTrialTs),0,tsdataPr')';
    
else
    
   trdata = (trdata - mean(trdata,1))./ std(trdata);
   trdata(isnan(trdata)) = 0;
   trdata(isinf(trdata)) = 0;
   
   tsdata = (tsdata - mean(tsdata,1))./ std(tsdata);
   tsdata(isnan(tsdata)) = 0;
   tsdata(isinf(tsdata)) = 0;
    
    
end


idctr = ismember(trlabel,TrValves);

trlabel = trlabel(idctr);

trdata = trdata(idctr,:);

idcts = ismember(tslabel,TestValves); 

tslabel = tslabel(idcts);

tsdata = tsdata(idcts,:);

triallabeltr = repmat(TotalTrialTr,[1,size(RasterTr,1)])';
triallabeltr = triallabeltr(idctr,:);

idctr = ismember(triallabeltr,TrTrials);

trlabel = trlabel(idctr);
trdata = trdata(idctr,:);
triallabeltr = triallabeltr(idctr,:);



triallabelts = repmat(TotalTrialTs,[1,size(RasterTs,1)])';
triallabelts = triallabelts(idcts,:);

idcts = ismember(triallabelts,TsTrials);

tsdata = tsdata(idcts,:);
tslabel = tslabel(idcts,:);
triallabelts = triallabelts(idcts,:);

p_correct = [];

[~,trdata] = pca(trdata);



% trdata = trdata';
% 
% trdata = (trdata - mean(trdata,1))./ std(trdata);
% trdata(isnan(trdata)) = 0;
% trdata(isinf(trdata)) = 0;
% 
% trdata = trdata';

trdata = trdata(:,1:10);

for ii = 1 : size(trdata,1)
    
    idx = true(size(trdata,1),1);
    idx(ii) = false;

    B = mnrfit(trdata(idx,:),trlabel(idx,:));
    p_correct = [ p_correct;mnrval(B,trdata(ii,:))];
    
    fprintf([num2str(ii),'\n'])
    
end

TAp_correct = [];
for ii =  1 : length(TrTrials) : size(trdata,1)

    TAp_correct = [TAp_correct;nanmean(p_correct(ii:ii+length(TrTrials)-1,:),1)];

end