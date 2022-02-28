function [AvPSTH, Err] = NPX_PlotAveragePSTH(PSTHstruct,Valve,IdxVec, style, color, AddFig)

%PSTHstruct = output of NPX_RasterPSTHPlotter
%Valve could be a scalar or a vector. if it is a vector it will average
%       across those valves.
%IdxVec = indices of the neurons you want to plot.


if isempty(IdxVec)
    
    IdxVec = 1 : size(PSTHstruct.KDF,2);
end
    
% if ischar(Valve) && strcmp('all',Valve)

    PSTHMat = [];

    for ii = 1 : length(Valve)

        PSTHMat = [PSTHMat; cell2mat(PSTHstruct.KDF(Valve(ii),IdxVec)')];

    end

    AvPSTH = mean(PSTHMat,1);
    if size(PSTHMat,1) == 1
        Err = PSTHstruct.KDFe{Valve};
    else
        Err = std(PSTHMat,1) / sqrt(size(PSTHMat,1));
    end
    

% else
% 
%     AvPSTH = mean(cell2mat(PSTHstruct.KDF(Valve,IdxVec)'),1);
%     Err = std(cell2mat(PSTHstruct.KDF(Valve,IdxVec)'),1) / sqrt(length(PSTHstruct.KDF));
% end
    

t = PSTHstruct.KDFt;
AvPSTH = AvPSTH(PSTHstruct.realPST);
Err = Err(PSTHstruct.realPST);

t = t(PSTHstruct.realPST);

Blue = [0, 0.4470, 0.7410];
Red = [0.8500, 0.3250, 0.0980];
Orange = [0.9290, 0.6940, 0.1250];
Green = [0.4660, 0.6740, 0.1880];

if isempty(color); color = [0,0,0]; end

if AddFig == true; figure; end


%ylim([0 9])
%xlim([-1 2])


if style == 1
    
    
    lineProps.width = .35;
    lineProps.col = {color};
    
    mseb(t,AvPSTH,Err,lineProps);
    
elseif style == 2
    
    hold on
    for ii = 1:size(PSTHMat,1)
        plot(t,PSTHMat(ii,PSTHstruct.realPST));
    end
    
elseif style ==3
    
    plot(t,AvPSTH,'color',color,'linewidth',3);
    hold on
    for ii = 1:size(PSTHMat,1)
        plot(t,PSTHMat(ii,PSTHstruct.realPST),'color',[color,0.1]);
    end
    
    
end


xlabel('time(s)')
ylabel('rate(hz)')

%mseb(KDFt,KDF{Valve,Unit},KDFe{Valve,Unit},lineProps);
    
    
