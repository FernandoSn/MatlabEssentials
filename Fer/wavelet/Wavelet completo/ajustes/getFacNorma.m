function factorNorma = getFacNorma(molde,canalObj,limiteSuperior,name)


%Funcion para obtener el factor de normalizacion de una señal con respecto
%a un "molde"

factorNorma = zeros(size(molde,2),1);

for ii = 1:size(molde,2)
    
    
    segCanalObj=canalObj(limiteSuperior(ii)-10000:limiteSuperior(ii),ii);

    %normalizada = canalObj.*((sum(abs(molde)))./(sum(abs(segCanalObj))));

    factorNorma(ii) = (rms(molde(:,ii))./rms(segCanalObj));

    %normalizada = canalObj.*factorNorma;
    
end

save([name,'.mat'],'factorNorma');