function [CM, ACC] = SubsetCrossTimeClassifier(trainlabel, traindata, task)

if nargin<3
    DISTANCE = 'euclidean';
elseif ~isfield(task,'DISTANCE')
    DISTANCE = 'euclidean';
end

if isfield(task,'taskstim')
    num_jobs = length(task.taskstim);
else
    num_jobs = 1;
end

%%
for j = 1:num_jobs
    templabel = trainlabel;
    tempdata = traindata;
    
    templabel = templabel(ismember(trainlabel,task.taskstim{j}),:);
    tempdata = tempdata(ismember(trainlabel,task.taskstim{j}),:,:);
    
    %     tempdata = shake(tempdata,1);
    %     templabel = shake(templabel,1);
    obsindex = 1:length(templabel);
    
    for o = obsindex
        for bin = 1:size(tempdata,2)
            
            trl = templabel(obsindex ~= o);
            trd = tempdata(obsindex~=o,bin,:);
            clslist = unique(trl,'stable');
            
            % classifier has a bug on identical data due to nanmeans of floats
            % being slightly different depending on the number of trials
            % averaged.  we will add noise <<< 1 and
            % >>> than the difference this error (eps is relative accuracy).
            BigDiff = eps*10^4;
            AddedNoise = (rand(size(trd))*BigDiff);
            trd = trd+AddedNoise;
            
            % model "training"
            for cls = 1:length(clslist)
                clsmean(cls,:) = nanmean(trd(trl == clslist(cls),:),1);
            end
            % model is trained
            
            
            
            for binX = 1:size(tempdata,2)
                % testing
                distances = pdist([squeeze(tempdata(o,binX,:))';clsmean],DISTANCE);
                distances = distances(1:length(clslist));
                if isfield(task,'notes')
                    if strcmp(task.notes,'NRA') && ismember(find(clslist==templabel(o)),task.fixup{j})
                        distances(clslist == templabel(o)) = nan;
                    end
                end
                [~, pred(o,bin,binX)] = min(distances);
            end
        end
    end
    
    pred = clslist(pred);
    
    % calculate accuracy
    for bin = 1:size(tempdata,2)
        for binX = 1:size(tempdata,2)
            CM{j}(bin,binX,:,:) = confusionmat(templabel,squeeze(pred(:,bin,binX)));
            CM{j}(bin,binX,:,:) = bsxfun(@rdivide,squeeze(CM{j}(bin,binX,:,:)),sum(squeeze(CM{j}(bin,binX,:,:)),2));
            ACC(bin,binX) = mean(diag(squeeze(CM{j}(bin,binX,:,:))));
        end
    end
%     
%     % calculate accuracy. This will become more complicated
%         CM{j} = confusionmat(templabel,pred);
%         CM{j} = bsxfun(@rdivide,CM{j},sum(CM{j},2));
%         ACC(j) = mean(diag(CM{j}));
%         N(j) = length(templabel);
%         
end

% ACC = mean(ACC);

end

