[s,a,b,p]=spectrogram(reg,2500,0.95*2500,2000,1000,'yaxis');

%codigo de spectrograma, overlap 95%, hamming 2.5seg, nfft 2000(resol),1000
%freq de muestreo y hz en yaxis.

surf(b,a,p,'edgecolor','none');axis tight;set(gca,'ylim',[0,100]);colormap(jet);view(0,90);

%3d spectrogram, visto aqui como 2d con 100 hz de amplitud.