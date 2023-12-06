function AuROCPlot(KWIKfile,varargin)
% function AuROCPlot(KWIKfile, VOI, Cells, Trials, Subplots, Thresh)
%
% KWIKfile = path to KWIK file with all necessary files in same folder
%
% VOI = valves of interest (Ex: [1,2,4,8]), default all valves if null
% vector: []
%
% cells = cluster numbers to analyze (Ex: [133,250,280]), default all
% clusters if null vector: []
%
% trials = trials to analyze in a MATLAB cell (Ex: [{1:10}], default all
% trials if null vector: []
% If your experiment contains multiple conditions divided up into sets of
% trials (like awake or anesthetized or laser on and laser off etc..) you
% can indicate that with something like TrialSets{1} = 1:10; TrialSets{2} =
% 21:30; etc... If you don't put in any TrialSets all trials are analyzed
% at once.
%
% Subplots = any subset or order of the following: ['R','Z','A'], where
% 'R' = Rate, 'Z' = Z-Score, 'A' = AuROC. Default ['R','Z','A'] if null
% vector: []

FilesKK=FindFilesKK(KWIKfile);

%default Trialset (all trials)
if isempty(varargin{3})
    [Scores{1},efd{1}] = SCOmaker(KWIKfile);
else
    for TrialSet=1:length(varargin{3})
        [Scores{TrialSet},efd{TrialSet}] = SCOmaker(KWIKfile,varargin{3}(TrialSet));
    end
end


[a,b] = fileparts(KWIKfile);
STfile = [a,filesep,b,'.st'];
load(STfile,'-mat')

%valves of interest (varargin{1})
if isempty(varargin{1})
    %default all valves
    VOI=1:size(Scores{1}.auROC,1);
else
    VOI=varargin{1};
end

if isempty(varargin{5})
    Thresh='N';
else
    Thresh=varargin{5};
end


if isempty(varargin{4})
    Subplots=['R','Z','A'];
else
    Subplots=varargin{4};
end
%%

    
    close all
    figure
    

for TrialSet=1:length(Scores)
    
    %cells in cell2mat(SpikeTimes.units(2:end)) cell-1 x 1
    %ypos in ypos cell-1 x 1
    
    pos = cell2mat(SpikeTimes.Wave.Position(2:end)');
    ypos = pos(:,2);
    [sortpos,posdex] = sort(ypos);
    posdex=posdex+1;
    
    %clusternumbers (varargin{2})
    if ~isempty(varargin{2})
        allcells=cell2mat(SpikeTimes.units(posdex))';
        [~,index]=ismember(varargin{2},allcells);
        if any(ismember(0,index))
            error('One or more cells you have input is/are not a good cluster');
        end
        posdex=posdex(sort(index));
    end
    
    BLrates = Scores{TrialSet}.RawRate(1,posdex,1);

    
    printpos([500 200 200*length(Subplots) 400]);
    %set(gcf,'Position',positions)
    %set(gcf,'PaperUnits','points','PaperPosition',[0 0 positions(3:4)],'PaperSize',[positions(3:4)]);
    
    CT=cbrewer('div', 'RdBu',64);
    CT = flipud(CT);
    
    for subplotnum = 1:length(Subplots)
        subplot(1,length(Subplots)*length(Scores),(subplotnum-1)*length(Scores)+TrialSet)
        
        switch Subplots(subplotnum)
            
            case 'R'
                imagesc(Scores{TrialSet}.RawRate(VOI,posdex,1)')
                colormap(hot)
                caxis([0 25])
                % axis off
                set(gca,'XTick',[],'YTick',[])
                h = colorbar;
                set(h,'location','southoutside')
                set(h,'XTick',[])
                
                rrcbpos = get(h,'position');
                rrcbxlim = get(h,'XLim');
                %hold on
                title('Rate')
                freezeColors
                cbfreeze(h)
                
                % position MO Rate image
                rrlim = get(gca,'CLim');
                rrpos = get(gca,'position');
                %%%%%
                morrpos = [rrpos(1)-.04 rrpos(2) rrpos(3)/7 rrpos(4)];
                axes('position',morrpos)
                imagesc([],[1:length(posdex)],Scores{TrialSet}.RawRate(1,posdex,1)')
                set(gca,'XTick',[],'YTick',[1:length(posdex)],'YTickLabel',SpikeTimes.units(posdex))
                caxis(rrlim)
                % axis off
                freezeColors
                
                % % position Rate histogram
                % axes('position',[rrcbpos(1) rrcbpos(2)-.15 rrcbpos(3) rrcbpos(4)+.02])
                % BLrates = Scores.RawRate(1,posdex(goodies)+1,1,tset);
                % rateedges = 0:0.5:40;
                % [n,bin] = histc(BLrates,rateedges);
                % plot(rateedges+.25,n/length(BLrates),'k','LineWidth',0.3)
                % hold on
                %
                % ODrates = Scores.RawRate(VOI,posdex(goodies)+1,1,tset);
                % ODrates = ODrates(:);
                % rateedges = 0:0.5:40;
                % [n,bin] = histc(ODrates,rateedges);
                % plot(rateedges+.25,n/length(ODrates),'r','LineWidth',0.3)
                % xlim(rrcbxlim)
                % box off
                
            case 'Z'
                imagesc(Scores{TrialSet}.ZScore(VOI,posdex,1)')
                set(gca,'XTick',[],'YTick',[])
                colormap(CT(16:end,:))
                % axis off
                caxis([-2 4])
                h = colorbar;
                set(h,'location','southoutside')
                %hold on
                title('ZScore')
                freezeColors
                cbfreeze(h)
                
                
            case 'A'
                if Thresh == 'Y'
                    v = Scores{TrialSet}.auROC(VOI,posdex,1);
                    sigp = Scores{TrialSet}.AURp(VOI,posdex,1)>.05;
                    v(sigp) = .5;
                    imagesc(v')
                else
                    imagesc(Scores{TrialSet}.auROC(VOI,posdex,1)')
                end
                set(gca,'XTick',[],'YTick',[])
                colormap(CT)
                % axis off
                h = colorbar;
                set(h,'location','southoutside')
                caxis([0 1])
                %hold on
                title('AuROC')
                freezeColors
                cbfreeze(h)
                
        end
    end
end



% position MO Rate image
% arlim = get(gca,'CLim');
% arpos = get(gca,'position');
% morrpos = [arpos(1)+arpos(3)+.02 arpos(2) arpos(3)/4 arpos(4)];
% axes('position',morrpos)
% ypedges = [0:20:280];
% [n,bin] = histc(ypos(goodies),ypedges);
% hh = barh(ypedges+10,n);
% set(hh,'edgecolor','none','facecolor','k')
% ylim([0 275])
% set(gca,'YTick',[0 275])

% axis off
% axis off
