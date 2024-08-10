clc
clear all
A = input(' Coefficients Matrix:\n ');
B = input('Enter the constant matrix: \n');
C = input('Coefficients of Objective Function: \n');
m = size(A,1)
n = size(A,2)
f=@(x) C*x;

set = nchoosek(1:n,m);
fs = [];
ifs = [];

for i =1:size(set,1)
    fprintf("x%d x%d \n",set(i,1),set(i,2));
end

for i = 1:nchoosek(n,m)
    X=zeros(n,1);
    index = set(i,:)

    
    S = [];

    for j =1:m
        S = [S A(:,index(:,j))];
    end

    S
    Y = inv(S)*B
    X(index)=Y

    if X>=0
        fs = [fs X];
    else 
        ifs = [ifs X];
    end
end
s=size(fs);
t=s(2);
for k=1:t
    z(k)=f(fs(:,k));
end
z
[v,r]=max(z);
fs(:,r)
v

