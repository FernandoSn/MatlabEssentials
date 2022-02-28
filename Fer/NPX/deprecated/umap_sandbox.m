function [] = plotMixTrialsPCA(ValveSpikes, MXcomponentlookup_full_efd, MXparams,odorID_ordered, varargin)

% plots responses of neurons to odor mixtures in PCA space, calculates the
% euclidean distance between each cluster (corresponding to odor A, odor B,
% or mixture. 

allValves = horzcat(ValveSpikes{:});
allCells_RasterAlign = squeeze(cat(3,allValves(:).RasterAlign)); % get spike counts for each breath cycle 

switch nargin
    case 4
        cells = 1:size(allCells_RasterAlign,2);
    case 5
        cells = varargin{1};
end

Raster = allCells_RasterAlign(:,:);

[trainlabel, traindata, ~] = BinRearranger(Raster, [0 .3], .3, 1:15);
[mapped, umap, clusterIdentifiers]=run_umap(traindata)

odor_num = size(Raster,1)
trial_num = 15;

for odor = 1:odor_num
odor_idx{odor} = (trial_num*odor)-(trial_num-1):trial_num*odor;
end

% get colormap, dark colors, early trials, lighter colors later trials. 
for t = 1:trial_num
map{1}(t,:) = [1 t*(1/16) t*(1/16)];
map{2}(t,:) = [t*(1/16) 1  t*(1/16)];
map{3}(t,:) = [t*(1/16) t*(1/16) 1];
end

figure;
for mx = 1:length(MXcomponentlookup_full_efd)
subplot(2,3,mx) 
plot(mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)},1),mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)},2), 'LineStyle', '--', 'Color', map{1}(1,:))
hold on;
plot(mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)},1),mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)},2), 'LineStyle', '--', 'Color', map{2}(1,:))
plot(mapped(odor_idx{MXparams.efdMXidx(mx)},1),mapped(odor_idx{MXparams.efdMXidx(mx)},2),'LineStyle', '--', 'Color', map{3}(1,:))
for trial = 1:trial_num
scatter(mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)}(trial),1), mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)}(trial),2), 400, trainlabel(odor_idx{MXcomponentlookup_full_efd(mx,1)}(trial)), '.', 'MarkerEdgeColor', map{1}(trial,:))
scatter(mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)}(trial),1), mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)}(trial),2), 400, trainlabel(odor_idx{MXcomponentlookup_full_efd(mx,2)}(trial)), '.', 'MarkerEdgeColor', map{2}(trial,:))
scatter(mapped(odor_idx{MXparams.efdMXidx(mx)}(trial),1), mapped(odor_idx{MXparams.efdMXidx(mx)}(trial),2),400, trainlabel(odor_idx{MXparams.efdMXidx(mx)}(trial)), '.', 'MarkerEdgeColor', map{3}(trial,:))
end
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
odorA = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,1),:);
odorB = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,2),:);
title([odorA, ' + ', odorB])
end
% 
% plot a single example (zoom)
figure;
for mx = 2
plot(mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)},1),mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)},2), 'LineStyle', '--', 'Color', map{1}(1,:))
hold on;
plot(mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)},1),mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)},2),'LineStyle', '--', 'Color', map{2}(1,:))
plot(mapped(odor_idx{MXparams.efdMXidx(mx)},1),mapped(odor_idx{MXparams.efdMXidx(mx)},2),'LineStyle', '--', 'Color', map{3}(1,:))
for trial = 1:trial_num
scatter(mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)}(trial),1), mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)}(trial),2), 400, trainlabel(odor_idx{MXcomponentlookup_full_efd(mx,1)}(trial)), '.', 'MarkerEdgeColor', map{1}(trial,:))
scatter(mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)}(trial),1), mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)}(trial),2), 400, trainlabel(odor_idx{MXcomponentlookup_full_efd(mx,2)}(trial)), '.', 'MarkerEdgeColor', map{2}(trial,:))
scatter(mapped(odor_idx{MXparams.efdMXidx(mx)}(trial),1), mapped(odor_idx{MXparams.efdMXidx(mx)}(trial),2), 400, trainlabel(odor_idx{MXparams.efdMXidx(mx)}(trial)), '.', 'MarkerEdgeColor', map{3}(trial,:))
end
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
odorA = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,1),:);
odorB = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,2),:);
title([odorA, ' + ', odorB])
end

mapped_ordered = [0,0];
for mx = 1:5
    odors = unique(MXcomponentlookup_full_efd);
    mapped_trials = vertcat([mapped(odor_idx{odors(mx)},1), mapped(odor_idx{odors(mx)},2)]);
    mapped_ordered = vertcat(mapped_ordered, mapped_trials) 
end

for mx = 1:5
    odors = unique(MXcomponentlookup_half_efd);
    mapped_trials = vertcat([mapped(odor_idx{odors(mx)},1), mapped(odor_idx{odors(mx)},2)]);
    mapped_ordered = vertcat(mapped_ordered, mapped_trials) 
