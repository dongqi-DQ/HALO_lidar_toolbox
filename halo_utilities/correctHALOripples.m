function [snr1,step_locations] = correctHALOripples(site,DATE,...
    snr0,t_snr)
%correctHALOripples corrects the ripples in the HALO bakcground, see
%Vakkari et al. (2019)

C = getconfig(site,DATE);
daten = datenum(num2str(DATE),'yyyymmdd');

if isfield(C,'background_file_type')
    bkg_file_type = C.background_file_type;
else
    bkg_file_type = 'txt';
end

C.background_file_type
bkg_file_type

[bkg_path, files_bkg] = getHALOfileList(site,DATE,'background',bkg_file_type);
% [P_amp_path, files_P_amp] = getHALOfileList(site,DATE,'P_amp','txt');

thedate = num2str(DATE);

if isfield(C,'dir_housekeeping')
    path_to_P_amp = [C.dir_housekeeping thedate(1:4) '_amp_ave_resp.mat'];
    P_amp = load(path_to_P_amp);
    P_amp = P_amp.P_amp;
    P_amp_exists = true;
else
    P_amp_exists = false;
end


if ~isempty(files_bkg)
% if exist(path_bkg,'dir') == 7 % if bkg files exist
    [P_bkg, P_fit, bkg_times] = calculateBKGtxt(bkg_path,files_bkg,C.background_file_type,daten,C.num_range_gates);
%     b_file(:,1:3) = nan; b_fit(:,1:3) = nan;
    P_bkg(all(isnan(P_bkg),2),:) = []; 
    P_fit(all(isnan(P_fit),2),:) = [];
    
    % Find steps
    [time_snr_dnum] = decimal2daten(t_snr,daten);
    step_locations = nan(1,length(bkg_times)-1);
    for i = 2:length(bkg_times)
        if ~isempty(find(time_snr_dnum>bkg_times(i),1,'first'))
            step_locations(i-1) = find(time_snr_dnum>bkg_times(i),1,...
                'first');
        end
    end
    
    % Correct ripples
    istep = 1;
    snr1 = nan(size(snr0));
    for i = 1:size(snr0,1)
        if istep < size(P_bkg,1)
            if i >= step_locations(istep)
                istep = istep + 1;
            end
        end
        %         P_snr = P_bkg(istep,:) - P_fit(istep,:);
        if P_amp_exists
            P_noise = P_fit + repmat(transpose(P_amp),size(P_fit,1),1);
        else
            P_noise = P_fit;
        end
        
        %         b_snr = b_file(istep,:) ./ b_fit(istep,:);
        %         snr1(i,:) = snr0(i,:) + P_snr - 1;
        snr1(i,:) = snr0(i,:) .* (P_bkg(istep,:) ./ P_noise(istep,:));
    end
else
    snr1 = snr0;
    step_locations = [];
end
end

