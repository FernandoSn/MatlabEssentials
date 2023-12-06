function [RasterAlign,FVphase] = NPX_RasterPhaseAlign(ValveTimes,SpikeTimes,PREX,FVtimes)

%Generates a phase Raster with respect to the respiration cylce. each cycle
% has a length of 1 ie. first cycle after odor onset [0 1].

%FVtimes a cell array contaning 2 matrices Odors x Trials with FV openings
%and closings timestamps.

if nargin == 4
    
    FVphase = cell(1,2);
    FVphase{1} = zeros(size(FVtimes{1},1),size(FVtimes{1},2));
    FVphase{2} = FVphase{1};
    
else
    
    FVphase = [];
    
end


Units = 1:size(SpikeTimes.tsec,1);    


% cycleVec = -5:15; %5 cycles before odor onset and 20 cycles after odor onset
cycleVec = 0:4; %5 cycles before odor onset and 20 cycles after odor onset

for Unit = Units
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,1)
        for Conc = 1:size(ValveTimes.PREXTimes,2)
            if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
                
                if size(st,1) > size(st,2); st=st'; end
                
                [CEM,~,~] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve,Conc},st,'hist');
                RasterAlign{Valve,Conc,Unit} = num2cell(CEM,2);
                
                if (Unit == 1) && (nargin == 4)
                    
                    FVtimes{1}(Valve,:) = FVtimes{1}(Valve,:) - ValveTimes.PREXTimes{Valve,Conc};
                    FVtimes{2}(Valve,:) = FVtimes{2}(Valve,:) - ValveTimes.PREXTimes{Valve,Conc};
                                          
                end
                    
                for k = 1:size(RasterAlign{Valve,Conc,Unit},1)
                    
                    Resp = PREX - ValveTimes.PREXTimes{Valve,Conc}(k);
                    OdorIdx = find(Resp==0,1);
                    Resp = Resp(OdorIdx+cycleVec(1):OdorIdx+cycleVec(end));
                    
%                     Resp = Resp((Resp>=-2) & (Resp<4));                  
%                     cycleVec = -sum(Resp<-0.01):sum(Resp>0.01);
                                       
                    RasterAlign{Valve,Conc,Unit}{k} = RasterAlign{Valve,Conc,Unit}{k}(RasterAlign{Valve,Conc,Unit}{k}>=Resp(1) & RasterAlign{Valve,Conc,Unit}{k} < Resp(end));
                    
                    temp = [];
                    for ii = 1:(length(Resp)-1)
                       
                        idx = (RasterAlign{Valve,Conc,Unit}{k} >= Resp(ii)) & (RasterAlign{Valve,Conc,Unit}{k} < Resp(ii+1));
                        
                        if sum(idx) ~= 0
                            temp = [temp,cycleVec(ii) + (RasterAlign{Valve,Conc,Unit}{k}(idx) - Resp(ii)) ./ (Resp(ii+1) - Resp(ii))];
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                       
                        if (Unit == 1) && (nargin == 4)
                                                       
                            if (FVtimes{1}(Valve,k) >= Resp(ii)) && (FVtimes{1}(Valve,k) < Resp(ii+1))
                                FVphase{1}(Valve,k) = cycleVec(ii) + (FVtimes{1}(Valve,k) - Resp(ii)) ./ (Resp(ii+1) - Resp(ii));
                            end
                            
                            if (FVtimes{2}(Valve,k) >= Resp(ii)) && (FVtimes{2}(Valve,k) < Resp(ii+1))
                                FVphase{2}(Valve,k) = cycleVec(ii) + (FVtimes{2}(Valve,k) - Resp(ii)) ./ (Resp(ii+1) - Resp(ii));
                            end
                            
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                    
                    RasterAlign{Valve,Conc,Unit}{k} = temp;
                    
                    
                end
            end
        end
    end
    
end