end
    
for mx = 1:6
    odors = unique(MXparams.efdMXidx);
    mapped_trials = vertcat([mapped(odor_idx{odors(mx)},1), mapped(odor_idx{odors(mx)},2)]);
    mapped_ordered = vertcat(mapped_ordered, mapped_trials) 
end

mapped_ordered = mapped_ordered(2:end,:);
    
    
distance_mat =  zeros(size(mapped_ordered,1),size(mapped_ordered,1));
for mx = 1:length(MXcomponentlookup_full_efd)
for c1 = 1:size(mapped_ordered,1)
    for c2 = 1:size(mapped_ordered,1)
        distance_mat(c1,c2) = sqrt((mapped_ordered(c2,1)- mapped_ordered(c1,1)).^2 + (mapped_ordered(c2,2)- mapped_ordered(c1,2)).^2);
    end
end
end

max_dist = max(distance_mat); 

figure; imagesc(distance_mat./max_dist)


d = zeros(size(mapped,1),size(mapped,1));
% calculate average PC distance from components vs. other odors 
for mx = 1:length(MXcomponentlookup_full_efd)
for c1 = 1:size(mapped,1)
    for c2 = 1:size(mapped,1)
        d(c1,c2) = sqrt((mapped(c2,1)- mapped(c1,1)).^2 + (mapped(c2,2)- mapped(c1,2)).^2);
    end
end
end

for mx = 1:length(MXcomponentlookup_full_efd)
f = (d(odor_idx{MXcomponentlookup_full_efd(mx,1)},odor_idx{MXcomponentlookup_full_efd(mx,1)}));
a{mx}(1)=mean(f((f~=0)));
b{mx}(1,:)=f(:)';
f = (d(odor_idx{MXcomponentlookup_full_efd(mx,2)},odor_idx{MXcomponentlookup_full_efd(mx,2)}));
a{mx}(2)=mean(f((f~=0)));
b{mx}(2,:)=f(:)';
f = (d(odor_idx{MXparams.efdMXidx(mx)},odor_idx{MXparams.efdMXidx(mx)}));
a{mx}(3)=mean(f((f~=0)));
b{mx}(3,:)=f(:)';
f = (d(odor_idx{MXcomponentlookup_full_efd(mx,1)},odor_idx{MXcomponentlookup_full_efd(mx,2)}));
a{mx}(4)=mean(f((f~=0)));
b{mx}(4,:)=f(:)';
f = (d(odor_idx{MXcomponentlookup_full_efd(mx,1)},odor_idx{MXparams.efdMXidx(mx)}));
a{mx}(5)=mean(f((f~=0)));
b{mx}(5,:)=f(:)';
f = (d(odor_idx{MXcomponentlookup_full_efd(mx,2)},odor_idx{MXparams.efdMXidx(mx)}));
a{mx}(6)=mean(f((f~=0)));
b{mx}(6,:)=f(:)';
end

figure; hold on;
for mx = 1:6
    subplot(2,3,mx); hold on
    for bar_num = 1:6
        bar(bar_num*1.5,mean(b{mx}(bar_num,:))/mean(b{mx}(4,:))) % normalize by cross-odor distance
        %er = errorbar(x,allmeans, allse, allse);
        er.Color = [0 0 0];
        er.LineStyle = 'none';
        xticks([1 2 3 4 5 6]*1.5);
        xticklabels({'repeat A', 'repeat B', 'repeat Mix', 'cross-odor', 'Mix A', 'Mix B'})
        xtickangle(315)
        box off
        ax = gca;
        ax.TickDir = 'out';
        ax.FontSize = 10;
        ylabel({'PCA distance'; 'Norm to cross-odor distance'})
        ylim([0 1])
        pbaspect([1 2 1])
    end
end

for mx = 1:6
    for bar_num = 1:6
        norm_distance(mx,bar_num) = mean(b{mx}(bar_num,:))/mean(b{mx}(4,:)); % normalize by cross-odor distance
    end
end


intra_odor_distance = vertcat(norm_distance(:,1), norm_distance(:,2), norm_distance(:,3));
element_to_mix_dist = vertcat(norm_distance(:,5), norm_distance(:,6));

