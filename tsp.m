clc 
clear all
n = 4;
A = [0 10 15 20; 10 0 35 25; 15 35 0 30; 20 25 30 0];
path = [1];
vis_row = zeros(1,n);
vis_col = zeros(1,n);
vis_col(1) = 1;
ansf = TSP(n,A,path,0,vis_row,vis_col)
function [val] = row_mins(n,A,vis_row,vis_col)
    val = 0;
    for i = 1:n
        if(vis_row(i)==0)
            cur_val = inf;
            for j = 1:n
                if(vis_col(j)==0)
                    cur_val = min(cur_val,A(i,j));
                end
            end
            val = val + cur_val;
        end
    end
end
function [val] = TSP(n,A,path,cost,vis_row,vis_col)
    val = cost;
    sz = size(path,2);
    if(sz == n)
        val = val + A(path(1,1),path(1,n));
        return
    end
    min_cost = inf;
    nod = path(1,sz);
    for i = 1:n
        if(vis_col(i) == 0)
            
            temp = val + A(nod,i);
            vis_row(nod) = 1;
            vis_col(i) = 1;
            path_new = [path i];
            if(temp + row_mins(n,A,vis_row,vis_col) <= min_cost)
                min_cost = min(min_cost,TSP(n,A,path_new,temp,vis_row,vis_col));
            end
            vis_row(nod) = 0;
            vis_col(i) = 0;
        end
    end
    val = min_cost;
end