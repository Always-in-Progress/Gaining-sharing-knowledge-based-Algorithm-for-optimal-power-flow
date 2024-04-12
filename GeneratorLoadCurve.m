clear;
close all;
clc;

PV = [0,0,0,0,0,0,0.0670217995175985,0.204959666510439,0.441740303387099,0.674386614692288,0.857661076753659,0.975895167221085,0.815624321265675,1,0.908416115105721,0.633496801137035,0.387087186639079,0.317973456486700,0.0825036103903032,0,0,0,0,0]';
PV = PV*0.2;

T = [2960 2810 2620 2500 2460 2420 2450 2580 2680 2960 3300 3450 3500 3400 3220 3170 3170 3300 3690 3715 3640 3600 3480 3200];
T = T/3715;

figure;
ax = gca;
plot(0:length(PV)-1, PV*1000, 'LineStyle', '-', 'Marker', '*', 'Color', '#77AC30', ...
    'LineWidth', 1.2);
% plot(0:length(PV)-1, PV*1000, 'LineStyle', '-', 'Marker', '*', 'Color', 'k', ...
%     'LineWidth', 1.2);
grid on;
ax.FontName = 'Times New Roman';
ax.FontSize = 11;
ax.XAxis.Color = 'k';
ax.YAxis.Color = 'k';
xlabel('\fontname{宋体}时段\fontname{Times New Roman}(h)', 'FontSize', 11, ...
    'Color', 'k');
ylabel('\fontname{宋体}分布式光伏最大有功出力\fontname{Times New Roman}(kW)', ...
    'FontSize', 11, 'Color', 'k');
title('分布式光伏日有功出力曲线', 'FontName', '宋体', 'FontSize', 12, 'Color', 'k');
axis tight;

figure;
ax = gca;
plot(0:length(T)-1, T, 'LineStyle', '-', 'Marker', '*', 'Color', '#A2142F', ...
    'LineWidth', 1.2);
% plot(0:length(T)-1, T, 'LineStyle', '-', 'Marker', '*', 'Color', 'k', ...
%     'LineWidth', 1.2);
grid on;
ax.FontName = 'Times New Roman';
ax.FontSize = 11;
ax.XAxis.Color = 'k';
ax.YAxis.Color = 'k';
xlabel('\fontname{宋体}时段\fontname{Times New Roman}(h)', 'FontSize', 11, ...
    'Color', 'k');
ylabel('\fontname{宋体}负荷功率波动标幺值\fontname{Times New Roman}(p.u.)', ...
    'FontSize', 11, 'Color', 'k')
title('负荷日波动曲线', 'FontName', '宋体', 'FontSize', 12, 'Color', 'k');
axis tight;