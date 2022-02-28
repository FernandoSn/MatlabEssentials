clc
clear all
close all
format long g
%Developer: Saeed Mardani

%This code is calculating the UNIFAC group contribution method for mixtures
%It can be used in estimation of thermodynamic activities of mixtures.

%This code was developed as a part of a larger program developed in
%MATLAB(R)during 2017. 

%This code can be used as an open source software by developers. 
%I do not accept any responsibility concerning the problems may happen by
%using this code!



%THIS EXAMPLE WAS AVAILABLE IN PAGE 295 OF THE BOOK: Gmehling, J., Kolbe, B., Kleiber, M., Rarey, J., 2012. Chemical Thermodynamics for Process Simulation, 1st ed. Wiley-VCH.

%Calculate the VLE of the system n-hexane (1)-2-butanone (2) at 60 'C for a mole
%fraction of x1 = 0 . 5 with the help of the UNIFAC method assuming ideal behavior
%of the vapor phase.

% THIS EXAMPLE WAS IMPLEMENTED IN MATLAB TO CALCULATE THE UNIFAC GROUP
% CONTRIBUTION METHOD, LATER, THIS CODE WAS USED TO CALCULATE THE
% ACTIVITIES FOR 6 COMPOUNDS AVAILABLE IN A MIXTURE WHICH WAS PERFORMING
% WELL.
R=[0.9011 0.6744 1.6724];
Q=[0.848 0.540 1.488];
C=[2 4 0;1 1 1];
x=[0.5 0.5];
T=333.15; 
anm=[0.0 0.0 476.4;
    0.0 0.0 476.4;
    26.76 26.76 0.0];
activity=UNIFAC(R,Q,C,x,T,anm)


function u=UNIFAC(R,Q,C,x,Treactor,anm)
format long g
s=size (C);
r=zeros(1,s(1));
q=zeros(1,s(1));
V=zeros(1,s(1));
F=zeros(1,s(1));

X=zeros(1,s(2));

%r and q calculation
for j=1:s(1)
   r(j)=C(j,:)*R'; 
   q(j)=C(j,:)*Q';
end  
%V and F calculation
for j=1:s(1)
    V(j)=r(j)/(x*r');
    F(j)=q(j)/(x*q');
    lnGammaC(j)=1-V(j)+log (V(j))-5*q(j)*(1-V(j)/F(j)+log (V(j)/F(j)));         %Calculation of combinatorial part
end

%PSI caculation, all the values are devided by the temperature (T), for the
%diagonal values PSI=1;
SI=exp(-anm/Treactor);

% X calculation (for groups)
for j=1:s(1)
    ngroups(j)=sum(C(j,:));
    CALC1(j)=ngroups(j)*x(j);%This i just a middle calculator for the calculation of X
end
CALC2=sum(CALC1);

for j=1:s(2)
    CALC3(j)=x*C(:,j);
end
Xgroups=CALC3/CALC2;
%teta for groups
for j=1:s(2)
    teta(j)=Xgroups(j)*Q(j)/sum(Xgroups.*Q);
end
%middle calculation for group Gamma calculations
for j=1:s(2) 
    CALC4(j,:)=teta.*SI(j,:);
end
for j=1:s(2) 
    CALC5(j,:)=teta.*SI(:,j)';
end
for i=1:s(2)
    for j=1:s(2)
        CALC6(j)=CALC4(i,j)/sum(CALC5(j,:));
    end
    lnY(i)=Q(i)*(1-log(teta*SI(:,i))-sum(CALC6)); %Group activity coefficients for the binary system
end
%Xpure calculation
for i=1:s(1)
    for j=1:s(2)
        Xpure(i,j)=C(i,j)/sum(C(i,:));
        
    end
end
%Teta pure calculation
for i=1:s(1)
    for j=1:s(2)
      
        CALC7(i,j)=Q(j)*Xpure(i,j); 
        
    end
    tetapure(i,:)=CALC7(i,:)./sum(CALC7(i,:)); %in this case teta pure is different for each component, while it was similar for the previous case
end

%middle calculation for pure Gamma calculations
for i=1:s(1)    
    for j=1:s(2)  
        CALC8(j)=tetapure(i,:)*SI(:,j); %this is for calculation of "denominator" part
        CALC9(j,:)=tetapure(i,:).*SI(j,:);%this is for calculation of "numerator" part
    end
    for j=1:s(2)
        CALC10(i,j)=sum(CALC9(j,:)./CALC8);
        CALC11(i,j)=log(sum(tetapure(i,:).*SI(:,j)'));

    end
    for j=1:s(2)
        
        lnYpure(i,j)=Q(j)*(1-CALC11(i,j)-CALC10(i,j));

    end
end

for j=2:s(1)    
    lnY(j,:)=lnY(1,:);
end

CALCl2=C.*(lnY-lnYpure);
for j=1:s(1)
    lnGammaR(j)=sum(CALCl2(j,:));
end
lnGamma=lnGammaR+lnGammaC;


u=exp(lnGamma);

end