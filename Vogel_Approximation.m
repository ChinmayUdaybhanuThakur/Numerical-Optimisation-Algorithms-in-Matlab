clear
clc

%supply = [50 70 30 50];
%demand = [25 35 105 20];
%cost_matrix = [2 4 6 11; 10 8 7 5; 13 3 9 12; 4 6 8 3];

supply = input('Enter the source capacitites in an array: ');
demand = input('Enter the demands in an array: ');
cost_matrix = input('Enter the cost matrix from sources to demand: ');

max_val = 1e3;          %max value of cost in cost matrix (for inf)

num_of_supply = size(supply, 2);
num_of_demand = size(demand, 2);
total_supply = sum(supply);
total_demand = sum(demand);
cost = 0;
basic_cells = 0;

X = zeros(size(cost_matrix));

if total_demand ~= total_supply 
    fprintf("\nUnbalanced transportation problem\n")
else
    fprintf("\nBalanced transportation problem\n")
end

while total_demand > 0
    row_min = [];
    row_min_index = [];

    for i = 1:num_of_supply
        row_min_val = max_val;
        row_sec_min_val = max_val;

        for j = 1:num_of_demand
            if row_min_val > cost_matrix(i, j)
                row_sec_min_val = row_min_val;
                row_min_val = cost_matrix(i, j);
                row_min_index(i) = j;
            elseif row_sec_min_val > cost_matrix(i, j)
                row_sec_min_val = cost_matrix(i, j);
            end
        end

        row_min(i) = row_sec_min_val - row_min_val;
    end

    col_min = [];
    col_min_index = [];

    for j = 1:num_of_demand
        col_min_val = max_val;
        col_sec_min_val = max_val;

        for i = 1:num_of_supply
            if col_min_val > cost_matrix(i, j)
                col_sec_min_val = col_min_val;
                col_min_val = cost_matrix(i, j);
                col_min_index(j) = i;
            elseif col_sec_min_val > cost_matrix(i, j)
                col_sec_min_val = cost_matrix(i, j);
            end
        end

        col_min(j) = col_sec_min_val - col_min_val;
    end

    [col_penalty_val, col_penalty_index] = max(col_min);
    [row_penalty_val, row_penalty_index] = max(row_min);

    if row_penalty_val > col_penalty_val
        i = row_penalty_index;
        j = row_min_index(row_penalty_index);
    else
        i = col_min_index(col_penalty_index);
        j = col_penalty_index;
    end

    if supply(i) > demand(j)
        supply(i) = supply(i) - demand(j);
        X(i, j) = demand(j);
        total_demand = total_demand - demand(j);
        cost = cost + cost_matrix(i, j)*demand(j);
        demand(j) = 0;
        cost_matrix(:, j) = max_val;
    elseif supply(i) < demand(j)
        demand(j) = demand(j) - supply(i);
        X(i, j) = supply(i);
        total_demand = total_demand - supply(i);
        cost = cost + cost_matrix(i, j)*supply(i);
        supply(i) = 0;
        cost_matrix(i, :) = max_val;
    else
        X(i, j) = supply(i);
        total_demand = total_demand - supply(i);
        cost = cost + cost_matrix(i, j)*supply(i);
        supply(i) = 0;
        demand(j) = 0;
        cost_matrix(i, :) = max_val;
        cost_matrix(:, j) = max_val;
    end
    basic_cells = basic_cells + 1;
end

if basic_cells == num_of_demand + num_of_supply - 1
    fprintf("Non-degenarate solutions\n\n")
else
    fprintf("Degenrate solutions\n\n")
end

fprintf("The initial solution using Vogel's Approximation Method is:\n\n")
disp(X)
fprintf("The cost is: %d\n", cost)