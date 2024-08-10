clear
clc

cost_matrix = magic(10);

%cost_matrix = input("Enter cost matrix: ");

n = size(cost_matrix, 1);
m = size(cost_matrix, 2);

if n > m
    dummy_cols = zeros([n, n-m]);
    cost_matrix = [cost_matrix dummy_cols];
elseif n < m
    dummy_rows = zeros([m-n, m]);
    cost_matrix = [cost_matrix; dummy_rows];
    n = m;
end

C = cost_matrix;

% Subtract row minima
assign_u = transpose(min(C, [], 2));
for i = 1:n
    for j = 1:n
        C(i, j) = C(i, j) - assign_u(i);
    end
end

% Subtract column minima
assign_v = min(C);
for j = 1:n
    for i = 1:n
        C(i, j) = C(i, j) - assign_v(j);
    end
end

% Subtract matrix minima (if required)
[num_of_lines, line_row, line_col] = min_lines(C, n);
while num_of_lines < n
    C_ = C;
    iter = 0;

    for i = 1:size(line_row, 2)
        C_(line_row(i) - iter, :) = [];
        iter = iter + 1;
    end

    iter = 0;
    for j = 1:size(line_col, 2)
        C_(:, line_col(j) - iter) = [];
        iter = iter + 1;
    end

    min_element = min(C_, [], "all");

    C = C - min_element;
    u_new = zeros([1, n]);
    v_new = zeros([1, n]) + min_element;

    for i = 1:size(line_row, 2)
        C(line_row(i), :) = C(line_row(i), :) + min_element;
        u_new(i) = -min_element;
    end

    for j = 1:size(line_col, 2)
        C(:, line_col(j)) = C(:, line_col(j)) + min_element;
        v_new(j) = 0;
    end
    
    assign_u = [assign_u; u_new];
    assign_v = [assign_v; v_new];

    [num_of_lines, line_row, line_col] = min_lines(C, n);
end

% Printing optimal value and optimal assignment table
[zeros_row, zeros_col] = independent_zeros(C, n);
optimal_value = 0;

assign_table = zeros(n);
for i = 1:n
    assign_table(zeros_row(i), zeros_col(i)) = 1;
    optimal_value = optimal_value + cost_matrix(zeros_row(i), zeros_col(i));
end

fprintf("\n*****************************************************************************************************************\n")
fprintf("The optimal value is: %d\n", optimal_value)
fprintf("The optimal assignment table is: \n");
disp(assign_table)
fprintf("*****************************************************************************************************************\n")

% Printing optimal dual variables using assignment method
assign_u_opt_val = sum(assign_u, 1);
assign_v_opt_val = sum(assign_v, 1);

fprintf("*****************************************************************************************************************\n")
fprintf("Using Hungarian Method\n")
fprintf("The optimal value is: %d\n\n", sum(assign_u_opt_val) + sum(assign_v_opt_val))
fprintf("The optimal dual variable values for row constraints are: ")
disp(assign_u_opt_val)
fprintf("The optimal dual variable values for column constraints are: ")
disp(assign_v_opt_val)
fprintf("*****************************************************************************************************************\n")

% Printing optimal dual variables using transportation method
transport_u = zeros([1, n]);
transport_v = zeros([1, n]) - cost_matrix(1, :);

for i = 1:n
    transport_u(zeros_row(i)) = cost_matrix(zeros_row(i), zeros_col(i)) - transport_v(zeros_col(i));
end

fprintf("*****************************************************************************************************************\n")
fprintf("Using uv method\n")
fprintf("The optimal value is: %d\n\n", sum(transport_u) + sum(transport_v))
fprintf("The optimal dual variables for row constraints are: ")
disp(transport_u)
fprintf("The optimal dual variables for column constraints are: ")
disp(transport_v)

%% Helper Functions

