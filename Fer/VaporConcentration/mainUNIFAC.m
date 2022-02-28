function MoleculesInfo = mainUNIFAC(molecules, liquidFractions,makeplot)

%Molecules = cell array of strings with the name of the molecules. ie. MO
%for mineral oil. DPG dipropylene glycol, ethyl butyrate.

%liquidFraction = fractions of the solvent and solute/s. ie. a 1:10 conc of
%ethyl butyrate in MO is [0.1 , 0.9];
tempsum = round(sum(liquidFractions),10);

if tempsum ~= 1
    error('liquidFractions should add to 1');
end

if length(molecules) ~= length(liquidFractions)
    error('molecules and liquidFractions should be the same length');
end

[~,~,RawExcel] = xlsread('Molecules2.xlsx','','','basic');

% prov = load('Molecules.mat');
% RawExcel = prov.RawExcel;

UNIFACgroups = xlsread('UNIFACgroups.xlsx','','','basic') ;
UNIFACInteractionParams = xlsread('UNIFACInteractionParameters.xlsx','','','basic') ;

%%
%Fill info struct with excel files.

NumComponents = length(molecules);
SGVec = []; %Vector for unique subgroups.
MoleculesInfo.NumComponents = NumComponents;

for ii = 1:NumComponents
    kk = 1;
    while ~strcmp(RawExcel{kk,2},molecules{ii}) 
        kk = kk+1;
    end
    %Filling the struct with all the info we need to calculate the activity
    %coefficients.
    
    %Important first column in subgroups is the UNIFAC subgroup id, second
    %column is the amount of a given subgroup.
    MoleculesInfo.Subgroups{ii} = cell2mat(RawExcel(kk:kk + RawExcel{kk,8}-1,6:7));
    MoleculesInfo.VaporPressure(ii) = RawExcel{kk,9};
    MoleculesInfo.MolecularWeight(ii) = RawExcel{kk,10};
    MoleculesInfo.Density(ii) = RawExcel{kk,11};
    MoleculesInfo.LiquidFractions(ii) = liquidFractions(ii);
    
    SGVec = [SGVec,(MoleculesInfo.Subgroups{ii}(:,1))'];
end

SGVec = sort(unique(SGVec));

%%
%Get variables for UNIFAC.

%Declaring Vars
SGNumMat = zeros(NumComponents, length(SGVec)); %number of Subgroups mat for UNIFAC.
R = zeros(1,length(SGVec)); %Van der Waals volumes.
Q = zeros(1,length(SGVec)); %Van der Waals surface area.
MolarFrac = zeros(1,NumComponents);
Temp = 298.15; %Kelvin (25C).

MGVec = zeros(1,length(SGVec)); %Vector for Main groups.
UNIFACIPmat = zeros(length(MGVec),length(MGVec)); %UNIFAC interaction parameters matrix.

for ii = 1:NumComponents
    for kk = 1:length(SGVec)
       
       idx = MoleculesInfo.Subgroups{ii}(:,1) == SGVec(kk);
       if sum(idx) == 0
           SGNumMat(ii,kk) = 0;
       else
           SGNumMat(ii,kk) = MoleculesInfo.Subgroups{ii}(idx,2);
       end
       
       if ii == 1
           idx = UNIFACgroups(:,1) == SGVec(kk);
           MGVec(kk) = UNIFACgroups(idx,3);
           R(kk) = UNIFACgroups(idx,5);
           Q(kk) = UNIFACgroups(idx,6);
       end
       
    end
end


for ii = 1:NumComponents
    
    MolarFrac(ii) = (MoleculesInfo.Density(ii) / MoleculesInfo.MolecularWeight(ii))...
        *liquidFractions(ii); %Calculating the moles in 1ml of solution.
    %Molarity = Density / MW. Molarity * liquidFraction = moles in 1ml
    %solution.
    
end

MolarFrac = MolarFrac ./ sum(MolarFrac); %Actual Molar Fraction.
MoleculesInfo.MolarFraction = MolarFrac;


%ignore
for ii = 1:NumComponents
    %BadVaporConcentration. Do not use, only for comparison.
    MoleculesInfo.BadVaporConc(ii) = ((MoleculesInfo.VaporPressure(ii)...
        *MoleculesInfo.MolarFraction(ii))/101325) * (10^6);
end

%Filling the Interaction parameters matrix
for ii = 1:size(UNIFACIPmat,1)
    
    for kk = 1:size(UNIFACIPmat,2)
   
        if MGVec(ii) == MGVec(kk)
            
            UNIFACIPmat(ii,kk) = 0;
            
        elseif MGVec(ii) < MGVec(kk)
            
            idx = UNIFACInteractionParams(:,1) == MGVec(ii) &...
                UNIFACInteractionParams(:,2) == MGVec(kk);
            
            UNIFACIPmat(ii,kk) = UNIFACInteractionParams(idx,3);
            
        else
            
            idx = UNIFACInteractionParams(:,1) == MGVec(kk) &...
                UNIFACInteractionParams(:,2) == MGVec(ii);
            
            UNIFACIPmat(ii,kk) = UNIFACInteractionParams(idx,4);
        end
        
    end
    
end

%%
%Calculate molar fraction.

% for ii = 1:NumComponents
%     
%     MolarFrac(ii) = (MoleculesInfo.Density(ii) / MoleculesInfo.MolecularWeight(ii))...
%         *liquidFractions(ii); %Calculating the moles in 1ml of solution.
%     %Molarity = Density / MW. Molarity * liquidFraction = moles in 1ml
%     %solution.
%     
% end
% 
% MolarFrac = MolarFrac ./ sum(MolarFrac); %Actual Molar Fraction.
% MoleculesInfo.MolarFraction = MolarFrac;
% 
% 
% %ignore
% for ii = 1:NumComponents
%     %BadVaporConcentration. Do not use, only for comparison.
%     MoleculesInfo.BadVaporConc(ii) = ((MoleculesInfo.VaporPressure(ii)...
%         *MoleculesInfo.MolarFraction(ii))/101325) * (10^6);
% end
%


%Finally calculating UNIFAC.
MoleculesInfo.AC = UNIFAC(R,Q,SGNumMat,MolarFrac,Temp,UNIFACIPmat);

MoleculesInfo.VaporConc = GetVaporConcentration(MoleculesInfo);



%%
%Make plots

if(makeplot)
    MoleculesPlot = MoleculesInfo;
    AcMat = zeros(101,NumComponents);
    VaporConcMat = zeros(101,NumComponents);
    MolarFrac = [1:-0.01:0;0:0.01:1]';
    for ii = 1:size(MolarFrac,1)
        AcMat(ii,:) = UNIFAC(R,Q,SGNumMat,MolarFrac(ii,:),Temp,UNIFACIPmat);
        MoleculesPlot.AC = AcMat(ii,:);
        MoleculesPlot.MolarFraction = MolarFrac(ii,:);
        VaporConcMat(ii,:) = GetVaporConcentration(MoleculesPlot);
    end
    
    figure
    
    plot(MolarFrac(:,2),AcMat);
    title('Activity Coeff')
    
    figure
    
    plot(MolarFrac(:,2),VaporConcMat);
    title('VaporConc (mg/L)')
    
end
