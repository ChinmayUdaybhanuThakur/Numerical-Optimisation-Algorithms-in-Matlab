C=input('Enter objective function: ');
A=input('Enter matrix A: ');
b=input('Enter matrix b: ');

x1=0:0.1:10;
x21=(b(1)-A(1,1)*x1)./A(1,2);
x22=(b(2)-A(2,1)*x1)./A(2,2);
x21=max(0,x21);
x22=max(0,x22);

plot(x1,x21,'r',x1,x22,'b');
xlabel('value of x1');
ylabel('value of x2');
title('x1 vs x2');
legend('x1+2x2=5','x1+x2=4');

grid on;

cx1=find(x1==0);
c1=find(x21==0);
Line1=[x1(:,[c1 cx1]);x21(:,[c1 cx1])]'

c2=find(x22==0);
Line2=[x1(:,[c2 cx1]);x22(:,[c2 cx1])]';

corpt=unique([Line1;Line2],'rows');

HG=[0;0];
for i=1:size(A,1)
    hg1=A(i,:);
    b1=b(i,:);
    for j=i+1:size(A,1)
        hg2=A(j,:);
        b2=b(j,:);
        Aa=[hg1;hg2];
        Bb=[b1;b2];
        Xx=Aa\Bb;
        HG=[HG Xx];
    end
end
pt=HG';

allpt=[pt;corpt];
points=unique(allpt,'rows');

PT=constraint(points);
PT=unique(PT,'rows');

for i=1:size(PT,1)
    Fx(i,:)=sum(PT(i,:).*C);
end

Vert_Fns=[PT Fx];
[fxval,indfx]=max(Fx);
optval=Vert_Fns(indfx,:)
OPTIMAL_BFS=array2table(optval)

disp('Inbuilt function');

lb = [0;0];


[result, optval] = linprog(-C, A, b, [],[] ,lb,[]);

disp(result);
disp(-optval);