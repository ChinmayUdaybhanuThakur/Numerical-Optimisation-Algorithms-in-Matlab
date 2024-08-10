function hh = constraints(X)
x1 = X(:,1);
x2 = X(:,2);
cons1 = x1+2*x2-5;
h1 = find(cons1>0);
X(h1,:) = [];

x1 = X(:,1);
x2 = X(:,2);
cons2 = x1+x2-4;
h2 = find(cons2>0);
X(h2,:)=[];
hh = X;
end