function [p_correct, TAp_correct]= NPX_decodingMNR2(trdata,trlabel,NumPC,NumTrials)

%trdata = trials by neurons matrix. data to train the model. ie. for an
%experiment where 8 stimuli (20 times each) was presented and 230 neurons
%were simultaneusly recorded, this will be a 160x230 Ma

%trlabel = the trial label associated to a particular stimulus.

%NumPC = number of principal components to use for testing and training.

%NumTrials = trials per stimuli.

p_correct = [];

[~,trdata] = pca(trdata);

trdata = zscore(trdata);

trdata = trdata(:,1:NumPC);

for ii = 1 : size(trdata,1)
    
    idx = true(size(trdata,1),1);
    idx(ii) = false; %Leave one out.

    B = mnrfit(trdata(idx,:),trlabel(idx,:));
    p_correct = [ p_correct;mnrval(B,trdata(ii,:))];
    
    fprintf([num2str(ii),'\n']) %print current trial.
    
end


%Trial averaged matrix.
TAp_correct = [];
for ii =  1 : NumTrials : size(trdata,1)

    TAp_correct = [TAp_correct;nanmean(p_correct(ii:ii+NumTrials-1,:),1)];

end