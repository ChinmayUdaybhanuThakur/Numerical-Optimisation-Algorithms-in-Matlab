%Gomory Cutt me method
clc
clear all

n = input('Enter the number of variables: ');
m = input('Enter the number of constraints: ');
lt = input('Enter the number of less than or equal to constraints: ');
eq = input('Enter the number of equality constraints: ');
gt = input('Enter the number of greater than or equal to constraints: ');

A = input('Enter the constraint matrix A as per chronological order: ');
b = input('Enter the column matrix b: ');
c = input('Enter the maximizer matrix: ');

%adding slack variables to matrix A
for i = 1: lt
    adder = [];
    for j = 1: m
        if (i == j)
            adder = [adder; 1];
        else 
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0]; %corresponding to slack variables
end

%adding surplus variables to A
for i = lt+eq+1 : lt+eq+gt
    adder = [];
    for j = 1: m
        if (i == j)
            adder = [adder; -1];
        else 
            adder = [adder; 0];
        end
    end
    A = [A adder];
    c = [c 0]; %corresponding to slack variables
end

B_columns = [lt+gt+n+eq-m+1 : lt+gt+n+eq]; %columns of basic matrix
B = [A(1:m, lt+gt+n+eq-m+1: lt+gt+n+eq)]; %basic matrix

fprintf('\nThe basic matrix is:');
B

Simplex = [];
C_b = [c(B_columns)];

X = [inv(B)*b]; % equivalent to inv(B)*C_b
Simplex = [Simplex X];
for i = 1: n+lt+gt+eq
    Simplex = [Simplex inv(B)*A(1:m, i)];
end

adder = [C_b*X];
for i = 1: n+lt+gt+eq
    adder = [adder C_b*Simplex(1:m, i+1) - c(i)];%since first column is of X
end
Simplex = [Simplex; adder];

fprintf('The Simplex matrix is:');
Simplex % a matrix of size (m+1)*(n+lt+gt+eq+1);

min_bottom_index = 2;
for i = 3: n+lt+eq+gt+1
    if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
        min_bottom_index = i;
    end
end

%finding the min_bottom index, and checking if to go to next iteration
iteration = 1;
if(Simplex(m+1, min_bottom_index) >= 0)
    fprintf('The optimal solution is corresponding to:');
    X
    fprintf('The solution is:');
    Simplex(m+1, 1);
    iteration = 0;
else
    for i = 2: n+lt+gt+eq+1
        if (Simplex(m+1, i) < 0)
            positive_found = 0;
            for j = 1: m
                if (Simplex(j, i) > 0)
                    positive_found = 1;
                end
            end
            if (positive_found == 0)
                fprintf('The solution to this problem is unbounded\n');
                iteration = 0;
            end
        end
    end
end

while iteration
    min_divider_index = 1;
    min_val = 100000;
    for i = 1:m
        if (Simplex(i, min_bottom_index) > 0)
            if (Simplex(i, 1)/Simplex(i, min_bottom_index) < min_val)
                min_divider_index = i;
                min_val = Simplex(i, 1)/Simplex(i, min_bottom_index);
            end
        end
    end

    B_columns(min_divider_index) = min_bottom_index -1;
    % the new basic matrix will have the min_bottom_index^th column of A

    B = A(1:m, B_columns);% new basic matrix
    C_b(min_divider_index) = c(min_bottom_index - 1); %new C_b
    X = inv(B)*b; %new X vector

    Simplex = [X];
    for i = 1:lt+gt+eq+n
        Simplex = [Simplex inv(B)*A(1:m, i)];
    end

    adder = [C_b*X];
    for i = 1: lt+gt+eq+n
        adder = [adder C_b*Simplex(1:m, i+1) - c(i)];
    end
    Simplex = [Simplex; adder];

    fprintf('The new basic matrix is:');
    B
    fprintf('The new Simplex matrix is: ');
    Simplex

    min_bottom_index = 2;
    for i = 3: n+lt+eq+gt+1
        if Simplex(m+1, min_bottom_index) > Simplex(m+1, i)
            min_bottom_index = i;
        end
    end
    
    %finding the min_bottom index, and checking if to go to next iteration
    if(Simplex(m+1, min_bottom_index) >= -0.001)
        fprintf('The optimal solution of Simplex method is corresponding to:');
        X
        fprintf('The Simplex solution value is:');
        Simplex(m+1, 1)
        break;
    else
        for i = 2: n+lt+gt+eq+1
            if (Simplex(m+1, i) < 0)
                positive_found = 0;
                for j = 1: m
                    if (Simplex(j, i) > 0)
                        positive_found = 1;
                    end
                end
                if (positive_found == 0)
                    fprintf('The solution to this problem is unbounded\n');
                    iteration = 0;
                end
            end
        end
    end

end %end of while loop

if iteration %means to move forward
    while true
        Simplex = get_added_simplex(Simplex, X);
        Simplex = dual_simples_matrix(Simplex);
        X = Simplex((1:size(X, 1)), 1);
        frac = X-floor(X);
        for i = 1: length(frac)
            if(frac(i)-floor(frac(i)) >= 0.99)
                frac(i) = 0;
            end
        end
        if(frac < 1e-5)
            break;
        end
    end
    fprintf("Final Simplex table for integral solution is: \n");
    disp(Simplex);
    fprintf("The vector X obtained is :\n");
    disp(X);
end

function Simplex = get_added_simplex(Simplex, X)
    [rows_now, cols_now] = size(Simplex);
    [maxx, max_fractional_index] = max(X - floor(X));
    new_row = Simplex(max_fractional_index, :);
    new_row = new_row - floor(new_row);
    for i = 1: length(new_row)
        if(new_row(i)-floor(new_row(i)) >= 0.99)
            new_row(i) = 0;
        end
    end
    new_row = -1*new_row;
    Simplex_last_row = Simplex(rows_now, :);
    Simplex(rows_now, :) = new_row;
    Simplex = [Simplex; Simplex_last_row];
    rows_now = rows_now+1;
    cols_now = cols_now+1;
    Simplex = [Simplex zeros(rows_now, 1)];
    Simplex(rows_now-1, cols_now) = 1;
end

function Simplex = dual_simples_matrix(Simplex)
    [min_x_value, min_row_index] = min(Simplex(:, 1));
    max_col_index = 2;
    max_ratio_val = -10000;
    [n, m] = size(Simplex);
    for j = 3: m
        if(Simplex(min_row_index, j) <= -0.001)
            if(Simplex(n, j)/Simplex(min_row_index, j) > max_ratio_val)
                max_ratio_val = Simplex(n, j);
                max_col_index = j;
            end
        end
    end

    new_matrix = zeros(n, m);
    for i = 1:n
        for j = 1:m
            new_matrix(i, j) = Simplex(i,j) - (Simplex(i, max_col_index) * Simplex(min_row_index, j))/Simplex(min_row_index, max_col_index);
        end
        new_matrix(min_row_index, :) = Simplex(min_row_index, :)/Simplex(min_row_index, max_col_index);
    end
    Simplex = new_matrix;
end