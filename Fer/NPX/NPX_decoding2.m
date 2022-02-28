function percentcorrect_times = NPX_decoding2(Raster,RasterPr,TrTrials,TsTrials,TrValves,TestValves)

%ncells_pseudo = 100;
 
% Decoding over time in trial

%TrTrials = vector with the indices of the trials to train the classifier.
%         ie. 1:100 for the first 100 trials or 'r' for random.

%Raster = output cell from VSRasterAlign_Beast or a struct containing a
%         train and a test raster


if strcmp(TsTrials,'r')
    
    option = 2;
    
    TsTrials = TrTrials;
    
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

niters = size(tsdata,1);
    



    %training_idx = randsample(length(Raster), ncells_pseudo, false);

    %newdata = Raster(:,training_idx);

    %for timebin = 2:25 % up to 500 ms 

     %   t = [.02:.02:.02*25];

      %  [mylabel, data, ~] = BinRearranger(newdata, [0 t(timebin)], t(timebin), 1:20);
      
      
%pop_size_limit = 150;
pop_size_limit = size(trdata,2);
permutations = 1;

predictlabel = zeros(niters,pop_size_limit);
reallabel = zeros(niters,pop_size_limit);
percentcorrect_times = zeros(permutations,pop_size_limit);

for permutation = 1:permutations
      
    for cell_num = 1:pop_size_limit

        cell_idx = randsample(size(trdata,2), cell_num, false);
        %cell_idx = 1:cell_num;
        
        if option == 1
            Mdl = fitcknn(trdata(:,cell_idx),trlabel,'NumNeighbors',5,'Standardize',1);
        end

        for ii = 1:niters
            
            
            if option == 2
               
                trlabeltemp = trlabel((1:length(trlabel))~=ii);
                trdatatemp = trdata((1:length(trlabel))~=ii,cell_idx);
                
                
                Mdl = fitcknn(trdatatemp,trlabeltemp,'NumNeighbors',5);
            end

            predictlabel(ii, cell_num) = predict(Mdl,tsdata(ii,cell_idx));

            reallabel(ii, cell_num) = tslabel(ii);

        end

        accurate = predictlabel(:, cell_num)-reallabel(:, cell_num);

        percentcorrect_times(permutation,cell_num) = (sum(accurate == 0)./length(accurate))*100;

    end
    
end

% for ii = 1:niters
% 
%     %leaveoneout = randi(size(data,1));
% 
%     %trainlabel = mylabel(find(~ismember(1:size(data,1), leaveoneout)));
% 
%     %traindata = data(find(~ismember(1:size(data,1), leaveoneout)),:);
% 
%     Mdl = fitcknn(trdata,trlabel,'NumNeighbors',5,'Standardize',1);
% 
%     predictlabel(ii) = predict(Mdl,tsdata(ii,:));
% 
%     reallabel(ii) = tslabel(ii);
% 
% end

        

%         accurate = predictlabel-reallabel;
% 
%         percentcorrect_times{f}(timebin-1) = (length(find(accurate == 0))./length(predictlabel))*100;
% 
% % plot the results 
% 
% mean_SO_correct = mean(vertcat(percentcorrect_times{:}));
% 
% se_SO_correct = std(vertcat(percentcorrect_times{:}))./sqrt(length(vertcat(percentcorrect_times{:})));
% 
% se_SO_top = mean_SO_correct + se_SO_correct;
% 
% se_SO_bottom = mean_SO_correct - se_SO_correct;
% 
% hold on; plot(t, mean_SO_correct,'k')
% 
% patch([t fliplr(t)], [se_SO_top fliplr(se_SO_bottom)], 'b', 'EdgeColor', 'b')
% 
% alpha .2