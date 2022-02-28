function PlotSimMatsScript2(td,base,ltd,inhamp,bsc,NamePDF)
%inhamp = inhamp - min(inhamp);
inhamp = inhamp./max(inhamp);



n = 1; %Fig Counter

figure
x = 10;
y = 8;
%set(gcf, 'Position',  [10, 500, 100 * x, 100 * y])
set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])


n = PlotFigs(td,ltd,x,y,n,'All');

freq = [20,15,10,8];

for ii = 1:length(freq)
   
    tbool = mean(base)<freq(ii);

    for amp = 0:500:max(inhamp)

        inhb = inhamp>(amp) & inhamp<(amp+2000);

        tdp = td(inhb,tbool);
        ltdp = ltd(inhb);

        [~,num] = unique(ltdp);
        num = diff(num);

        if (length(unique(ltdp)) == length(unique(ltd))) && (min(num) > 1)
            n = PlotFigs(tdp,ltdp,x,y,n,['<',num2str(freq(ii)),'Hz ','inh ',num2str(amp+1),'-',num2str(amp+2000)]);
        end

    end

    
end

%for wnd = 2000:1000:8000
for wnd = 0.1:0.1:1
    for amp = 0:0.05:1

        inhb = inhamp>(amp) & inhamp<(amp+wnd);

        tdp = td(inhb,:);
        ltdp = ltd(inhb);

        [~,num] = unique(ltdp);
        num = diff(num);

        if (length(unique(ltdp)) == length(unique(ltd))) && (min(num) > 1)
            n = PlotFigs(tdp,ltdp,x,y,n,['inh ',num2str(amp),'-',num2str(amp+wnd)]);
        end

    end
end

tbool = mean(base)<10000;
inhamp = zscore(inhamp);

for wnd = 0.5:0.5:3
    for amp = -3:0.5:4

        inhb = inhamp>(amp) & inhamp<(amp+wnd);

        tdp = td(inhb,tbool);
        ltdp = ltd(inhb);

        [~,num] = unique(ltdp);
        num = diff(num);

        if (length(unique(ltdp)) == length(unique(ltd))) && (min(num) > 1)
            n = PlotFigs(tdp,ltdp,x,y,n,['Zinh ',num2str(amp),'-',num2str(amp+wnd)]);
        end

    end
end

% tbool = sum(bsc(2:end,:))>0;
% for amp = 0:500:max(inhamp)
%    
%     inhb = inhamp>(amp) & inhamp<(amp+2000);
%     
%     tdp = td(inhb,tbool);
%     basep = base(:,tbool);
%     ltdp = ltd(inhb);
%     
%     [~,num] = unique(ltdp);
%     num = diff(num);
%     
%     if (length(unique(ltdp)) == length(unique(ltd))) && (min(num) > 1)
%         n = PlotFigs(tdp,basep,ltdp,x,y,n,['siginh ',num2str(amp+1),'-',num2str(amp+2000)]);
%     end
%     
% end
% 
% tbool = (sum(bsc(2:end,:))>0) & (~(bsc(1,:)));
% for amp = 0:500:max(inhamp)
%    
%     inhb = inhamp>(amp) & inhamp<(amp+2000);
%     
%     tdp = td(inhb,tbool);
%     basep = base(:,tbool);
%     ltdp = ltd(inhb);
%     
%     [~,num] = unique(ltdp);
%     num = diff(num);
%     
%     if (length(unique(ltdp)) == length(unique(ltd))) && (min(num) > 1)
%         n = PlotFigs(tdp,basep,ltdp,x,y,n,['nodpgsiginh ',num2str(amp+1),'-',num2str(amp+2000)]);
%     end
%     
% end

% inhb = inhamp>1500 & inhamp<8001;
% n = PlotFigs(td(inhb,:),base(inhb,:),ltd(inhb),x,y,n,'inh1500-8001');
% n = PlotFigs(td(inhb,:),ltd(inhb),x,y,n,'inh1500-8001');
% 
% 
% tbool = sum(bsc(2:end,:))>0;
% n = PlotFigs(td(inhb,tbool),base(inhb,tbool),ltd(inhb),x,y,n,'siginh1500-8001');
% n = PlotFigs(td(inhb,tbool),ltd(inhb),x,y,n,'siginh1500-8001');
% 
% tbool = (sum(bsc(2:end,:))>0) & (~(bsc(1,:)));
% n = PlotFigs(td(inhb,tbool),base(inhb,tbool),ltd(inhb),x,y,n,'nodpgsiginh1500-8001');
% n = PlotFigs(td(inhb,tbool),ltd(inhb),x,y,n,'nodpgsiginh1500-8001');





Figs2PDF(NamePDF);
end

function n = PlotFigs(td,ltd,x,y,n,tl)
    
    %td = td(:,sum(td)>0);
    %td = td - min(td);
    %td = td./max(td);
    
    
    %td = (td - mean(base));%./mean(base);
    %td = NPX_GetZScoredPseudoMat(td,base,ltd);
    
    rho = NPX_GetSimMatrix(td, 'corr');
    TACorrMat = NPX_GetTrialAveragedSimMat(rho, ltd);
    
    n = SetSubplot(x,y,n);
    imagesc(TACorrMat)
    colorbar
    SetFigParams(true,tl);
    
    n = SetSubplot(x,y,n);
    plot([0,1,3,5,7,9,10],TACorrMat(2:end,2))
    hold on
    plot([0,1,3,5,7,9,10],TACorrMat(2:end,end))
    SetFigParams(false,''); 

end

function SetFigParams(isMat,txt)

if isMat
   
    xticks([])
    yticks([])
end

title(txt);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',5);

end

function n = SetSubplot(x,y,n)
if n > (x*y)
    figure
    set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])
    n = 1;
end

subplot(x,y,n);
n = n+1;
end