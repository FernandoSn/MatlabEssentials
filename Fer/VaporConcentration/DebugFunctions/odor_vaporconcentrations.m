% Make a calibration curve for each different odorant 
% Check that PID output is what we should be getting theoretically 
% Check that PID output doubles for each (and match for PPM) 
% all vapor pressures at 25 degrees C from thegoodscents company 
% dilute, then a further 2x dilution. Want to deliver ~100 ppm 

%% Ethyl Butyrate
minoil_molfrac = .177
%water_molfrac = .2775 

vp = 12.80 %mmHg (vapor pressure of the pure odorant) at 25 degrees
conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
pressure_atm = 760 % atmospheric pressure in mmHg
density = .875 % wt by volume of pure odorant 
molar_mass = 116.16 % molar mass of pure odorant 

moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
mole_frac = moles./minoil_molfrac;
partial_pressure = vp*mole_frac % using raoult's law
vapor_conc(1,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 

% volume of air in odor vials = 15 mL 
% for 1% odor use 1 L/min airflow 
% for .5% odor use .5 L/min airflow 
% need to find where on the curve starting concentration is the same. 
% %% Isoamyl acetate
% % vapor pressure at 68 degrees = 4 mmHg, at 74.7 degrees = 5 mmHg
% 
% vp = 5.6 %mmHg (vapor pressure of the pure odorant)
% conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% pressure_atm = 760 % atmospheric pressure in mmHg
% density = .876 % density of pure odorant in g/mL
% molar_mass = 130.18 % molar mass of pure odorant 
% 
% moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% mole_frac = moles./minoil_molfrac;
% partial_pressure = vp*mole_frac % using raoult's law
% vapor_conc(2,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% 
% %% 2 hexanone (methyl-butyl-ketone)
% 
% vp = 11.6 % mmHg (vapor pressure of the pure odorant)
% conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% pressure_atm = 760 % atmospheric pressure in mmHg
% density = .812 % density of pure odorant in g/mL
% molar_mass = 100.16 % molar mass of pure odorant 
% 
% moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% mole_frac = moles./minoil_molfrac;
% partial_pressure = vp*mole_frac % using raoult's law
% vapor_conc(3,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% 
% %% Ethyl Tiglate 
% 
% % vp = 4.269 % (vapor pressure of the pure odorant) could only find measurement at 25 celcius 
% % conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% % pressure_atm = 760 % atmospheric pressure in mmHg
% % density = .923 % density of pure odorant in g/mL
% % molar_mass = 128.17 % molar mass of pure odorant 
% % 
% % moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% % mole_frac = moles./water_molfrac;
% % partial_pressure = vp*mole_frac % using raoult's law
% % vapor_conc(4,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% 
% %% Acetophenone 
% % 
% % vp = .397 % (vapor pressure of the pure odorant) could only find measurement at 25 celcius 
% % conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% % pressure_atm = 760 % atmospheric pressure in mmHg
% % density = 1.03 % density of pure odorant in g/mL
% % molar_mass = 120.15 % molar mass of pure odorant 
% % 
% % moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% % mole_frac = moles./water_molfrac;
% % partial_pressure = vp*mole_frac % using raoult's law
% % vapor_conc(5,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% 
% %% Ethyl Acetate 
% 
% % vp = 111.716 % (vapor pressure of the pure odorant) could only find measurement at 25 celcius 
% % conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% % pressure_atm = 760 % atmospheric pressure in mmHg
% % density = .902 % density of pure odorant in g/mL
% % molar_mass = 88.11 % molar mass of pure odorant 
% % 
% % moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% % mole_frac = moles./.177
% % partial_pressure = vp*mole_frac % using raoult's law
% % vapor_conc(6,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% 
% 
% %% Vale (valeraldehyde (pentanal))
% 
% vp = 31.792 % (vapor pressure of the pure odorant) could only find measurement at 25 celcius 
% conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% pressure_atm = 760 % atmospheric pressure in mmHg
% density = .81 % density of pure odorant in g/mL
% molar_mass = 86.13 % molar mass of pure odorant 
% 
% moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% mole_frac = moles./minoil_molfrac;
% partial_pressure = vp*mole_frac % using raoult's law
% vapor_conc(4,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% 
% 
% %% Hexanol
% 
% vp = .947 % (vapor pressure of the pure odorant) could only find measurement at 25 celcius 
% conc = [.0063 .0125 .025 .05 .1 .2 .4 .8 1.6 3.2] % mL of odorant 
% pressure_atm = 760 % atmospheric pressure in mmHg
% density = .8153 % density of pure odorant in g/mL
% molar_mass = 102.17 % molar mass of pure odorant 
% 
% moles = conc*(density/molar_mass) % find mole fraction of the odorant in the mineral oil solution
% mole_frac = moles./minoil_molfrac;
% partial_pressure = vp*mole_frac % using raoult's law
% vapor_conc(5,:) = (partial_pressure./pressure_atm)*(10^6) % in ppm 
% % 
%%
%perc_vol = [.0125 .25 .5 1 2 4 8 16 32]  
figure; hold on 
for i = 1:size(vapor_conc,1) 
    %plot(log10(conc), log10(vapor_conc(i,:)))
    plot(conc, vapor_conc(i,:))
end

%%
for i = 1:size(vapor_conc,1)
    coefficients = polyfit(conc, vapor_conc(i,:),1);
    coeffs(i,:) = coefficients;
    odor_vol(i) = (100 - coeffs(i,2))./coeffs(i,1);
end

