clearvars
close all
clc

Catalog = 'Z:\expt_sets\catalogs\telc-emx\ExperimentCatalog_tet_bulb_awk_md2016_ctrlside.txt';

% Catalog = 'Z:\expt_sets\catalogs\VGAT\ExperimentCatalog_dynamics_VGAT_sc.txt';
% Catalog = 'Z:\expt_sets\catalogs\VGAT\ExperimentCatalog_VGAT_TET.txt';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

k = 3;
BreathCorrector(KWIKfiles{k})

% BreathCorrector('Z:\expt_sets\major\170918\epochs\170918-001_bank1.result-1.hdf5')


% k = 1, V = 1:16, T 1:15 done
% k = 2, V = 1:16, T 1:15 done
% k = 3, V = 1:16, T 1:15 done
% k = 4, V = 1:16, T 1:15 done
% k = 5, V = 1:16, T 1:15 done
% k = 6, V = 1:16, T 1:15 done
% k = 7, V = 1:16, T 1:15 done
% k = 8, V = 1:2, T 1:4 done