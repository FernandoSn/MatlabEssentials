clear all
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
FilesKK = FindFilesKK(KWIKfile);
TrialSets{1} = FT(R):LT(R);
efd = EFDmaker(KWIKfile);
FVall = cat(2,efd.ValveTimes.FVSwitchTimesOn{:});

[a,b] = fileparts(FilesKK.AIP);
RESPfile = [a,filesep,b,'.resp'];
load(RESPfile,'-mat');
Fs = 2000;

%%
MBL = movingAverage(BbyB.Width, 5); % relative breath length
RBL = BbyB.Width./movingAverage(BbyB.Width, 5); % relative breath length

ShortBreaths = find(RBL<.5);
LongBreaths = find(RBL>1.5);

LongBreaths(LongBreaths<2 | LongBreaths>length(PREX)-2) = [];

%%
close all
clear MX*
for LB = 1:length(LongBreaths)
    maxchange(LB) = ((BbyB.Width(LongBreaths(LB))-MBL(LongBreaths(LB))));
    locale = round(Fs*(PREX(LongBreaths(LB))+.5*MBL(LongBreaths(LB)))) : round(Fs*(PREX(LongBreaths(LB))+1.5*MBL(LongBreaths(LB))));
    
    lwin = (1:length(locale))-round(length(locale)/2);
    lmat = bsxfun(@plus,round(Fs*PREX(LongBreaths(LB)+(-2:2))),lwin');
    localmeanbreath = mean(RRR(lmat),2);
    [acor,lag] = xcorr(RRR(locale),localmeanbreath,'coeff');
    
    
    [MXC(LB),MXL(LB)] = max(acor);
    MXL(LB) = lag(MXL(LB))/Fs;
    
    
    if MXC(LB)>.5 && abs(MXL(LB))<maxchange(LB)
      figure(LB)
    subplot(1,3,1)
    plot((1/Fs:1/Fs:length(RRR(locale))/Fs)-length(locale)/Fs/2,RRR(locale),'k'); hold on;
    plot((1/Fs:1/Fs:length(RRR(locale))/Fs)-length(locale)/Fs/2,localmeanbreath,'b')
    xlim([-.5 .5])
    title([num2str(MXC(LB)),', ',num2str(MXL(LB))])
    axis square
    
    subplot(1,3,2)
    plot(lag/Fs,acor); hold on
    plot([maxchange(LB) maxchange(LB)],[-1 1],'r')
    plot([-maxchange(LB) -maxchange(LB)],[-1 1],'r')
    plot([-maxchange(LB) maxchange(LB)],[.8 .8],'r')
    axis square
    
    subplot(1,3,3)
    plot(RRR((round(Fs*(PREX(LongBreaths(LB))))) : round(Fs*(PREX(LongBreaths(LB))+1))));
    axis square
    hold on;
    plot(round(Fs*(.5*MBL(LongBreaths(LB))))+round(length(locale)/2)+MXL(LB)*Fs,0,'ro')
    end
end
