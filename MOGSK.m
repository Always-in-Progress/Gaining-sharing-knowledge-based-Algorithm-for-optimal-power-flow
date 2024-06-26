%% Optimal Power Flow Utilising MOGSK Based on NSGA-?
clear;
close all;
clc;

tic;

PV = [0,0,0,0,0,0,0.0670217995175985,0.204959666510439,0.441740303387099,0.674386614692288,0.857661076753659,0.975895167221085,0.815624321265675,1,0.908416115105721,0.633496801137035,0.387087186639079,0.317973456486700,0.0825036103903032,0,0,0,0,0]';
PV = PV * 0.2;

drawing_flag = true;

% 粒子群算法(PSO)、樽海鞘群算法(SSA)、灰色狼群算法(GWO)结果的综合比较
N = 13; % 补偿装置总数
nVar = 24*N; %维度（决策变量的个数）
% Active Powers in kWs Generated by Photovoltatic Arrays at Bus 8, 25, 32
% 第1、2、3、4、5、6、7、8、9、10、11、12组补偿位置分别为
% 母线24、25、7、8、30、32、4、14、29、31、2、23
% 第1组的补偿装置容量范围为0 ~ 0.2Mvar
% 第2组的补偿装置容量范围为-0.2 ~ 0.2Mvar
% 第3组的补偿装置容量范围为0 ~ 0.1Mvar
% 第4组的补偿装置容量范围为-0.1 ~ 0.1Mvar
% 第5组的补偿装置容量范围为0 ~ 0.1Mvar
% 第6组的补偿装置容量范围为-0.1 ~ 0.1Mvar
% 第7组的补偿装置容量范围为0 ~ 0.08Mvar
% 第8组的补偿装置容量范围为0 ~ 0.08Mvar
% 第9组的补偿装置容量范围为0 ~ 0.07Mvar
% 第10组的补偿装置容量范围为0 ~ 0.07Mvar
% 第11组的补偿装置容量范围为0 ~ 0.06Mvar
% 第12组的补偿装置容量范围为0 ~ 0.05Mvar