% Minimum lines function
function [num_of_lines, line_row, line_col] = min_lines(C, n)
    rows = zeros([1, n]) + 1;
    cols = zeros([1, n]);
    row_queue = [];

    assign_col = zeros([1, n]);
    [zeros_row, zeros_col, ~] = max_independent_zeros(C, n, 1, assign_col);

    for i = 1:size(zeros_row, 2)
        for j = 1:n
            if C(zeros_row(i), j) == 0 && j ~= zeros_col(i)
                C(zeros_row(i), j) = -1;
            end
            if C(j, zeros_col(i)) == 0 && j ~= zeros_row(i)
                C(j, zeros_col(i)) = -1;
            end
        end
        rows(zeros_row(i)) = 0;
    end

    for i = 1:n
        if rows(i) == 1
            row_queue = [row_queue i];
        end
    end

    while size(row_queue) ~= 0
        curr_row = row_queue(1);

        for j = 1:n
            if C(curr_row, j) == 0 || C(curr_row, j) == -1
                if cols(j) == 0
                    cols(j) = 1;
                    for i = 1:n
                        if C(i, j) == 0 && rows(i) == 0
                            rows(i) = 1;
                            row_queue = [row_queue i];
                        end
                    end
                end
            end
        end

        row_queue = row_queue(2:end);
    end

    line_row = [];
    line_col = [];
    for i = 1:n
        if rows(i) == 0
            line_row = [line_row i];
        end
        if cols(i) == 1
            line_col = [line_col i];
        end
    end

    num_of_lines = size(line_col, 2) + size(line_row, 2);
end

% Maximal Independent Zeros
function [zeros_row, zeros_col, num_of_zeros] = max_independent_zeros(C, n, curr_row, assign_col)
    num_of_zeros = 0;

    if curr_row == n
        for j = 1:n
            if C(curr_row, j) == 0 && assign_col(j) == 0
                zeros_row = curr_row;
                zeros_col = j;
                num_of_zeros = 1;
                break;
            end
        end
    else
        for j = 1:n
            if C(curr_row, j) == 0 && assign_col(j) == 0
                assign_col(j) = 1;
                [temp_zeros_row, temp_zeros_col, temp_num_of_zeros] = max_independent_zeros(C, n, curr_row + 1, assign_col);
                
                if temp_num_of_zeros + 1 > num_of_zeros
                    num_of_zeros = temp_num_of_zeros + 1;
                    zeros_row = [curr_row temp_zeros_row];
                    zeros_col = [j temp_zeros_col];
                end

                assign_col(j) = 0;
            end
        end

        [temp_zeros_row, temp_zeros_col, temp_num_of_zeros] = max_independent_zeros(C, n, curr_row + 1, assign_col);

        if temp_num_of_zeros > num_of_zeros
            num_of_zeros = temp_num_of_zeros;
            zeros_row = temp_zeros_row;
            zeros_col = temp_zeros_col;
        end
    end

    if num_of_zeros == 0
        zeros_row = [];
        zeros_col = [];
    end
end

% N Independent Zeros
function [zeros_row, zeros_col] = independent_zeros(C, n)
    assign_col = zeros([1, n]);

    [zeros_row, zeros_col] = rec(C, n, 1, assign_col);
end

% Recursion
function [zeros_row, zeros_col, is_valid] = rec(C, n, curr_row, assign_col)
    is_valid = 0;
    if curr_row == n
        for j = 1:n
            if C(curr_row, j) == 0 && assign_col(j) == 0
                zeros_row = curr_row;
                zeros_col = j;
                is_valid = 1;
                break;
            end
        end
    else
        for j = 1:n
            if C(curr_row, j) == 0 && assign_col(j) == 0
                assign_col(j) = 1;
                [temp_zeros_row, temp_zeros_col, is_valid] = rec(C, n, curr_row + 1, assign_col);
                
                if is_valid == 0
                    assign_col(j) = 0;
                else
                    zeros_row = [curr_row temp_zeros_row];
                    zeros_col = [j temp_zeros_col];
                    is_valid = 1;
                    break;
                end
            end
        end
    end

    if is_valid == 0
        zeros_row = [];
        zeros_col = [];
    end
end
