clear;
close all;
clc;

M = 3;
nSample = 1e6;

% MOGWO
load('MOGWO_result_of_3objs_under_1_VB_in_10_grids.mat', 'Archive');
Archive_MOGWO = Archive;
cost_MOGWO = reshape([Archive_MOGWO.Cost], M, [])';
% MOEO
load('MOEO_result_of_3objs_under_1_VB_in_10_grids.mat', 'Archive');
Archive_MOEO = Archive;
cost_MOEO = reshape([Archive_MOEO.Cost], M, [])';
% MOGSK
load('MOGSK_result_of_3objs_under_1_VB', 'pop');
Archive_MOGSK = pop;
cost_MOGSK = reshape([Archive_MOGSK.Cost], M, [])';
% MOGWEO
load('MOGWEO_result_of_3objs_under_1_VB_in_10_grids.mat', 'Archive');
Archive_MOGWEO = Archive;
cost_MOGWEO = reshape([Archive_MOGWEO.Cost], M, [])';

max_value = max([max(cost_MOGWO); max(cost_MOEO); ...
    max(cost_MOGSK); max(cost_MOGWEO)], [], 1);
min_value = min([min(cost_MOGWO); min(cost_MOEO); ...
    min(cost_MOGSK); min(cost_MOGWEO)], [], 1);
range = max_value - min_value;

uni_cost_MOGWO = (cost_MOGWO - min_value) ./ range;
uni_cost_MOEO = (cost_MOEO - min_value) ./ range;
uni_cost_MOGSK = (cost_MOGSK - min_value) ./ range;
uni_cost_MOGWEO = (cost_MOGWEO - min_value) ./ range;
ref_point = [1, 1, 1];

HV_MOGWO = approximate_hypervolume_ms(uni_cost_MOGWO', ref_point', nSample);
HV_MOEO = approximate_hypervolume_ms(uni_cost_MOEO', ref_point', nSample);
HV_MOGSK = approximate_hypervolume_ms(uni_cost_MOGSK', ref_point', nSample);
HV_MOGWEO = approximate_hypervolume_ms(uni_cost_MOGWEO', ref_point', nSample);

save('Hypervolume.mat', 'HV_MOGWO', 'HV_MOEO', 'HV_MOGSK', 'HV_MOGWEO');