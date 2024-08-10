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

if total_supply > total_demand
    cost_matrix = [cost_matrix transpose(zeros(size(supply)))];
    demand = [demand (total_supply - total_demand)];
    total_demand = total_supply;
elseif total_demand > total_supply
    cost_matrix = [cost_matrix; zeros(size(demand))];
    supply = [supply; (total_demand - total_supply)];
end

X = zeros(size(cost_matrix));

i = 1;
j = 1;
while total_demand > 0
    if supply(i) > demand(j)
        supply(i) = supply(i) - demand(j);
        X(i, j) = demand(j);
        total_demand = total_demand - demand(j);
        cost = cost + cost_matrix(i, j)*demand(j);
        j = j + 1;
    elseif supply(i) < demand(j)
        demand(j) = demand(j) - supply(i);
        X(i, j) = supply(i);
        total_demand = total_demand - supply(i);
        cost = cost + cost_matrix(i, j)*supply(i);
        i = i + 1;
    else
        X(i, j) = supply(i);
        total_demand = total_demand - demand(j);
        cost = cost + cost_matrix(i, j)*demand(j);
        i = i + 1;
        j = j + 1;
    end
end

X = X(1:num_of_supply, 1:num_of_demand);

fprintf("The initial solution using North-West Corner Rule is:\n\n")
disp(X)
fprintf("The cost is: %d\n", cost)