% 下边界
Lb = zeros(24, N);
Lb(:, 2) = -0.2;
Lb(:, [4, 6]) = -0.1;
Lb(:, 13) = 0.8*PV;
% 上边界
Ub = zeros(24, N);
Ub(:, 1:2) = 0.2;
Ub(:, 3:6) = 0.1;
Ub(:, 7:8) = 0.08;
Ub(:, 9:10) = 0.07;
Ub(:, 11) = 0.06;
Ub(:, 12) = 0.05;
Ub(:, 13) = PV;
% 改变维度布局
min_range = reshape(Lb', 1, nVar);
max_range = reshape(Ub', 1, nVar);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Objective Functions
fopt = {'mean(mean(ploss)) * 1000', 'mean(mean(abs(vol_pu - 1))) * 100', ...
    '(1 - mean(P_PV(PV > 0)./PV(PV > 0))) * 100'};
fobj = @fitness;
% Number of Objective Functions
nObj = numel(fopt);

%% MOGSK Parameters
MaxIt = 200;  % Maximum Number of Iterations
nPop = 200;  % Population Size
max_nfes = 10000 * nVar;

G_Max = fix(max_nfes/nPop);
nfes = 0;

KF = 0.5;% Knowledge Factor
KR = 0.9;%Knowledge Ratio
K = 10*ones(nPop, 1);%Knowledge Rate
lu = [min_range; max_range];

%% Initialization
empty_individual.Position = [];
empty_individual.Cost = [];
empty_individual.Rank = [];
empty_individual.DominationSet = [];
empty_individual.DominatedCount = [];
empty_individual.CrowdingDistance = [];

pop = repmat(empty_individual, nPop, 1);
for i = 1:nPop
    for j = 1:nVar
        pop(i, 1).Position(1, j) = unifrnd(min_range(j),max_range(j),1);
    end
    pop(i, 1).Cost = fobj(pop(i).Position, fopt, PV);
end

% Non-Dominated Sorting
[pop, F] = NonDominatedSorting(pop);

% Calculate Crowding Distance
pop = CalcCrowdingDistance(pop, F);

% Sort Population
[pop, F] = SortPopulation(pop);

% Store F1
F1 = pop(F{1});

disp('Staring MOGSK ...');
% Show Iteration Information
disp(['Iteration ' num2str(0) ': Number of F1 Members = ' num2str(numel(F1))]);

popCosts = reshape([pop.Cost], nObj, nPop);
popRanks = [pop.Rank];

% Results
if drawing_flag
    if nObj == 2
        hold off;
        plot(popCosts(1, :), popCosts(2, :), 'k.');
        hold on;
        plot(popCosts(1, popRanks == 1), popCosts(2, popRanks == 1), '*');
        legend('Individuals', 'Non-dominated solutions');
        grid on;
        drawnow;
    elseif nObj == 3
        hold off;
        plot3(popCosts(1, :), popCosts(2, :), popCosts(3, :), 'k.');
        hold on;
        plot3(popCosts(1, popRanks == 1), popCosts(2, popRanks == 1), ...
            popCosts(3, popRanks == 1), '*');
        legend('Individuals', 'Non-dominated solutions');
        grid on;
        drawnow;
    end
end

% Iteration
for iter = 1:MaxIt
    D_Gained_Shared_Junior = ceil((nVar)*(1-iter/G_Max).^K);
    D_Gained_Shared_Senior = nVar-D_Gained_Shared_Junior;
    %     pop = pop; % the old population becomes the current population
    pos = reshape([pop.Position]', nVar, nPop)';

    indBest = 1:nPop;
    [Rg1, Rg2, Rg3] = Gained_Shared_Junior_R1R2R3(indBest);

    [R1, R2, R3] = Gained_Shared_Senior_R1R2R3(indBest);
    R01 = 1:nPop;
    Gained_Shared_Junior=zeros(nPop, nVar);

    ind1 = R01 > Rg3;
    if(sum(ind1) > 0)
        Gained_Shared_Junior(ind1,:)= pos(ind1,:) + KF*ones(sum(ind1), nVar) .* (pos(Rg1(ind1),:) - pos(Rg2(ind1),:)+pos(Rg3(ind1), :)-pos(ind1,:)) ;
    end
    ind1 = ~ind1;
    if(sum(ind1) > 0)
        Gained_Shared_Junior(ind1,:) = pos(ind1,:) + KF*ones(sum(ind1), nVar) .* (pos(Rg1(ind1),:) - pos(Rg2(ind1),:)+pos(ind1,:)-pos(Rg3(ind1), :)) ;
    end
    R0 = 1:nPop;
    Gained_Shared_Senior = zeros(nPop, nVar);
    ind = R0 > R2;
    if(sum(ind) > 0)
        Gained_Shared_Senior(ind,:) = pos(ind,:) + KF*ones(sum(ind), nVar) .* (pos(R1(ind),:) - pos(ind,:) + pos(R2(ind),:) - pos(R3(ind), :)) ;
    end
    ind = ~ind;
    if(sum(ind)>0)
        Gained_Shared_Senior(ind,:) = pos(ind,:) + KF*ones(sum(ind), nVar) .* (pos(R1(ind),:) - pos(R2(ind),:) + pos(ind,:) - pos(R3(ind), :)) ;
    end
    Gained_Shared_Junior = boundConstraint(Gained_Shared_Junior, pos, lu);
    Gained_Shared_Senior = boundConstraint(Gained_Shared_Senior, pos, lu);

    D_Gained_Shared_Junior_mask = rand(nPop, nVar) <= (D_Gained_Shared_Junior(:, ones(1, nVar))./nVar);
    D_Gained_Shared_Senior_mask = ~D_Gained_Shared_Junior_mask;

    D_Gained_Shared_Junior_rand_mask = rand(nPop, nVar) <= KR*ones(nPop, nVar);
    D_Gained_Shared_Junior_mask = and(D_Gained_Shared_Junior_mask, D_Gained_Shared_Junior_rand_mask);

    D_Gained_Shared_Senior_rand_mask = rand(nPop, nVar)<=KR*ones(nPop, nVar);
    D_Gained_Shared_Senior_mask = and(D_Gained_Shared_Senior_mask, D_Gained_Shared_Senior_rand_mask);
    ui = pos;

    ui(D_Gained_Shared_Junior_mask) = Gained_Shared_Junior(D_Gained_Shared_Junior_mask);
    ui(D_Gained_Shared_Senior_mask) = Gained_Shared_Senior(D_Gained_Shared_Senior_mask);

    popnew = repmat(empty_individual, nPop, 1);
    parfor k = 1:nPop
        popnew(k, 1).Position = ui(k, :);
        popnew(k, 1).Cost = fobj(popnew(k, 1).Position, fopt, PV);
    end

    % Merge
    pop = [pop; popnew];

    % Non-Dominated Sorting
    [pop, F] = NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop = CalcCrowdingDistance(pop, F);

    % Sort Population
    pop = SortPopulation(pop);

    % Truncate
    pop = pop(1:nPop);

    % Non-Dominated Sorting
    [pop, F] = NonDominatedSorting(pop);

    % Calculate Crowding Distance
    pop = CalcCrowdingDistance(pop, F);

    % Sort Population
    [pop, F] = SortPopulation(pop);

    % Store F1
    F1 = pop(F{1});

    % Show Iteration Information
    disp(['Iteration ' num2str(iter) ': Number of F1 Members = ' num2str(numel(F1))]);

    popCosts = reshape([pop.Cost], nObj, nPop);
    popRanks = [pop.Rank];

    % Results
    if drawing_flag
        if nObj == 2
            hold off;
            plot(popCosts(1, :), popCosts(2, :), 'k.');
            hold on;
            plot(popCosts(1, popRanks == 1), popCosts(2, popRanks == 1), '*');
            legend('Individuals', 'Non-dominated solutions');
            grid on;
            drawnow;
        elseif nObj == 3
            hold off;
            plot3(popCosts(1, :), popCosts(2, :), popCosts(3, :), 'k.');
            hold on;
            plot3(popCosts(1, popRanks == 1), popCosts(2, popRanks == 1), ...
                popCosts(3, popRanks == 1), '*');
            legend('Individuals', 'Non-dominated solutions');
            grid on;
            drawnow;
        end
    end
end

toc;