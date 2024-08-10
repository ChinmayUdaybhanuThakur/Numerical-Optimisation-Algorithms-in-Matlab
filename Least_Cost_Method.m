clear
clc

%supply = [50 70 30 50];
%demand = [25 35 105 20];
%cost_matrix = [2 4 6 11; 10 8 7 5; 13 3 9 12; 4 6 8 3];

supply = input('Enter the source capacitites in an array: ');
demand = input('Enter the demands in an array: ');
cost_matrix = input('Enter the cost matrix from sources to demand: ');

num_of_supply = size(supply, 2);
num_of_demand = size(demand, 2);
total_supply = sum(supply);
total_demand = sum(demand);
cost = 0;

X = zeros(size(cost_matrix));

sorted_cost = [];
sorted_i = [];
sorted_j = [];
for i = 1:num_of_supply
    for j = 1:num_of_demand
        sorted_cost = [sorted_cost cost_matrix(i, j)];
        sorted_i = [sorted_i i];
        sorted_j = [sorted_j j];
    end
end

[sorted_cost, I] = sort(sorted_cost);
sorted_i = sorted_i(I);
sorted_j = sorted_j(I);

for index = 1:size(sorted_cost, 2)
    if total_demand <= 0
        break
    end

    i = sorted_i(index);
    j = sorted_j(index);

    if supply(i) > demand(j)
        supply(i) = supply(i) - demand(j);
        X(i, j) = demand(j);
        total_demand = total_demand - demand(j);
        cost = cost + cost_matrix(i, j)*demand(j);
        demand(j) = 0;
    elseif supply(i) < demand(j)
        demand(j) = demand(j) - supply(i);
        X(i, j) = supply(i);
        total_demand = total_demand - supply(i);
        cost = cost + cost_matrix(i, j)*supply(i);
        supply(i) = 0;
    else
        X(i, j) = supply(i);
        total_demand = total_demand - demand(j);
        cost = cost + cost_matrix(i, j)*demand(j);
        demand(j) = 0;
        supply(i) = 0;
    end
end

fprintf("The initial solution using Least Cost Method is:\n\n")
disp(X)
fprintf("The cost is: %d\n", cost)
