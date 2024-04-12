% Function that deletes an excess of particles inside the repository using
% crowding distances
function Archive = CrowdingDistance(Archive)
    N = numel(Archive);
    % Compute the crowding distances
    crowding = zeros(N, 1);
    Cost = reshape([Archive.Cost], [], N)';
    M = size(Cost, 2);
    for m = 1:1:M
        [m_cost, idx] = sort(Cost(:, m), 'ascend');
        m_up     = [m_cost(2:end); m_cost(end-1)];
        m_down   = [-Inf; m_cost(1:end-1)];
        distance = (m_up - m_down) ./ (max(m_cost) - min(m_cost) + eps);
        [~, idx] = sort(idx,'ascend');
        crowding = crowding + distance(idx);
    end
    crowding(isnan(crowding)) = Inf;
    
    for n = 1:N
        Archive(n).CrowdingDistance = crowding(n);
    end
        
end