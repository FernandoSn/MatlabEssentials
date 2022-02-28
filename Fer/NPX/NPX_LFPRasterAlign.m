function RasterAlign = NPX_LFPRasterAlign(jsonFile,ValveTimes)

%Gets a raster cell similar to Beast Raster but for LFP.

Fs = 2500;
DsFactor = 2;

LFP = load_open_ephys_binary(jsonFile, 'continuous', 2,'mmap');
LFP = double(LFP.Data.Data(1).mapped(:,:));
LFP = downsample(LFP',DsFactor);
LFP = LFP';
Fs = Fs / DsFactor;

LFP = bsxfun(@minus, LFP, mean(LFP,2)); % removeDC
tm = median(LFP,1);
LFP = bsxfun(@minus, LFP, tm);

[b,a]=butter(2,[1/(Fs/2),500/(Fs/2)]);


for Valve = 1:size(ValveTimes.PREXTimes,1)
    for Conc = 1:size(ValveTimes.PREXTimes,2)
        if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
            
            for Trial = 1:length(ValveTimes.PREXTimes{Valve,Conc})
                
                Sample = round(ValveTimes.PREXTimes{Valve,Conc}(Trial) * Fs);
                %idx = Sample - (Fs/2) : Sample + Fs - 1;
                idx = Sample - Fs : Sample + Fs*2 - 1;
                
                for Channel = 1:size(LFP,1)
                    
                    RasterAlign{Valve,Conc,Channel}{Trial} = ...
                        filtfilt(b,a,LFP(Channel,idx)')';
                    
%                     RasterAlign{Valve,Conc,Channel}{Trial} = LFP(Channel,idx);
                    
                end
            
            end
        end
    end
end