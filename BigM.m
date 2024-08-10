n = input("No of variables: ")
    m = input("No of Constraints: ")
    geq = input("Enter the greater than equal to constraints: ")
    leq = input("Enter the less than equal to constraints: ")
    eq = input("Input the number of equality constraints: ")
    A = input("Enter the coefficients of matrix A: ")
    b = input("Enter the constant matrix: ")
    C = input("Enter the coefficients of the objective function: ")
[r,c]=size(A)
temp=A
id=[];
for i=1:size(A,1)
    if(i<=leq)   
        vec= zeros(r,1);
        vec(i)=1;
        A=[A,vec(:)];
        C=[C,0];
        id=[id,size(A,2)];
    end
    if(i>leq && i<=leq+eq)
        vec= zeros(r,1);
        vec(i)=1;
        A=[A,vec(:)];
        C=[C,-100];
        id=[id,size(A,2)];
    end
    if(i>eq+leq)
        vec= zeros(r,1);
        vec(i)=-1;
        A=[A,vec(:)];
        C=[C,0];
        vec= zeros(r,1);
        vec(i)=1;
        A=[A,vec(:)];
        C=[C,-100];
        id=[id,size(A,2)];
    end
end
A;
id; 
B=A(:,id(:,:));
Cj=C(:,id(:,:));
x=B\b;
cv=Cj*x;
lrow=[cv];
for j =1:size(A,2)
    Zj=Cj*A(:,j);
    lrow=[lrow,Zj-C(1,j)];
end
A=[x,A];
A=[A;lrow];
while(1)
    A
    id
    enter=0;
    min=0;
    for i=2: size(lrow,2)
        if(A(size(A,1),i)<min)
        min=A(size(A,1),i);
        enter=i;
        end
    end
    if(enter==0)
        fprintf("optimal acheived!")
        A
        A(size(A,1),1)
        break
    end
ex=0;
min=1e9;
for i=1:size(A,1)-1
    if(A(i,enter)>0&& A(i,1)>0 )
        if(A(i,1)/A(i,enter)<min)
            min=A(i,1)/A(i,enter);
            ex=i;
        end
    end
    if(A(i,enter)<0&& A(i,1)<0)
        if(A(i,1)/A(i,enter)<min)
            min=A(i,1)/A(i,enter);
            ex=i;
        end
    end
end
if(ex==0)
    fprintf("Unbounded Solution")
    A
    break
end
id(1,ex)=enter-1;
A_=A;
pivot=A(ex,enter)
for(i=1:size(A,1))
    for j=1:size(A,2)
        if(i~=ex&& j~=enter)
            A_(i,j)=A(i,j) - (A(i,enter)*A(ex,j)/pivot);
        end
    end
end
for(i=1:size(A,1))
    if(i~=ex)
    A_(i,enter)=0;
    end
end
for(j=1:size(A,2))
    A_(ex,j)=A(ex,j)/pivot;
end
id;
A_;
A=A_;
end