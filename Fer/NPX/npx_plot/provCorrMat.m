%Borrar
% Time1 = 0:0.1:3;
% CorrMatsTime = cell(length(Time1)+1,4);

Time1 = 0:0.5:7;
CorrMatsTime = cell(length(Time1)+1,4);

CorrMatsTime{end,1} = 'L2Choice';
CorrMatsTime{end,2} = 'L3Choice';
CorrMatsTime{end,3} = 'L2Passive';
CorrMatsTime{end,4} = 'L3Passive';

L2 = 1:129;
L3 = 130:302;
T1 = 1:37;
T2 = 38:76;

idx = L2;
Trials = T1;
for ii = 1:length(Time1)
    [ltd, td] = NPX_GetTD(Raster(:,:,idx), [Time1(ii) Time1(ii)+0.5],0.5, Trials);
    CorrMatsTime{ii,1} = NPX_GetTrialAveragedVecSimMat(zscore(td),ltd); 
end

idx = L3;
for ii = 1:length(Time1)
    [ltd, td] = NPX_GetTD(Raster(:,:,idx), [Time1(ii) Time1(ii)+0.5],0.5, Trials);
    CorrMatsTime{ii,2} = NPX_GetTrialAveragedVecSimMat(zscore(td),ltd); 
end

Trials = T2;
for ii = 1:length(Time1)
    [ltd, td] = NPX_GetTD(Raster(:,:,idx), [Time1(ii) Time1(ii)+0.5],0.5, Trials);
    CorrMatsTime{ii,4} = NPX_GetTrialAveragedVecSimMat(zscore(td),ltd); 
end

idx = L2;
for ii = 1:length(Time1)  
    [ltd, td] = NPX_GetTD(Raster(:,:,idx), [Time1(ii) Time1(ii)+0.5],0.5, Trials);
    CorrMatsTime{ii,3} = NPX_GetTrialAveragedVecSimMat(zscore(td),ltd);   
end

save('TACorrMatsxTime500ms','CorrMatsTime')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % NamePDF{1} = 'L2Octans2Choice500ms';
% % NamePDF{2} = 'L3Octans2Choice500ms';
% % NamePDF{3} = 'L2Octans2Passive500ms';
% % NamePDF{4} = 'L3Octans2Passive500ms';
% 
% mCorrMatCell = cell(size(a,1)-1,4);
% %T1 = 0:0.1:3;
% T1 = 0:0.5:7;
% 
% for ii = 1:size(a,1)-1
%    
%     for kk = 1:size(a,2)
%         
%         mCorrMatCell{ii,kk} = mean(cat(3,a{ii,kk},b{ii,kk}),3);
%         
%         
%     end
%     
%         
%     
% end
% 
% NamePDF = 'PinAce1-500ms';
% 
% figure
% x = 10;
% y = 8;
% n = 1;
% set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])
% 
% for kk = 1:size(mCorrMatCell,2)
%     
% %     if mod(n,y) ~= 1    
% %         n = n - (mod(n,y) - 1) + y; 
% %     end
%     
%     while mod(n,y) ~= 1    
%         n = n + 1; 
%     end
%     
% %     if kk == 3
% %             figure
% %             set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])
% %             n = 1;
% %     end
%     
%    for ii = 1:size(mCorrMatCell,1)
% 
%         subplot(x,y,n);
%         n = n+1;
%         imagesc(mCorrMatCell{ii,kk})
%         caxis([-0.5,0.5]);
%         colorbar
%         xticks([])
%         yticks([])
%         
%         if ii == 1
%             title([a{end,kk},' ',NamePDF]);
%         else        
%             title(['t ',num2str(T1(ii)),'-',num2str(T1(ii)+1)]);
%         end
%         
%         han = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',han,'FontName','Times','fontsize',5);
%     
%     end
%     
% end
% 
% Figs2PDF(NamePDF);



