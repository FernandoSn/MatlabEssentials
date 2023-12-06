function FFTNoise(signal,Fs)

% signal = ((signal ./ 65535) .* 20) - 10;

signal = signal - mean(signal);
figure;plot(signal);

y = abs(fft(signal).^2);


freq = linspace(0,Fs/2,length(y)/2);

figure;
plot(freq, y(1:length(freq)));