function NPX_decoding(Raster)
%% Decoding as a function of time  

% concatenate cells

% RasterAlign = cat(3, ValveSpikes{1}.RasterAlign);
% 
% ?
% 
% % get odor mixture trials 
% 
% odor_idx = MXparams.efdMXidx;
% 
% Raster = squeeze(RasterAlign(odor_idx,:,:));
% 
% ?
% 
% % set number of cells in pseudopopulation 
% 
ncells_pseudo = 100;
% 
% ?
% 
% % set number of times to run decoder with bootstrapped leave-one our
% 
% % cross-validation 
% 
niters = 100; 
% Decoding over time in trial 

for f = 1

    training_idx = randsample(length(Raster), ncells_pseudo, false);

    newdata = Raster(:,training_idx);

    for timebin = 2:25 % up to 500 ms 

        t = [.02:.02:.02*25];

        [mylabel, data, ~] = BinRearranger(newdata, [0 t(timebin)], t(timebin), 1:20);

        for i = 1:niters

            leaveoneout = randi(size(data,1));

            trainlabel = mylabel(find(~ismember(1:size(data,1), leaveoneout)));

            traindata = data(find(~ismember(1:size(data,1), leaveoneout)),:);

            Mdl = fitcknn(traindata,trainlabel,'NumNeighbors',5,'Standardize',1);

            predictlabel(i) = predict(Mdl,data(leaveoneout,:));

            reallabel(i) = mylabel(leaveoneout);

        end

        

        accurate = predictlabel-reallabel;

        percentcorrect_times{f}(timebin-1) = (length(find(accurate == 0))./length(predictlabel))*100;

    end

end

% plot the results 

mean_SO_correct = mean(vertcat(percentcorrect_times{:}));

se_SO_correct = std(vertcat(percentcorrect_times{:}))./sqrt(length(vertcat(percentcorrect_times{:})));

se_SO_top = mean_SO_correct + se_SO_correct;

se_SO_bottom = mean_SO_correct - se_SO_correct;

hold on; plot(t, mean_SO_correct,'k')

patch([t fliplr(t)], [se_SO_top fliplr(se_SO_bottom)], 'b', 'EdgeColor', 'b')

alpha .2

%% Decoding as a function of cell # 

% get odor mixture trials 

% odor_idx = MXparams.efdMXidx
% 
% Raster = squeeze(RasterAlign(odor_idx,:,:)) %% first, 50ppm odors 
% 
% ?
% 
% % set analysis params
% 
% pop_size_limit = 150;
% 
% analysis_window = .480; 
% 
% n_predictions = 100;
% 
% ?
% 
% [mylabel, data, n_bins] = BinRearranger(Raster, [0 analysis_window], analysis_window, 1:15);
% 
% ?
% 
% ?
% 
% % Decoding for cell #
% 
% for cell_num = 1:pop_size_limit
% 
%     for permutations = 1:n_predictions
% 
%         training_idx = randsample(length(Raster), cell_num, false);
% 
%         newdata = data(:,training_idx);
% 
%         leaveoneout = randi(size(data,1));
% 
%         trainlabel = mylabel(find(~ismember(1:size(data,1), leaveoneout)));
% 
%         traindata = newdata(find(~ismember(1:size(data,1), leaveoneout)),:);
% 
%         Mdl = fitcknn(traindata,trainlabel,'NumNeighbors',5,'Standardize',1);
% 
%         predictlabel(permutations, cell_num-1) = predict(Mdl,newdata(leaveoneout,:));
% 
%         reallabel(permutations, cell_num-1) = mylabel(leaveoneout);
% 
%         accurate = predictlabel(permutations, cell_num-1)-reallabel(permutations, cell_num-1);
% 
%         percentcorrect(permutations, cell_num-1) = accurate;
% 
%     end
% 
% end
% 
% ?
% 
% % plot results
% 
% for columns = 1:size(percentcorrect,2)
% 
%     prop_correct_trials(columns) = length(find(percentcorrect(:,columns) == 0))/size(percentcorrect,1);
% 
% end
% 
% ?
% 
% figure; hold on;
% 
% plot(2:pop_size_limit, prop_correct_trials)
% 
