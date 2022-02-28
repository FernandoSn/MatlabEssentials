allCells_RasterAlign = squeeze(Raster); % get spike counts for each breath cycle 



figure; hold on
for mx = 1:8
plot(mapped(odor_idx{mx},1),mapped(odor_idx{mx},2),'o');
xlabel('PC1')
ylabel('PC2')
xlim([-20 20])
ylim([-20 20])
end