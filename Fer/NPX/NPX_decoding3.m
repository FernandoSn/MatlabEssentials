function [percentcorrect_times,predictlabel, tslabel]= NPX_decoding3(Raster,RasterPr,TrTrials,TsTrials,TrValves,TestValves,permutations)

%ncells_pseudo = 100;
 
% Decoding over time in trial

%TsTrials = vector with the indices of the trials to train the classifier.
%         ie. 1:100 for the first 100 trials or 'cv' for cross-validation.

%Raster = output cell from VSRasterAlign_Beast or a struct containing a
%         train and a test raster


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

niters = size(tsdata,1);
    



    %training_idx = randsample(length(Raster), ncells_pseudo, false);

    %newdata = Raster(:,training_idx);

    %for timebin = 2:25 % up to 500 ms 

     %   t = [.02:.02:.02*25];

      %  [mylabel, data, ~] = BinRearranger(newdata, [0 t(timebin)], t(timebin), 1:20);
      
      
%pop_size_limit = 150;
pop_size_limit = size(trdata,2);

if nargin < 7
    
    permutations = 200;
    
end

%predictlabel = zeros(permutations,niters,pop_size_limit);
%reallabel = zeros(niters,pop_size_limit);
percentcorrect_times = zeros(permutations,pop_size_limit);

predictlabel = cell(1,permutations);

for permutation = 1:permutations
    
    predictlabel{permutation} = zeros(niters,pop_size_limit);
    for cell_num = 1:pop_size_limit

        cell_idx = randsample(size(trdata,2), cell_num, false);
        %cell_idx = 1:cell_num;
        
        if option == 1
            
            Mdl = fitcknn(trdata(:,cell_idx),trlabel,'NumNeighbors',5);
            
            for ii = 1:niters
            
                predictlabel{permutation}(ii, cell_num) = predict(Mdl,tsdata(ii,cell_idx));

                %reallabel(ii, cell_num) = tslabel(ii);

            end
            
        elseif option == 2
        
            Mdl = fitcknn(trdata(:,cell_idx),trlabel,'NumNeighbors',5,'Leaveout','on');
            
            predictlabel{permutation}(:, cell_num) = kfoldPredict(Mdl);
            
            %reallabel(:, cell_num) = tslabel;
            
        end

        accurate = predictlabel{permutation}(:, cell_num)-tslabel;

        percentcorrect_times(permutation,cell_num) = (sum(accurate == 0)./length(accurate))*100;

    end
    
end