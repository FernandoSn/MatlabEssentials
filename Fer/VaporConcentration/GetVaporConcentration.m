function VaporConc = GetVaporConcentration(MoleculesInfo)

%Returns Vapor Concentrations of all the elements in a mixture in PPM.
%ie. MO + EtBu or MO + EtBu + Hex, etc.

VaporConc = zeros(1,MoleculesInfo.NumComponents);

for ii = 1:length(VaporConc)
    
    VaporConc(ii) = (MoleculesInfo.MolarFraction(ii)...
        * MoleculesInfo.AC(ii) * MoleculesInfo.MolecularWeight(ii)...
        *  MoleculesInfo.VaporPressure(ii)) / (8.314 * 298.15);
    
    %8.314 is the universal gas constant.
    %298.15 is 25C in Kelvin.
    %Vapor Pressure is in Pa not mmhg!!!
    
end