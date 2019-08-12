delete(instrfindall)
clearvars
close all
clc

cbmex('open')

%% Create trial params
% Miscellany
nseries = 2; % Number of times each odor is presented in a block
nloops = 1;

% Timing
params.TrialLength = 10; % Including presentation time.
params.openTime = 1; % Length of time odor will be presented.

% Panel and Valence
% MFC1 odor pin options: 24 26 28 29 30 31 32 33
% MFC2 odor pin options: 40 41 42 43 44 45 47 49
% 24 and 42 need to always be mineral oil or Beast will flip shit.

% params.odorchannels = [24 26 28:1:33 40 41 43:1:45 47 49];
params.odorchannels = [31];
% params.odorchannels = [24,26,28,29,30,31,32,33,40,41,43,44,45,47,49];

% params.odorconc = [.03 .1 .3 1];
params.odorconc = 10.^-([1.5:-.75:0]);


params.numchannels = length(params.odorchannels); % Number of odors
params.numstimuli = length(params.odorchannels)*length(params.odorconc);

% Mouse
params.mouseID = 'SN1';

%% Start recording
% cbmex('open')
% cbmex('fileconfig', ['C:\data\', datestr(date,'yymmdd'), '-'], 'comments', 1)

%% Big loop over sets of series
for big_loop = 1:nloops
    delete(instrfindall)
    
    %% Initialize Arduinos
    global a;
    global s;
    
    [a,s] = BeastInitializeArduinos(); %global
    writeDigitalPin(a,'D24',1); % Mineral oil valve always open
    writeDigitalPin(a,'D42',1); % Mineral oil valve always open
    writePWMDutyCycle(a,'D8',0.5);
    writePWMDutyCycle(a,'D10',0.5);
    a2sOdorPin = 'D4'; % Pin on A arduino that sends odor data to S arduino %SWITCH
    a2sWaterPin = 'D2'; % Pin on A arduino that sends water data to S arduino %SWITCH
    a2sFVPin = 'D3';
    MFC1 = 'D8'; % 0.5LPM at rest
    MFC2 = 'D10'; % 0.5LPM at rest

    pause(2)
    
    %% Create file to store recording data
    expphase = 'Odor';
    [behaviorfilename] = InitBehaviorFileTest(expphase);
    
    %% Create parameter file
    [pt,b] = fileparts(behaviorfilename);
    bh_prm_filename = fullfile(pt,[b,'.bh_prm']);
    save(bh_prm_filename,'params','-mat')
    
    %% For each chunk of trials
    T = 0;
    for series = 1:nseries
        
        % create random permutation of the odor valves
        [mfcVal,DC] = BeastMyFlo(params.numchannels, params.odorchannels, params.odorconc);
        randomizer = randperm(params.numstimuli);
        rv = mfcVal(randomizer,:);
        DC = DC(randomizer,:);
        
        % create a log of the times. This will be paired with above odor log
        for i = 1:params.numstimuli
            t_trial = tic;
            
            % PID capture
            channel_in = 130;
            cbmex('mask', 0, 0);
            cbmex('mask', channel_in, 1);
            cbmex('trialconfig',0); % start library collecting data
            cbmex('trialconfig',1); % start library collecting data
            
            % Calibrate MFC2 and MFC3
            writePWMDutyCycle(a,MFC1,rv(i,2));
            writePWMDutyCycle(a,MFC2,rv(i,3));
            
            % Open Odor Valve
            BeastValveOpener(rv(i),a2sOdorPin);
            fprintf('Valve %d \n',rv(i,1))
            fprintf('Series: %d \n', series)
            fprintf('Loop: %d \n', big_loop)
            fprintf('Conc: %.2f \n', DC(i,1))
            
            pause(6)
            
            % Monitor respiration for 2 seconds to establish mean
            resp_monitor_time = 2;
%             channel_in = 133;
%             cbmex('mask', 0, 0)
%             cbmex('mask', channel_in, 1)
%             cbmex('trialconfig',1); % acquire data
            
            [~, VOdata] = BeastDataMonitor(behaviorfilename, resp_monitor_time, rv(i,1), DC(i,1), DC(i,2));
            [VOCell] = BeastDataSort(rv(i,1), rv(i,2), rv(i,3), VOdata);
            
%             pause(resp_monitor_time);
%             [time, respdata] = cbmex('trialdata'); % read data
%             rd = respdata{1,3};
%             rsd = std(double(rd));
%             rsmean = mean(double(rd));
            
            % Monitor respiration for exhalation and deliver odor
%             cbmex('trialconfig',0);
%             cbmex('trialconfig',1);
            pause(.1) % acquire 100msec of resp data
            
            t_inh = tic;
            passfail = 0;
%             while toc(t_inh)<5 % keep this up for 5 seconds.
%                 [time, respdata] = cbmex('trialdata'); % read data
%                 trd = respdata{1,3};
%                 
%                 inhpeak = trd<(rsmean-rsd); % inhalation trough logical
%                 rising = trd(end)>rsmean; % exhalation crossing the mean logical
%                 passfail = (sum(inhpeak)*sum(rising))>0; % was there an inh followed by an exh?
%                 
%                 if passfail == 1
%                     BeastFinalValveOpener(a2sFVPin, VOCell, toc(t_trial), behaviorfilename)
%                     pause(params.openTime)
%                     cbmex('trialconfig',0);
%                     break
%                 end
%                 pause(.05)
%             end
            
            if passfail ~= 1
                BeastFinalValveOpener(a2sFVPin, VOCell, toc(t_trial), behaviorfilename)
%                 cbmex('trialconfig',0);
                pause(params.openTime)
            end
            
            % Close Final Valve
            BeastFinalValveCloser(a2sFVPin, VOCell, toc(t_trial), behaviorfilename)
            
            % Calibrate MFC1 and MFC2
            writePWMDutyCycle(a,MFC1,.5);
            writePWMDutyCycle(a,MFC2,.5);
            
            % Close Odor Valve
            BeastValveCloser(rv(i),a2sOdorPin);
            BeastDataMonitor(behaviorfilename, resp_monitor_time, rv(i,1), DC(i,1), DC(i,2));
            
            [Yr,Ir] = sort(params.odorchannels);
            [Y,I] = sort(params.odorconc);

            odor_plot_idx = find(Yr == rv(i,1));
            conc_plot_idx = find(Y == DC(i,1));

            % Collect PIDdata
            [~, temp] = cbmex('trialdata'); % read data
            PIDdata{odor_plot_idx,conc_plot_idx,series} = smooth(downsample(double(temp{1,3}),5),11)/4;
            Fs = 2000/5;
            current_data = PIDdata{odor_plot_idx,conc_plot_idx,series};
            t = 1/Fs:1/Fs:(length(current_data)/Fs);
            cbmex('trialconfig',0); 

            % Plot PIDdata
            figure(1)
            printpos([300 300 300*params.numchannels 300])
            subplot(2,length(Ir),odor_plot_idx)
            colors = flipud(parula(ceil(length(params.odorconc)*3)));
            colors = colors(end-floor((length(colors)/2)):end,:);
           
            plot(t,current_data,'color',colors(conc_plot_idx,:)); hold on;
            xlim([1 params.TrialLength])
            YL = ceil(max(cell2mat(cellfun(@max,PIDdata(odor_plot_idx,:),'uni',0)))/100)*100;
            ylim([0 YL])
            axis square
                        
            current_max = max(current_data(t > 9 & t < 9.1));
            
            subplot(2,length(Ir),odor_plot_idx+length(Ir))
            tr_col = hot(ceil(nseries*2));
            plot(log10(DC(i,1)),log10(current_max),'.','color',tr_col(series,:), 'markersize',20); hold on
            xlim([-3 0.5])
            axis square
            ylim([1 4])
            
            % Prepare for new trial
            T = T+1;
            pause(params.TrialLength-toc(t_trial))
        end
    end
    fclose(s);
end