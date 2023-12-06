clearvars
close all
clc

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_pcx_awk_intensity.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));
%%
R = 2;
KWIKfile = KWIKfiles{R};

%% Get File Names
FilesKK = FindFilesKK(KWIKfile);

%% Get Analog Input Info
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);

%% Have to get Final Valve Times to clean up respiration trace
% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

%% BreathProcessing (resp,Fs,t)

% Find respiration cycles.
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);