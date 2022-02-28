function PIDdata = NPX_VisPID(CPID,CeventsMCC,OlfacMat,Fs,Wnd,Source,isFig,Valves)

%wnd = time window to visualize in seconds

PIDss = CeventsMCC;%(1:705);%(1:2:end); %Samples.

if nargin>7
  [PIDOdorTimes,Odors] = NPX_PREX2Odor(PIDss,OlfacMat,1,Valves);
else
  [PIDOdorTimes,Odors] = NPX_PREX2Odor(PIDss,OlfacMat,1);  
end

%[PIDOdorTimes,Odors] = NPX_PREX2Odor(PIDss(16:end),OlfacMat(16:end,:),1);
%[PIDOdorTimes,Odors] = NPX_PREX2Odor(PIDss,OlfacMat,1,[18]);

PIDdata = cell(length(Odors),1);



if isFig 
    %if length(coloridx) == (length(Trials)-1); coloridx = [coloridx,256];end
    figure
    set(gcf, 'Position',  [10, 500, 250 * length(Odors), 200])
    ColorMap = jet;
end


for odor = 1:length(Odors)
    
  Trials = 1:length(PIDOdorTimes{odor});
  if length(Trials) > 256
        coloridx = repmat(1:256,[1,ceil(length(Trials)/256)]);
  else
    coloridx = 1:floor(256 / (length(Trials))):256;
  end
    
  for trial = 1:length(Trials)
      
      
      if strcmp(Source,'front')
        trace = CPID(PIDOdorTimes{odor}(trial):PIDOdorTimes{odor}(trial) + Fs*Wnd);
        %trace = trace - mean(trace);
        trace = trace - trace(1);
      elseif strcmp(Source,'back')
         trace = CPID(PIDOdorTimes{odor}(trial)-Fs*Wnd:PIDOdorTimes{odor}(trial) + Fs);
         trace = trace - trace(end);
         %trace = trace - mean(trace);
      end
      PIDdata{odor} = [PIDdata{odor};trace];
      
      if isFig
        
        subplot(1,length(Odors),odor);
        hold on
        t = 0:1/Fs:length(PIDdata{odor}(trial,:))/Fs;
        t = t(2:end);
        plot(t,PIDdata{odor}(trial,:),'color',ColorMap(coloridx(trial),:))
        
      end
      
  end
  
  
  
end

for ii = 1:length(Odors)
    subplot(1,length(Odors),ii);
    ylim([min(cell2mat(PIDdata),[],'all')-200, max(cell2mat(PIDdata),[],'all')+200])
    %ylim([-200 500])
end