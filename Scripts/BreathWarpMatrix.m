function  [warpFmatrix,tFmatrix] = BreathWarpMatrix(RRR,InhTimes,PREX,POSTX,Fs)
inhperiod = mean(POSTX-PREX);
fullperiod = mean(diff(PREX));
exhperiod = fullperiod-inhperiod;
POSTX(PREX>POSTX) = PREX(PREX>POSTX)+inhperiod;

trouble = find(PREX>POSTX);
PREX(trouble) = [];
POSTX(trouble) = [];
InhTimes(trouble) = [];

trouble = find(POSTX(1:end-1)>PREX(2:end));
PREX(trouble) = [];
POSTX(trouble) = [];
InhTimes(trouble) = [];

for i = 1:length(InhTimes)-1
    inhsamples = round((PREX(i)')*Fs):round((POSTX(i)')*Fs);
    exhsamples = round((POSTX(i)')*Fs):round((PREX(i+1)')*Fs);
    fullbreathsamples = [inhsamples,exhsamples];
    warpImatrix(i,:) = interp1(round(inhperiod*Fs)/length(inhsamples):round(inhperiod*Fs)/length(inhsamples):round(inhperiod*Fs) ,RRR(inhsamples),1:round(inhperiod*Fs));
    warpEmatrix(i,:) = interp1(round(exhperiod*Fs)/length(exhsamples):round(exhperiod*Fs)/length(exhsamples):round(exhperiod*Fs) ,RRR(exhsamples),1:round(exhperiod*Fs));
end
warpFmatrix = [warpImatrix,warpEmatrix];
tFmatrix = 0:fullperiod/size(warpFmatrix,2):fullperiod-fullperiod/size(warpFmatrix,2);
end