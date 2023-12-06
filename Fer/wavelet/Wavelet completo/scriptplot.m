function scriptplot(registro)

    for ii=1:size(registro,2)

        subplot(size(registro,2),1,ii),plot(registro(:,ii));

        %ylim([-2 2])
        
    end