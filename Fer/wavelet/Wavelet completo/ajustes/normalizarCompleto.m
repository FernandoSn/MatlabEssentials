function normalizarCompleto(molde,canalObj,limiteSuperior,name)


%funcion para normalizar un registro con respecto a un molde

factorNorm = getFacNorma(molde,canalObj,limiteSuperior,name);
normalizarReg(factorNorm)


%for ii = 1:size(canalObj,2)
%            
%            fprintf('canal %u\n',ii);
%            
%            canalObj(:,ii)=canalObj(:,ii).*factorNorm(ii);
%            
%end

%registroNormalizado = canalObj;