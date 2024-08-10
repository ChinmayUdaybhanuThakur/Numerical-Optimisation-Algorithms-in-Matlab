clc 
clear all
n = 2;
A = [2 5; 6 5];
b = [16; 30];
f = [-1 -1];
ansf = -1 * dfs(n,A,b,f)
function [nval] = dfs(n,A,b,f)
    [X,val,exit_flag] = linprog(f,A,b);
    nval = inf;
    if(exit_flag < 0)
        return
    end
    eps = 1e-6;
    flag = true;
    X = round(X,3);
    for i = 1:n
        dec = X(i,1) - floor(X(i,1));
        if(dec > eps && dec < 1-eps)
            new_cons = zeros(1,n);
            new_cons(1,i) = 1;
            new_A = [A ; new_cons];
            new_b = [b ; floor(X(i,1))];
            new_A = round(new_A,3);
            new_b = round(new_b,3);
            nval = min(nval , dfs(n,new_A,new_b,f));
            new_cons = zeros(1,n);
            new_cons(1,i) = -1;
            new_A = [A ; new_cons];
            new_b = [b ; -1 * ( floor(X(i,1))+1 )];
            new_A = round(new_A,3);
            new_b = round(new_b,3);
            nval = min(nval , dfs(n,new_A,new_b,f));
            flag = false;
        end
    end
    if(flag)
        nval = min(nval,val);
    end
end