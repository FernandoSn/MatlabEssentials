function ZScoredPseudoMat = NPX_GetZScoredPseudoMat2(PseudoMat,trials,options,PriorPseudoMat)

%deprecated old.
if nargin < 3
   error('not enough parameters');
end

if nargin == 3
    
    %The first bloc of trials is always MO.

    Zave = mean(PseudoMat(:,1:trials),2);
    Zstd = std(PseudoMat(:,1:trials)')';

    %Zstd(Zstd == 0) = 1;

    ZScoredPseudoMat = (PseudoMat(:,trials+1:end) - Zave) ./ Zstd;
    
    %(F-Fmin)/Fmax or (F-Fmin)/(Fmax-F).
    
    %ZScoredPseudoMat = (PseudoMat - min(PseudoMat,[],2))./ (-1 .* PseudoMat + max(PseudoMat,[],2));
    
    
    % ZScoredPseudoMat = [];
    % 
    % for ii =  trials + 1 : trials : size(PseudoMat,2)
    %     
    %     ZScoredPseudoMat = [ZScoredPseudoMat,PseudoMat(:,ii:ii+trials-1) - PseudoMat(:,1:trials)];
    %     
    % end
    
    %PseudoMat = PseudoMat';
    %ZScoredPseudoMat = ((PseudoMat - mean(PseudoMat,1))./ std(PseudoMat))';

elseif nargin == 4        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Zave = [];
%     Zstd = [];
%     for ii =  1 : trials : size(PriorPseudoMat,2)
% 
%         Zave = [Zave,mean(PriorPseudoMat(:,ii:ii+trials-1),2)];
%         Zstd = [Zstd,std(PriorPseudoMat(:,ii:ii+trials-1)')'];
% 
%     end
%     ZScoredPseudoMat = [];
%     n = 1;
%     for ii =  1 : trials : size(PseudoMat,2)
%         
%         ZScoredPseudoMat = [ZScoredPseudoMat,(PseudoMat(:,ii:ii+trials-1) - Zave(:,n))./ Zstd(:,n) ];
%         n = n + 1;
% 
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if options == 1
    
        temp1 = [];
        for ii =  1 : trials : size(PseudoMat,2)

            temp1 = [temp1,mean(PseudoMat(:,ii:ii+trials-1),2)];

        end
        
        PseudoMat = temp1;
        
%         temp2 = [];
%         for ii =  1 : trials : size(PriorPseudoMat,2)
% 
%             temp2 = [temp2,mean(PriorPseudoMat(:,ii:ii+trials-1),2)];
% 
%         end
%         
%         PriorPseudoMat = temp2;


    end
    
    
    
    Zave = mean(PriorPseudoMat,2);
    Zstd = std(PriorPseudoMat')';
    
    ZScoredPseudoMat = (PseudoMat - Zave)./Zstd;
    
    %ZScoredPseudoMat = (ZScoredPseudoMat)./max(ZScoredPseudoMat,[],2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end




%discard nan or inf cells

badcell = sum(isinf(ZScoredPseudoMat) | isnan(ZScoredPseudoMat),2);
badcell = badcell == 0;
ZScoredPseudoMat(~badcell,:) = 0;

fprintf('Badcells: %d \n', sum(~badcell))
%

% if options == 1
%     
%     ZScoredPseudoMatAve = [];
%     for ii =  1 : trials : size(ZScoredPseudoMat,2)
% 
%         ZScoredPseudoMatAve = [ZScoredPseudoMatAve,mean(ZScoredPseudoMat(:,ii:ii+trials-1),2)];
% 
%     end
% 
%     ZScoredPseudoMat = ZScoredPseudoMatAve;
% 
% end






%ZScoredPseudoMat = ZScoredPseudoMat(badcell,:);





%%%%%

% Exc = isinf(ZScoredPseudoMat);
% Inh = isnan(ZScoredPseudoMat);
% 
% %ZScoredPseudoMat(Exc) = max(max(ZScoredPseudoMat));
% 
% ZScoredPseudoMat(Exc) = max(max(ZScoredPseudoMat(~isinf(ZScoredPseudoMat))));
% 
% ZScoredPseudoMat(Inh) = min(min(ZScoredPseudoMat));


%%%


