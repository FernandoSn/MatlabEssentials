function RefCorrsMat = RefineCorrCppMat(CorrsMat,Interval, varargin)

%This is a must after SpikeTrainAnalysis

%This function verifies that the significant correlations obtained by the
%SpikeTrainAnalysis in C++ are in the -5ms to 5ms interval, that is
%monosynaptic putative interactions. This is just a helper func so I
%don't have to rewrite the C++ program.

NoCorrs = size(CorrsMat,1); %Number of correlations of the original Matrix
Offset = 3; %Number of columns not corresponding to the actual corr
Correction = 1; %This correction is just to compensate for the way Matlab handles Matrices.
NewInter = 10; %New interval in ms.

First = 4; %index of the first value of the corr data.

Ini = Interval/2 + Offset - NewInter/2 + Correction; %Initial index
Fin = Ini + NewInter - Correction;

MaxV = Offset + 3*Interval + 3 + 2;
MinV = Offset + 3*Interval + 3 + 1;

RefCorrsMat = [];

for ii = 1:NoCorrs
    
    Ex = sum( CorrsMat(ii,Ini:Fin) > CorrsMat(ii,MaxV) );

    In = sum( CorrsMat(ii,Ini:Fin) < CorrsMat(ii,MinV) );
    
    if (Ex || In)
              
        Vec2Concat = CorrsMat(ii,:);
        
        if ~isempty(varargin)
            %This adds the depth to the units in the correlation in the las
            %two colums of the matrix
            cludepth = varargin{1};
            
            
            if (length(varargin) > 1) && varargin{2}
                
                switch Vec2Concat(1)
                    case 3
                        Vec2Concat(1) = 2;
                        Vec2Concat = FlipVecHelper(Vec2Concat, Interval, First);
                    case 6
                        Vec2Concat(1) = 5;
                        Vec2Concat = FlipVecHelper(Vec2Concat, Interval, First);
                    case 7
                        if sum( Vec2Concat(Ini:Ini+NewInter/2-1) < Vec2Concat(MinV) )
                            
                        Vec2Concat = FlipVecHelper(Vec2Concat, Interval, First);
                        
                        end
                end
                
            end
            
            Vec2Concat = [Vec2Concat, cludepth(Vec2Concat(2),:)];
            Vec2Concat = [Vec2Concat, cludepth(Vec2Concat(3),:)];
            Vec2Concat = [Vec2Concat, abs(cludepth(Vec2Concat(3),2)...
                - cludepth(Vec2Concat(2),2))];
            
        end
        
        RefCorrsMat = [RefCorrsMat ; Vec2Concat];
        
    end
    
end
    RefCorrsMat = [RefCorrsMat , ones(size(RefCorrsMat,1),1)];
end

function Vec2Concat = FlipVecHelper(Vec2Concat, Interval, First)

%Helper to flip the correlation vector in case of having a lag correlation.

Vec2Concat(2:3) = fliplr(Vec2Concat(2:3));
Vec2Concat(First:First+Interval-1) = fliplr(Vec2Concat(First:First+Interval-1));
Vec2Concat(First+Interval+1:First+Interval*2) = fliplr(Vec2Concat(First+Interval+1:First+Interval*2));
Vec2Concat(First+Interval*2+2:First+Interval*3+1) = fliplr(Vec2Concat(First+Interval*2+2:First+Interval*3+1));

end

