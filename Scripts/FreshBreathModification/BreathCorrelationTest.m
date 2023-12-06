clearvars
close all
clc

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_dynamics_VGAT.txt';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

% k = 1;
%%
R = 1;
KWIKfile = KWIKfiles{R};
FilesKK = FindFilesKK(KWIKfile);
TrialSets{1} = FT(R):LT(R);
efd = EFDmaker(KWIKfile);


[a,b] = fileparts(FilesKK.AIP);
RESPfile = [a,filesep,b,'.resp'];
[InhTimes,PREX,POSTX,RRR,BbyB] = resp_loader(RESPfile);
Fs = 2000;

for V = 1:length(efd.ValveTimes.PREXIndex)
    tracewin = [-.5 .5];
    tracewinx = tracewin(1)+1/Fs:1/Fs:tracewin(2);
    
    tracewin_s = [tracewin(1)*Fs tracewin(2)*Fs];
    tracewin_sx = tracewin_s(1)+1:tracewin_s(2);
    brwin = 0:1;
    
    for B = 1:length(brwin)
        PI = round(PREX(efd.ValveTimes.PREXIndex{V}(FT(R):LT(R))+brwin(B))*Fs);
        bmatIDX = bsxfun(@plus,tracewin_sx,PI');
        bmatIDX(bmatIDX<0) = 1;
        btr{V,B} = (RRR(bmatIDX)-mean(RRR(bmatIDX(:))))/std(RRR(bmatIDX(:)));
    end
end

a = cat(3,btr{:});
aa = permute(a,[1,3,2]);
aaa = reshape(aa,size(aa,1)*size(aa,2),[]);
%%

for V = 1:length(efd.ValveTimes.PREXIndex)
    figure(V);
    clf
printpos([100 200 150*length(brwin) 500])
    for B = 1:length(brwin)
        corrcheck(V,B,:) = corr(mean(aaa)',btr{V,B}');
        for T = 1:10
            subplotpos(length(brwin),10,B,T,.2)
            if corrcheck(V,B,T) > .2
                plot(btr{V,B}(T,:),'k')
                ylim([-3 3])
                axis off
            else
                plot(btr{V,B}(T,:),'r')
                ylim([-3 3])
                axis off
            end
        end
    end
end



%%

% %%
% figure(1);
% printpos([100 200 1200 500])
% % R = 2;
% % VOI = [4,7,8,12,15,16];
% VOI = [15];
% 
% B = 1;
% cmap = [.3 .3 .8; .7 .7 .7;.5 .5 .5; .3 .3 .3; .1 .1 .1];
% clear P L LN
% clf
% for V = 1:length(VOI)
%     for T = 1:length(relNextIn{R,V,B})
%         subplotpos(length(VOI),length(relNextIn{R,V,B}),V,T,.2)
%         % plotting odor on times
%         h = area([relFT{R,VOI(V),B}(T),relFToff{R,VOI(V),B}(T)],[4 4],-5);
%         h(1).FaceColor = [.5 .5 .5]; h(1).EdgeColor = 'none';
%         hold on
%         
%         h = area([0,relNextIn{R,VOI(V),B}(T)],[4 4],-5);
%         h(1).FaceColor = [.7 .7 1]; h(1).EdgeColor = 'none';
%         
%         %             h = area([relNextIn{R,VOI(V),B}(T),relNextIn{R,VOI(V),B}(T)+relNextIn{R,VOI(V),B+1}(T)],[4 4],-5);
%         %             h(1).FaceColor = [.9 .9 1]; h(1).EdgeColor = 'none';
%         
%         hold on
%         plot(tracewinx,btr{R,VOI(V),B}(T,:),'Color',[.1 .1 .1]);
%         %
%         %             % plotting next inhalation
%         %             %                 for T = 1:length(relNextIn{R,V,B})
%         %             try
%         %                 [P{R,VOI(V),B}(T),L{R,VOI(V),B}(T)] = min(btr{R,VOI(V),B}(T,tracewinx>relNextIn{R,VOI(V),B}(T) & tracewinx<relNextIn{R,VOI(V),B}(T)+.1));
%         %                 L{R,VOI(V),B}(T) = tracewinx(L{R,VOI(V),B}(T)+find(tracewinx>relNextIn{R,VOI(V),B}(T),1));
%         %             catch
%         %                 P{R,VOI(V),B}(T) = nan;
%         %                 L{R,VOI(V),B}(T) = relNextIn{R,VOI(V),B}(T);
%         %             end
%         %             %                 end
%         %
%         %             LN{R,VOI(V),B} = L{R,VOI(V),B}(T)/L{R,VOI(V),1}(T);
%         %
%         %             plot(L{R,VOI(V),B}(T),P{R,VOI(V),B}(T),'b.')
%         
%         xlim([tracewin(1) tracewin(2)])
%         ylim([-5 4])
%         box off; axis off;
%     end
%     
%     %% creating x axis
%     %         if V == length(VOI)
%     %             subplotpos(length(brwin),length(VOI)+.2,B,V+.3,.2)
%     %             plot([tracewin(1) tracewin(2)],[0 0],'k'); hold on;
%     %             xtlist = -1:.5:2;
%     %             for xt = 1:length(xtlist)
%     %                 plot([xtlist(xt) xtlist(xt)],[-.0005 0],'k');
%     %             end
%     %             ylim([-.001 .01])
%     %             xlim([tracewin(1) tracewin(2)])
%     %             box off; axis off;
%     %         end
% end
