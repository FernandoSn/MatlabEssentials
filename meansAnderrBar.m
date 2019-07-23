home = [88.3; 49.6];
ac = [69.3; 35.3; 11.4];
odor = [30.2; 37.6; 120];
no = [17.1; 78.4];
meanhome = mean(home);
meanac = mean(ac);
meanodor = mean(odor);
meanno = mean(no);
means = [meanhome; meanac; meanno; meanodor];
errhome = std(home)/sqrt(2);
errac = std(ac)/sqrt(3);
errno = std(no)/sqrt(2);
errodor = std(odor)/sqrt(3);
err = [errhome; errac; errno; errodor];
figure; bar(means, 'BarWidth', 0.5, 'FaceColor', [0.5 0.5 0.5]);
hold on
errorbar(means,err,'rx')


%%
clear means
clear err

for k = 1:grps
    means(k) = nanmean(bg(:,k));
    err(k) = nanstd(bg(:,k)/sqrt(length(bg(:,k))));
end

%%

fracplus_off = data2(:,4);
fracminus_off = data2(:,6);
fracminus_on = data2(:,12);
fracplus_on = data2(:,10);

x1 = [1;1;1;1;1];
x2 = [2;2;2;2;2];
x3 = [3;3;3;3;3];
x4 = [4;4;4];
x5 = [5;5;5];
x6 = [6;6;6];
x7 = [7;7;7];
x8 = [8;8;8];
x9 = [9;9;9];
x10 = [10;10];
x11 = [11;11];
x12 = [12;12];