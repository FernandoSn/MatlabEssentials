function [J,relativa,freq]=relativaTapers(data,tapers,nfft,Fs)



if nargin < 4; error('Need all input arguments'); end;
data=change_row_to_column(data);
[NC,C]=size(data); % size of data
[NK K]=size(tapers); % size of tapers
if NK~=NC; error('length of tapers is incompatible with length of data'); end;
tapers=tapers(:,:,ones(1,C)); % add channel indices to tapers
data=data(:,:,ones(1,K)); % add taper indices to data
data=permute(data,[1 3 2]); % reshape data to get dimensions to match those of tapers
data_proj=data.*tapers; % product of data with tapers
J=(fft(data_proj,nfft).^2)/Fs;   % fft of projected data
J=mean(abs(J),2);
freq=0:(Fs/2)/(length(J)/2):Fs/2;
J=J(1:length(freq));
freq=freq';
relativa=J/sum(J);