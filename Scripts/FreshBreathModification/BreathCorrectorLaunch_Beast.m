clearvars
close all
clc

% Catalog = 'Z:\expt_sets\catalogs\VGAT\ExperimentCatalog_VGAT_TET_beast.txt';
% 
% 
% T = readtable(Catalog, 'Delimiter', ' ');
% KWIKfiles = T.kwikfile(logical(T.include));

% KWIKfile = 'Z:\expt_sets\mixtures\OB3.3\180407\epochs\180407-001_bank1.result-1.hdf5';
KWIKfile = 'Z:\expt_sets\mixtures\OFC2.3\180419\epochs\180419-001_bank1.result-merged.hdf5';

k = 1;
BreathCorrector_Beast(KWIKfile)

% BreathCorrector('Z:\expt_sets\major\170918\epochs\170918-001_bank1.result-1.hdf5')


% k = 1, V = 1:16, T 1:15 done
% k = 2, V = 1:16, T 1:15 done
% k = 3, V = 1:16, T 1:15 done
% k = 4, V = 1:16, T 1:15 done
% k = 5, V = 1:16, T 1:15 done
% k = 6, V = 1:16, T 1:15 done
% k = 7, V = 1:16, T 1:15 done
% k = 8, V = 1:2, T 1:4 done