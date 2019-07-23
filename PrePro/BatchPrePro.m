clearvars
close all
clc

%% For locating responsive cells relative to layer
% turn on Essentials

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\VGAT\ExperimentCatalog_dynamics_VGAT_sc.txt';
% Catalog = 'Z:\expt_sets\catalogs\VGAT\ExperimentCatalog_VGAT_TET_beast.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

for k = 2:length(KWIKfiles)
Paramfile = KWIKfiles{k}(1:findstr('\epochs',KWIKfiles{k}));
SuperPrePro(Paramfile,0,0,1)
end