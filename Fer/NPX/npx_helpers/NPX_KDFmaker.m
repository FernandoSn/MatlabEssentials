function [KDF, KDFtrials, KDFt, KDFe] = NPX_KDFmaker(Raster, PST, KernelSize, Trials,err)

%err = 4, if std is needed.

if nargin < 5
    err = 2; %Bootstrap
end

     for V = 1:size(Raster,1)     %this computes the number of valves
         if iscell(Trials)
             trials = Trials{V};
         else
             trials = Trials;
         end
        for U = 1:size(Raster,2)  %this computes the number of units???
            if nargin<4
                trials = 1:length(Raster{V,U});
            end
            RA = [];
            for T = 1:length(trials)
                RA(T).Times = Raster{V,U}{trials(T)};
                KDFtrials = [];
%                 if ~isempty(RA(T).Times)
%                     KDFtrials{V,U,T} = NPX_psth(RA(T),KernelSize,'n',PST,0);
%                 else
%                     RA(T).Times = nan;
%                     KDFtrials{V,U,T} = NPX_psth(RA(T),KernelSize,'n',PST,0);
%                 end
            end
            if sum(~cellfun(@isempty,{RA.Times}))>0
                [KDF{V,U},KDFt,KDFe{V,U}] = NPX_psth(RA,KernelSize,'n',PST,err);
            end
        end
     end
end