function NPX_ScatterPlot(score,trials,drawLines,transparency,cm,varargin)

figure
stimuli = size(score,1) / trials;


% Colors = [0, 0.4470, 0.7410;
%           	0.8500, 0.3250, 0.0980;
%           	0.9290, 0.6940, 0.1250;
%           	0.4940, 0.1840, 0.5560;
%           	0.4660, 0.6740, 0.1880;
%           	0.3010, 0.7450, 0.9330;
%           	0.6350, 0.0780, 0.1840;
%             0,0,0];

%Colors = winter;
%Colors = spring;
%Colors = cool;

if isempty(cm)
    Colors = winter;
else
    Colors = cm;
end


%Colors = summer;
%Colors = autumn;
%Colors = parula;

% if ~isempty(varargin{1})
%    
%     
% end

Colors = Colors(1:floor(256./(stimuli-1)):end,:);



Dim = size(score,2);

        
%figure;
hold on;


%Stimuli = size(score,1) / trials;
n = 1;

%Dim = size(score,2);

alphafrac = 1/trials;
alpha = alphafrac;

for ii = 1:size(score,1)
    
    if mod(ii,trials) == 1 || trials == 1
        
        if transparency
            alpha = alphafrac;
        else
            alpha = 1;
        end
        color = Colors(n,:);
        
        if drawLines && Dim == 2
            line(score(ii: ii + trials - 1,1),score(ii: ii + trials - 1,2),'Color',color);
        elseif drawLines && Dim == 3
            line(score(ii: ii + trials - 1,1),score(ii: ii + trials - 1,2),...
                score(ii: ii + trials - 1,3),'Color',color);
        end
        
        n = n + 1;
        
        if n > size(Colors,1)
            
            n = 1;
            
        end
    end
    
    if Dim == 2
        
       scatter(score(ii,1),score(ii,2),'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerFaceAlpha',alpha,'MarkerEdgeAlpha',alpha)
       
    elseif Dim == 3
       scatter3(score(ii,1),score(ii,2),score(ii,3),'MarkerFaceColor',color,'MarkerEdgeColor',color,'MarkerFaceAlpha',alpha,'MarkerEdgeAlpha',alpha)
    %     scatter3(mean(score(ini:ini+Trials-1,1))...
    %         ,mean(score(ini:ini+Trials-1,2)),mean(score(ini:ini+Trials-1,3))) 
        
    end
    
    if transparency
        alpha = alpha + alphafrac;
        if alpha > 1; alpha = 1; end
    end


end

if Dim == 3
   
    
%     if ~isempty(varargin{1})
%         
%         xlabel(['PC1  ', num2str(varargin{1}(1)),'%'])
%         ylabel(['PC2  ', num2str(varargin{1}(2)),'%'])
%         zlabel(['PC3  ', num2str(varargin{1}(3)),'%'])
%         a = get(gca,'XTickLabel');
%         set(gca,'XTickLabel',a,'FontName','Times','fontsize',10);
%     
%     else
%         xlabel('PC1')
%         ylabel('PC2')
%         zlabel('PC3')
%     end

    
    %view(-45,15)
 
    %view(-45,20); %carv2m18L3
    %view(-145,18); %carv2m19L3
    %view(128,30); %carv2m20L3
    
    %view(-136,51); %carv2m18L2
    %view(-228,20); %carv2m19L2
    %view(63,30); %carv2m20L2
    
    %view(-28,35); %etbuvalm18L3
    %view(154,28); %etbuvalm19L3
    %view(124,21); %etbuvalm20L3
    
    %view(45,38); %etbuvalm18L2
    %view(48,10); %etbuvalm19L2
    %view(115,14); %etbuvalm20L2
    
    %view(71,54); %etbuvalm22L3
    %view(-104,27); %etbuvalm23L3
    
    %view(-30,40); %etbuvalm22L2
    %view(-41,10); %etbuvalm23L2
    
    %view(-111,35); %carvm22L3
    %view(-135,30); %carvm23L3
    
    %view(59,26); %carvm22L2
    %view(159,19); %carvm23L2
    
    %view(172,40)
    
end

%a = [1:10]'; b = num2str(a); c = cellstr(b);

          	