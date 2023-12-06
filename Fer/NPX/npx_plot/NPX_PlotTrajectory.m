function NPX_PlotTrajectory(td,stimuli,trials,cm)

td  = zscore(td(:,1:end));
[~,score,~,~] = pca(td);
%score = score(:,1:6);

%score = run_umap(score(:,1:6),'metric','cosine','min_dist',0.09,'n_neighbors',15,'n_components',3,'verbose','none');
%score = run_umap(td,'metric','cosine','min_dist',0.09,'n_neighbors',15,'n_components',3,'verbose','none');
%score = run_umap(score(:,1:6),'metric','cosine','min_dist',0.799,'n_neighbors',199,'n_components',3,'verbose','none');

figure
hold on;

% Colors = [0, 0.4470, 0.7410;
%           	0.8500, 0.3250, 0.0980;
%           	0.9290, 0.6940, 0.1250;
%           	0.4940, 0.1840, 0.5560;
%           	0.4660, 0.6740, 0.1880;
%           	0.3010, 0.7450, 0.9330;
%           	0.6350, 0.0780, 0.1840;
%             0,0,0];

%Colors = winter;
%Colors = spring;
%Colors = cool;
%Colors = summer;
%Colors = autumn;
%Colors = parula;

if isempty(cm)
    Colors = winter;
else
    Colors = cm;
end


Colors = Colors(1:floor(256./(stimuli-1)):end,:);
%Dim = size(score,2);
samples = size(score,1) ./ trials ./ stimuli;


n = 0;
c = 0;

for ii = 1:samples:size(score,1)

    if mod(n,size(score,1)./stimuli) == 0
        c = c+1;
    end

    plot3(score(ii:ii+samples-1,1),score(ii:ii+samples-1,2),score(ii:ii+samples-1,3),...
        'color',Colors(c,:));

    n = n+samples;

end
          	