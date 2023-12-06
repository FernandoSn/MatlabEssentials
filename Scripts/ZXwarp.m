function [tWarp,tWarpLinear,fullperiod] = ZXwarp (InhTimes,PREX,POSTX,t,Fs)

fullperiod = mean(diff(InhTimes));
inhperiod = mean(POSTX-PREX);

% the problems created by manually adjusting breaths are managed here:

trouble = find(PREX>POSTX);
PREX(trouble) = [];
POSTX(trouble) = [];
InhTimes(trouble) = [];

trouble = find(POSTX(1:end-1)>PREX(2:end));
PREX(trouble) = [];
POSTX(trouble) = [];
InhTimes(trouble) = [];


% We have a spotty low Fs sampling of the breath phase. We
% can only detect it at the zero crossings before and after inhalation. The
% value is zero at the beginning of inhalation. At the end of the
% inhalation the value is the average period of inhalation. And right
% before the preinhalation crossing the value is the average length of
% a breath cycle.



a = find(ismember(PREX-1/Fs,POSTX));
PREX(a) = [];
POSTX(a) = [];
InhTimes(a) = [];

X = [PREX';POSTX';(PREX')-1/Fs];

% V makes cyclical warp
V = [zeros(length(InhTimes),1); inhperiod*ones(length(InhTimes),1); fullperiod*ones(length(InhTimes),1)];
tWarp = interp1(X,V,t,'linear','extrap');

% V2 makes continuous/linear warp
PREITV = (0:length(InhTimes)-1)*fullperiod;
POSTITV = inhperiod*ones(1,length(InhTimes))+(0:length(InhTimes)-1)*fullperiod;
PREPREITV = PREITV;
V2 = [PREITV,POSTITV,PREPREITV];
tWarpLinear = interp1(X,V2,t,'linear','extrap');
end
