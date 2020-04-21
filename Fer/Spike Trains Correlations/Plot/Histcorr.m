function a = Histcorr(CorrVec,BinSize,epoch,varargin)

XAxis = -epoch:BinSize:epoch-BinSize;
%figure
a = bar(XAxis,CorrVec,'histc');
set(a,'FaceColor','k','EdgeColor','k');

if ~isempty(varargin)
    
    switch varargin{1}
        
        case 1
            set(a,'FaceColor',[213/255,213/255,213/255],'EdgeColor','k');
            a.FaceAlpha = 0.5;
            return
            
        case 2
            
            set(a,'FaceColor',varargin{2},'EdgeColor',varargin{2});
            a.FaceAlpha = 0.7;
            a.EdgeAlpha = 0.0;
            return
            
        case 3
            
    end
end
    
  

  ylabel('Target Spikes count')
  xlabel('Time from reference spikes (ms)')
