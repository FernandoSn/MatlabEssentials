%Realtime power spectrum display.
%Needs some more work.

close all;
clear variables;

%% PARAMS


f_disp = [0,150]; % the range of frequency to show spectrum over.
channel = 1; %Channel to display. %This is not the actual channel.
collect_time = .05; % collect samples for this time
display_period = .1; % display spectrum every this amount of time



%%

cbmex('open'); % open library

proc_fig = figure; % main display
set(proc_fig, 'Name', 'Close this figure to stop');
xlabel('frequency (Hz)');
ylabel('magnitude (dB)');

cbmex('trialconfig', 1); % empty the BR buffer

%Put this thread to sleep 500ms to have the BR buffer filled with new data.
java.lang.Thread.sleep(500);

[~, ~, continuous_data] = cbmex('trialdata',1);

if size(continuous_data,1) == 0
    
    error('No data available');
    
end

%Get sampling Rate.
fs0 = continuous_data{channel,2};


%Matlab buffer setup
DisplayBuffer = zeros(fs0,1);
DBFI = 1;
DBLI = [];
          

t_disp0 = tic; % display time
t_col0 = tic; % collection time
bCollect = true; % do we need to collect
% while the figure is open

%% Main Loop
while (ishandle(proc_fig))
    
    if (bCollect)
        et_col = toc(t_col0); % elapsed time of collection
        if (et_col >= collect_time)
            [spike_data, t_buf1, continuous_data] = cbmex('trialdata',1); % read some data
            
            % if the figure is still open
            if (ishandle(proc_fig))
                
                % graph all
                
                
                    % get the ii'th channel data
                    data = continuous_data{channel,3};
                    % number of samples to run through fft
                    collect_size = min(size(data), collect_time * fs0);
                    x = data(1:collect_size);
                    %uncomment to see the full rang
                    
                    %remove DC.
                    x = x - mean(x);
                    
                    
                    if DBFI > fs0 
                        
                        DisplayBuffer(1:end-length(x)) = DisplayBuffer(length(x)+1:end);
                        DisplayBuffer(end-length(x)+1 : end) = x;
                        
                    else
                        
                        DBLI = DBFI+length(x)-1;

                        DisplayBuffer(DBFI:DBLI) = x;

                        DBFI = DBLI + 1;
                        
                        
                    end
                    
                    %Power Spectrum.
                    ps = abs(fft(double(DisplayBuffer))).^2;
                    
                    %Frequency vector.
                    f = linspace(0,fs0/2,length(ps)/2);
                    
                    %Find Freq limits.
                    ulimit = find(f>=f_disp(2),1,'first');
                    llimit = find(f>=f_disp(1),1,'first');
                    
                    %Plot Spectrum
                    plot(f(llimit:ulimit),ps(llimit:ulimit));
                    xlabel('frequency (Hz)');ylabel('Squared Voltage');
                
                
                drawnow;
            end
            bCollect = false;
        end
    end
    
    et_disp = toc(t_disp0); % elapsed time since last display
    if (et_disp >= display_period)
        t_col0 = tic; % collection time
        t_disp0 = tic; % restart the period
        bCollect = true; % start collection
    end
end

cbmex('close'); % always close