% Name: Shivam Maske
% Entry No.: 2021MCB1245

clear
clc

n = input("Enter the number of variables: ");
m = input("Enter the number of constraints: ");

leq = input("Enter the number of less-than-or-equal-to constraints: ");
for i = 1 : leq
    A(i, :) = input("Enter the less-than-or-equal-to constraint in row matrix form:");
end

geq = input("Enter the number of greater-than-or-equal-to constraints: ");
for i = 1 : geq
    A(leq + i, :) = input("Enter the greater-than-or-equal-to constraint in row matrix form:");
end

eq = input("Enter the number of equality constraints: ");
for i = 1 : eq
    A(leq + geq + i, :) = input("Enter the equality constraint in row matrix form:");
end

problem_type = input("Enter '1' if problem is maximization, else enter '0': ");
C = input("Enter the coefficients of the objective function: ");
if problem_type == 0
    for i = 1 : n
        C(1, i) = -C(1, i);
    end
end

b = A(:,end);
A = A(:,1:end-1);

basic_var = [];

% Add slack, surplus, and artificial variables
for i = 1 : m
    if i <= leq
        % Add slack variables for less-than-or-equal-to constraints
        slack_vector = zeros(m, 1);
        slack_vector(i) = 1;
        A = [A, slack_vector(:)];
        C = [C, 0];
        basic_var = [basic_var, size(A,2)];
    elseif i <= leq + geq
        % Add surplus for greater-than-or-equal-to constraints
        surplus_vector = zeros(m, 1);
        surplus_vector(i) = -1;
        A = [A, surplus_vector(:)];
        C = [C, 0];
    
    end
end

for i = 1 : geq + eq
        %Add artificial variables for greater-than-or-equal-to constraints
        artificial_vector = zeros(m, 1);
        artificial_vector(i + leq) = 1;
        A = [A, artificial_vector(:)];
        basic_var = [basic_var, size(A,2)];
end

if leq > 0
    fprintf("\n%d slack variables used, numbered from %d to %d\n", leq, n + 1, n + leq)
end
if geq > 0
    fprintf("%d surplus variables used, numbered from %d to %d\n", geq, n + leq + 1, n + leq + geq)
end
if geq + eq > 0
    fprintf("%d artificial variables used, numbered from %d to %d\n\n", geq + eq, n + leq + geq + 1, n + leq + geq + geq + eq)
end

%Phase-1 starts here
fprintf("****************************\nPhase-1 starts from here\n****************************\n\n")

B = A(:, basic_var(:,:));           %Basis Matrix
C_z = zeros(1, n + leq + geq);
C_z = [C_z -ones(1, geq + eq)];
fprintf("The objective function for phase - 1 is: ");
disp(C_z);

C_j = C_z(:, basic_var(:, :));

[A, opt_val, opt_sol, basic_var, status] = simplex_method(B, b, C_j, A, C_z, basic_var, 1, n, leq, geq);

fprintf("****************************\nPhase-1 ends here\n****************************\n")

for i = 1 : size(basic_var, 2)
    if basic_var(i) > n + leq + geq && A(i, 1) ~= 0
        status = 0;
        break;
    end
end

if status == 0
    fprintf("****************************\nGiven LPP has no feasible solution.\n****************************\n\n");
else
    fprintf("****************************\nPhase-2 starts here\n****************************\n")

    B = A(:, basic_var(:,:));       %Basis Matrix
    Cj = C(:, basic_var(:,:));      %Objective function values for basic variables
    A = A(:, 1 : end - geq - eq);

    [A, opt_val, opt_sol, basic_var, status] = simplex_method(B, b, Cj, A, C, basic_var, 2);

    if status == 1
        fprintf("****************************\nOptimal value exisits\n****************************\n\n");
        %disp(A);
        if problem_type == 0
            opt_val = -opt_val;
        end
        fprintf("Optimal value is: ")
        disp(opt_val);
        fprintf("The optimal solution is:\n")
        disp(opt_sol);
        fprintf("The corresponding variables are: ")
        disp(basic_var)
    else
        fprintf("****************************\nUnbounded solution exisits\n****************************\n\n");
        disp(A);
    end
end

%Simplex method function
function [A, opt_val, opt_sol, basic_var, status] = simplex_method(B, b, Cj, A, C, basic_var, phase, n, leq, geq)
    if phase == 1
        x = B \ b;
        last_row = Cj * x;
        for j = 1 : size(A, 2)
            Zj = Cj * A(:,j);
            last_row = [last_row, Zj - C(1,j)];
        end
        A = [x, A];
        A = [A; last_row];
    else
        A(end, 1) = Cj * A(1 : end - 1, 1);
        for j = 2 : size(A, 2)
            Zj = Cj *A(1 : end - 1, j);
            A(end, j) = Zj - C(1, j - 1);
        end
    end
    
    % Perform iterations of the simplex method
    while true
        fprintf("Basic variables are: ")
        disp(basic_var)
        fprintf("Simplex table:\n")
        disp(A)
        
        enter_var = 0;              %variable that will enter the simplex table in next iteration, if any
        min = 0;
        for i = 2 : size(A, 2)
            if A(size(A,1), i) < min
                min = A(size(A, 1), i);
                enter_var = i;
            end
        end
        if enter_var == 0
            opt_sol = A(1 : end - 1, 1);
            opt_val = A(size(A, 1), 1);
            status = 1;
            break
        end
        exit_var = 0;
        min = 1e9;
        for i = 1 : size(A, 1) - 1
            if A(i, enter_var) > 0
                if A(i, 1) / A(i, enter_var) < min
                    min = A(i, 1) / A(i, enter_var);
                    exit_var = i;
                elseif phase == 1 && A(i, 1) / A(i, enter_var) == min && basic_var(i) > n + leq + geq
                    min = A(i, 1) / A(i, enter_var);
                    exit_var = i;
                end
            end
        end
        if exit_var == 0
            fprintf("\nUnbounded solution exists\n")
            %disp(A)
            %disp(A(size(A, 1), 1))
            opt_sol = [];
            opt_val = inf;
            status = 2;
            break
        end
        basic_var(1, exit_var) = enter_var - 1;
        A_ = A;
        pivot = A(exit_var, enter_var);
        for i = 1 : size(A, 1)
            for j = 1 : size(A, 2)
                if i ~= exit_var && j ~= enter_var
                    A_(i, j) = A(i, j) - (A(i, enter_var) * A(exit_var, j) / pivot);
                end
            end
        end
        for i = 1 : size(A, 1)
            if i ~= exit_var
                A_(i, enter_var) = 0;
            end
        end
        for j = 1 : size(A, 2)
            A_(exit_var, j) = A(exit_var, j) / pivot;
        end
        A = A_;
    end
end


