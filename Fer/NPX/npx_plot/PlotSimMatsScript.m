function PlotSimMatsScript(td,base,ltd,inhamp,bsc,NamePDF)

n = 1; %Fig Counter
TTr = 20; %total trials
odors = 8;

figure
x = 10;
y = 8;
%set(gcf, 'Position',  [10, 500, 100 * x, 100 * y])
set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])


n = PlotFigs(td,base,ltd,x,y,n,'All');

for ii = 1:16 
    trb = false(TTr,1);
    trb(ii:ii+4) = true;
    trb = repmat(trb,odors,1); 
    %n = PlotFigs(td(trb,:),base(trb,:),ltd(trb),x,y,n,['tr ',num2str(ii),'-',num2str(ii+4)]);
    n = PlotFigs(td(trb,:),base(:,:),ltd(trb),x,y,n,['tr ',num2str(ii),'-',num2str(ii+4)]);
end

tbool = sum(bsc(2:end,:))>0;
for ii = 1:16 
    trb = false(TTr,1);
    trb(ii:ii+4) = true;
    trb = repmat(trb,odors,1); 
    %n = PlotFigs(td(trb,tbool),base(trb,tbool),ltd(trb),x,y,n,['sigtr ',num2str(ii),'-',num2str(ii+4)]);
    n = PlotFigs(td(trb,tbool),base(:,tbool),ltd(trb),x,y,n,['sigtr ',num2str(ii),'-',num2str(ii+4)]);
end

tbool = (sum(bsc(2:end,:))>0) & (~(bsc(1,:)));
for ii = 1:16 
    trb = false(TTr,1);
    trb(ii:ii+4) = true;
    trb = repmat(trb,odors,1);
    %n = PlotFigs(td(trb,tbool),base(trb,tbool),ltd(trb),x,y,n,['nosigdpgtr ',num2str(ii),'-',num2str(ii+4)]);
    n = PlotFigs(td(trb,tbool),base(:,tbool),ltd(trb),x,y,n,['nosigdpgtr ',num2str(ii),'-',num2str(ii+4)]);
end


for ii = 1:16 
    Sidx = NPX_GetInhSortedIdx(inhamp, ltd, ii:ii+4);
    %n = PlotFigs(td(Sidx,:),base(Sidx,:),ltd(Sidx),x,y,n,['Srtr ',num2str(ii),'-',num2str(ii+4)]);
    n = PlotFigs(td(Sidx,:),base(:,:),ltd(Sidx),x,y,n,['Srtr ',num2str(ii),'-',num2str(ii+4)]);
end

tbool = sum(bsc(2:end,:))>0;
for ii = 1:16 
    Sidx = NPX_GetInhSortedIdx(inhamp, ltd, ii:ii+4);
    %n = PlotFigs(td(Sidx,tbool),base(Sidx,tbool),ltd(Sidx),x,y,n,['Srsigtr ',num2str(ii),'-',num2str(ii+4)]);
    n = PlotFigs(td(Sidx,tbool),base(:,tbool),ltd(Sidx),x,y,n,['Srsigtr ',num2str(ii),'-',num2str(ii+4)]);
end

tbool = (sum(bsc(2:end,:))>0) & (~(bsc(1,:)));
for ii = 1:16 
    Sidx = NPX_GetInhSortedIdx(inhamp, ltd, ii:ii+4);
    %n = PlotFigs(td(Sidx,tbool),base(Sidx,tbool),ltd(Sidx),x,y,n,['Srnosigdpgtr ',num2str(ii),'-',num2str(ii+4)]);
    n = PlotFigs(td(Sidx,tbool),base(:,tbool),ltd(Sidx),x,y,n,['Srnosigdpgtr ',num2str(ii),'-',num2str(ii+4)]);
end





inhb = inhamp>1500 & inhamp<8001;
%n = PlotFigs(td(inhb,:),base(inhb,:),ltd(inhb),x,y,n,'inh1500-8001');
n = PlotFigs(td(inhb,:),base(:,:),ltd(inhb),x,y,n,'inh1500-8001');


tbool = sum(bsc(2:end,:))>0;
%n = PlotFigs(td(inhb,tbool),base(inhb,tbool),ltd(inhb),x,y,n,'siginh1500-8001');
n = PlotFigs(td(inhb,tbool),base(:,tbool),ltd(inhb),x,y,n,'siginh1500-8001');

tbool = (sum(bsc(2:end,:))>0) & (~(bsc(1,:)));
%n = PlotFigs(td(inhb,tbool),base(inhb,tbool),ltd(inhb),x,y,n,'nodpgsiginh1500-8001');
n = PlotFigs(td(inhb,tbool),base(:,tbool),ltd(inhb),x,y,n,'nodpgsiginh1500-8001');





Figs2PDF(NamePDF);
end

function n = PlotFigs(td,base,ltd,x,y,n,tl)
    
    %td = td(:,sum(td)>0);
    %td = td - min(td);
    %td = td./max(td);
    
    
    td = (td - mean(base));%./mean(base);
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