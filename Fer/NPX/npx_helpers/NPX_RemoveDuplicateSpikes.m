function NPXSpikes = NPX_RemoveDuplicateSpikes(NPXSpikes, varargin)
    

    %Based on remove_ks2_duplicate_spikes, included in kilosort 2.5
    

    input_parser = inputParser;
    addParameter(input_parser, 'overlap_s', 5e-4, @(x) (isnumeric(x))) % the temporal window within which pairs of spikes will be considered duplicates (if they are also within the spatial window)
    addParameter(input_parser, 'channel_separation_um', 100, @(x) (ischar(x))) % the spatial window within which pairs of spikes will be considered duplicates (if they are also within the temporal window)
    parse(input_parser, varargin{:});
    P = input_parser.Results;
    

%     spike_times = uint64(rez.st3(:,1));
%     spike_templates = uint32(rez.st3(:,2));
    NPXSpikes.spikeTemplates = NPXSpikes.spikeTemplates+1;
    spike_times = uint64(NPXSpikes.ss);
    spike_templates = uint32(NPXSpikes.spikeTemplates);
    NPXSpikes.spikeTemplates = NPXSpikes.spikeTemplates-1;
    

%     rez.U=gather(rez.U);
%     rez.W = gather(rez.W);
%     templates = zeros(rez.ops.Nchan, size(rez.W,1), size(rez.W,2), 'single');
%     for iNN = 1:size(templates,3)
%        templates(:,:,iNN) = squeeze(rez.U(:,iNN,:)) * squeeze(rez.W(:,iNN,:))';
%     end
%     templates = permute(templates, [3 2 1]); % now it's nTemplates x nSamples x nChannels

    templates = NPXSpikes.temps;
    n_spikes=numel(spike_times);        
    %% Make sure that the spike times are sorted
    if ~issorted(spike_times)
        [spike_times, spike_idx] = sort(spike_times);
        spike_templates = spike_templates(spike_idx);
    else
        spike_idx=(1:n_spikes)';
    end
    %% deal with cluster 0
    if any(spike_templates==0)
        error('Currently this function can''t deal with existence of cluster 0. Should be OK since it ought to be run first in the post-processing.');
    end
    %% Determine the channel where each spike had that largest amplitude (i.e., the primary) and determine the template amplitude of each cluster
%     whiteningMatrix = rez.Wrot/rez.ops.scaleproc;
%     whiteningMatrixInv = whiteningMatrix^-1;
% 
%     % here we compute the amplitude of every template...
%     % unwhiten all the templates
%     tempsUnW = zeros(size(templates));
%     for t = 1:size(templates,1)
%         tempsUnW(t,:,:) = squeeze(templates(t,:,:))*whiteningMatrixInv;
%     end

    % The amplitude on each channel is the positive peak minus the negative
    %tempChanAmps = squeeze(max(tempsUnW,[],2))-squeeze(min(tempsUnW,[],2));

    % The template amplitude is the amplitude of its largest channel
    %[tempAmpsUnscaled,template_primary] = max(tempChanAmps,[],2);
    
    
    
    %without undoing the whitening
    tempChanAmps = squeeze(max(templates, [], 2) - min(templates, [], 2));
    [tempAmpsUnscaled, template_primary] = max(tempChanAmps, [], 2); 

    template_primary = cast(template_primary, class(spike_templates));
    spike_primary = template_primary(spike_templates);

    %% Number of samples in the overlap
    n_samples_overlap = round(P.overlap_s * NPXSpikes.sample_rate);
    n_samples_overlap = cast(n_samples_overlap, class(spike_times));
    %% Distance between each channel
    chan_dist = ((NPXSpikes.xcoords - NPXSpikes.xcoords').^2 + (NPXSpikes.ycoords - NPXSpikes.ycoords').^2).^0.5;
    n_spikes=numel(spike_times);
    remove_idx = [];
    reference_idx = [];
    % check pairs of spikes in the time-ordered list for being close together in space and time. 
    % Check pairs that are separated by N other spikes,
    % starting with N=0. Increasing N until there are no spikes within the temporal overlap window. 
    % This means only ever computing a vector operation (i.e. diff(spike_times))
    % rather than a matrix one (i.e. spike_times - spike_times').
    diff_order=0;
    while 1==1
        diff_order=diff_order+1;
        fprintf('Now comparing spikes separated by %g other spikes.\n',diff_order-1);
        isis=spike_times(1+diff_order:end) - spike_times(1:end-diff_order);
        simultaneous = isis<n_samples_overlap;
        if any(isis<0)
            error('ISIs less than zero? Something is wrong because spike times should be sorted.');
        end
        if ~any(simultaneous)
            fprintf('No remaining simultaneous spikes.\n');
            break
        end
        nearby = chan_dist(sub2ind(size(chan_dist),spike_primary(1:end-diff_order),spike_primary(1+diff_order:end)))<P.channel_separation_um;
        first_duplicate = find(simultaneous & nearby); % indexes the first (earliest in time) member of the pair
        n_duplicates = length(first_duplicate);
        if ~isempty(first_duplicate)
            fprintf('On iteration %g, %g duplicate spike pairs were identified.\n',diff_order,n_duplicates);
            amps_to_compare=tempAmpsUnscaled(spike_templates([first_duplicate first_duplicate(:)+diff_order]));
            if length(first_duplicate)==1
                amps_to_compare = amps_to_compare(:)'; % special case requiring a dimension change
            end
            first_is_bigger =  diff(amps_to_compare,[],2)<=0;
            remove_idx = [remove_idx ; spike_idx([first_duplicate(~first_is_bigger);(first_duplicate(first_is_bigger)+diff_order)])];
            reference_idx = [reference_idx ; spike_idx([(first_duplicate(~first_is_bigger)+diff_order);first_duplicate(first_is_bigger)])];
        end
    end
    [remove_idx,idx] = unique(remove_idx);
    reference_idx = reference_idx(idx);
    
    
    %%%%%%FSV delete
    NPXSpikes.refss = NPXSpikes.ss(reference_idx);
    NPXSpikes.refSpTem = NPXSpikes.spikeTemplates(reference_idx);
    NPXSpikes.refclu = NPXSpikes.clu(reference_idx);
    
    logical_remove_idx = ismember((1:n_spikes)',remove_idx);
    
    NPXSpikes.removedss = NPXSpikes.ss(logical_remove_idx);
    NPXSpikes.removedSpTem = NPXSpikes.spikeTemplates(logical_remove_idx);
    NPXSpikes.removedclu = NPXSpikes.clu(logical_remove_idx);
    
    %%%%%%%%
    
    
    NPXSpikes.ss = NPXSpikes.ss(~logical_remove_idx);
    NPXSpikes.st = NPXSpikes.st(~logical_remove_idx);
    NPXSpikes.clu = NPXSpikes.clu(~logical_remove_idx);
    NPXSpikes.spikeTemplates = NPXSpikes.spikeTemplates(~logical_remove_idx);
    NPXSpikes.tempScalingAmps = NPXSpikes.tempScalingAmps(~logical_remove_idx);
    %NPXSpikes.SpikeTimes = NPX_GetBeastCompatSpikeTimes(NPXSpikes);
    
%     rez = remove_spikes(rez,logical_remove_idx,'duplicate','reference_time',spike_times(reference_idx),...
%         'reference_cluster',spike_templates(reference_idx));
end