figure; hold on; plot(ones(length(intra_odor_distance)), intra_odor_distance, 'o')
plot(ones(length(element_to_mix_dist))+.25, element_to_mix_dist, 'o')
boxplot(intra_odor_distance, 'positions', 1)
boxplot(element_to_mix_dist, 'positions', 1.25)
[p, h] = kstest2(intra_odor_distance, element_to_mix_dist)
box off
ax = gca;
ax.TickDir = 'out';
ax.FontSize = 10;
ylabel({'PCA distance'; 'Norm to cross-odor distance'})
ylim([0 1])
xlim([.75 2.25])
axis('square')
% 
% 
% 
% for i = 1:3
% for f = 1:3
%     within_all_cell{i}(f,:) = unique(b{1,i}(f,:));
% end 
% end 
% 
% across_all_cell = b{1,4};
% 
% % for i = 1:2
% % mix_comparison_all_cell{i} = b{1,i};
% % end
% 
% 
% within_all = within_all_cell{:};
% within_all = within_all(:);
% 
% across_all = across_all_cell(:);
% 
% mix_comparison_all = mix_comparison_all_cell{:};
% mix_comparison_all = mix_comparison_all(:); 
% 
% within_all_norm = within_all(:)/(mean(across_all(:)));
% mix_comparison_all_norm = mix_comparison_all(:)/(mean(across_all(:)));
% across_all_norm = across_all(:)/(mean(across_all(:)));
% 
% within_all_mean  = getMeanSE(within_all_norm); 
% across_all_mean = getMeanSE(across_all_norm); 
% mix_comparison_all_mean = getMeanSE(mix_comparison_all_norm); 
% 
% allmeans = [within_all_mean.mean, mix_comparison_all_mean.mean, across_all_mean.mean];
% allse = [within_all_mean.se, mix_comparison_all_mean.se, across_all_mean.se];
% allstd = [within_all_mean.std, mix_comparison_all_mean.std, across_all_mean.std];
% x = 1:3;
% 
% figure; hold on; 
% bar(x,allmeans)
% er = errorbar(x,allmeans, allse, allse);
% er.Color = [0 0 0];
% er.LineStyle = 'none';
% xticks([1 2 3]);
% xticklabels({'repeat', 'mixture', 'cross-odor'})
% xtickangle(315)
% box off 
% ax = gca;
% ax.TickDir = 'out';
% ax.FontSize = 15;
% ylabel({'PCA distance'; 'Norm to cross-odor distance'}) 
% ylim([0 1.00])
% pbaspect([1 2 1])
% 
figure;
for mx = 1:length(MXcomponentlookup_full_efd)
subplot(2,3,mx) 
plot(mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)},1),mapped(odor_idx{MXcomponentlookup_full_efd(mx,1)},2), 'ro')
hold on;
plot(mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)},1),mapped(odor_idx{MXcomponentlookup_full_efd(mx,2)},2),'go')
plot(mapped(odor_idx{MXparams.efdMXidx(mx)},1),mapped(odor_idx{MXparams.efdMXidx(mx)},2), 'bo')
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
odorA = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,1),:);
odorB = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,2),:);
title([odorA, ' + ', odorB])
end

figure; hold on
subplot(1,3,1); hold on 
for mx = 1:length(unique(MXcomponentlookup_full_efd))
odor_idx_idx =  unique(MXcomponentlookup_full_efd);
odorA = odorID_ordered{1}(odor_idx_idx(mx),:);
plot(mapped(odor_idx{odor_idx_idx(mx)},1),mapped(odor_idx{odor_idx_idx(mx)},2), 'o', 'DisplayName', [odorA])
alpha(.5)
%hold on;
%plot(mapped(odor_idx{MXcomponentlookup_half_efd(mx,2)},1),mapped(odor_idx{MXcomponentlookup_half_efd(mx,2)},2),'o', 'DisplayName', [odorA, '+odorB)
%alpha(.5)

%plot(mapped(odor_idx{MXparams.efdMXidx(mx)},1),mapped(odor_idx{MXparams.efdMXidx(mx)},2), 'o', 'DisplayName', [odorA, '+', odorB])
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
axis('square')
end

legend('show')

subplot(1,3,2); hold on 
for mx = 1:length(unique(MXcomponentlookup_half_efd))
odor_idx_idx =  unique(MXcomponentlookup_half_efd);
odorA = odorID_ordered{1}(odor_idx_idx(mx),:);
plot(mapped(odor_idx{odor_idx_idx(mx)},1),mapped(odor_idx{odor_idx_idx(mx)},2), 'o', 'DisplayName', [odorA])
alpha(.5)
%hold on;
%plot(mapped(odor_idx{MXcomponentlookup_half_efd(mx,2)},1),mapped(odor_idx{MXcomponentlookup_half_efd(mx,2)},2),'o', 'DisplayName', [odorA, '+odorB)
%alpha(.5)

%plot(mapped(odor_idx{MXparams.efdMXidx(mx)},1),mapped(odor_idx{MXparams.efdMXidx(mx)},2), 'o', 'DisplayName', [odorA, '+', odorB])
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
axis('square')
end

legend('show')

subplot(1,3,3); hold on 
for mx = 1:length(MXcomponentlookup_full_efd)
odorA = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,1),:);
odorB = odorID_ordered{1}(MXcomponentlookup_full_efd(mx,2),:);
plot(mapped(odor_idx{MXparams.efdMXidx(mx)},1),mapped(odor_idx{MXparams.efdMXidx(mx)},2), 'o', 'DisplayName', [odorA, '+', odorB])
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
axis('square')
end

legend('show')