function [normalizada,factorNorma] = ajusteRegistro(molde,canalObj,limiteSuperior)

segCanalObj=canalObj(limiteSuperior-10000:limiteSuperior);

%normalizada = canalObj.*((sum(abs(molde)))./(sum(abs(segCanalObj))));

factorNorma = (rms(molde)./rms(segCanalObj));

normalizada = canalObj.*factorNorma;


%%%%Se ocupo muy poco, ocupar las otras funciones en su lugar