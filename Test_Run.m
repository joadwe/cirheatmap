close all
clear

%% Online examples

DataX{1} = rand(100, 10); % Create dataset of 3 groups
DataX{2} = -rand(100, 5);
DataX{3} = rand(100, 7);

x = 1:1:100;
Labels = [];

for i = 1:numel(x)
    Labels{i} = ['Label ', num2str(x(i))]; % Create labels for each column
end

Groups = {'Pre', 'During','After'}; % Create labels for each group

[Fig] = CirHeatmap(DataX', 'GroupLabels', Groups,'OuterLabels', Labels, 'CircType', 'half','InnerSpacerSize',0.5);
