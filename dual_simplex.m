clc
clear all

variables = input("Enter the number of variables: ");
constraints = input("Enter the number of constraints: ");
n_constraints = input('Enter the number of "≤, =, >=" constraints respectively: ');



A = input("Enter A: ");
b = input("Enter b: ");
func_type = input('Enter 0 for maximization and 1 for minimization: ');
Obj = input("Enter the coefficients of the objective function: ");

if (func_type == 1) 
    Obj = -Obj;
end

A = [A, [eye(leq); zeros(geq + eq, leq)], [zeros(leq + eq, geq); -eye(geq)]];
Obj = [Obj, zeros(1, leq + geq)];

[m, n] = size(A);

combinations = nchoosek(1:n, m);
flag = 1;

for i = 1:nchoosek(n, m)
    B = A(:, combinations(i, :));
    if (det(B) ~= 0)
        Y = B\A;
        Cb = Obj(combinations(i, :));
        zjcj = Cb*Y - Obj;
        [minValue, minIndex] = min(zjcj);
        if (minValue >= 0)
            choosen_variables = combinations(i, :);
            simplex_table = [[B\b; Cb*(B\b)], [Y; zjcj]];
            disp(simplex_table);
            flag = -1;
            break;
        end
    end
end

if (flag == 1)
    disp("No initial feasible solution found.");
    return;
end

for i = 1:nchoosek(1:n, m)
    [minValue, minIndex] = min(simplex_table(1:end-1, 1));
    if (minValue >= 0)
        disp("Optimal solution found:");
        disp("Variables:");
        disp(choosen_variables);
        disp("Values:");
        disp(simplex_table(1:end-1, 1));
        return;
    end
    pr = minIndex;
    ent_var = -1;
    value = -inf;
    for j = 2:length(simplex_table(1, 2:end)) + 1
        if (simplex_table(pr, j) < 0)
            if (value < simplex_table(end, j) / simplex_table(pr, j))
                value = simplex_table(end, j) / simplex_table(pr, j);
                ent_var = j;
            end
        end
    end
    if (ent_var == -1) 
        disp("Infeasible solution");
        return;
    end
    pc = j;
    pe = simplex_table(pr, pc);
    new_simplex_table = zeros(m + 1, n + 1);
    new_simplex_table(pr, :) = simplex_table(pr, :) / pe;
    
    for j = 1:m
        if (j ~= pr)
            for k = 1:n
                if (k ~= pc)
                     new_simplex_table(j, k) = simplex_table(j, k) - (simplex_table(pr, k) * simplex_table(j, pc)) / pe;
                end
            end
        end
    end
    simplex_table = new_simplex_table;
    disp(simplex_table);
end