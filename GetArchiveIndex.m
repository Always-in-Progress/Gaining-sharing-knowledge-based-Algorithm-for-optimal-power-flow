function POP = GetArchiveIndex(POP, REP, idx_max, draw_flag)

    if ~exist('idx_max', 'var')
        idx_max = 1;
    end
    
    if ~exist('draw_flag', 'var')
        draw_flag = false;
    end

    REP_size = numel(REP);
    POP_size = numel(POP);

    REP_cost = (reshape([REP.Cost], [], REP_size))';
    POP_cost = (reshape([POP.Cost], [], POP_size))';

    % Normalization
    norm_REP_cost = (REP_cost - min(REP_cost)) ./ ...
        (max(POP_cost) - min(POP_cost));
    norm_POP_cost = (POP_cost - min(POP_cost)) ./ ...
        (max(POP_cost) - min(POP_cost));

    distance = zeros(POP_size, REP_size);
    for n = 1:POP_size
        for count_arch = 1:REP_size
            % Normalized Euclidian distance
            distance(n, count_arch) = norm(norm_POP_cost(n, :) ...
                - norm_REP_cost(count_arch, :), 2);
        end
        [~, idx] = sort(distance(n, :), 2, 'ascend');
        POP(n).ArchiveIndex = idx(1:idx_max);
    end
    
    if draw_flag
        [~, idx] = min(distance, [], 2);
        for arch = 1:REP_size
            figure(arch);
            plot(norm_REP_cost(arch, 1), norm_REP_cost(arch, 2), '*'); hold on;
            plot(norm_POP_cost(idx == arch, 1), norm_POP_cost(idx == arch, 2), '.'); grid on;
            title(['Type', num2str(arch)]);
        end
    end
end