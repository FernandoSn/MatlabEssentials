t=0:0.001:1;
t=t*2*pi;
t1=sin(t*1);
t2=sin(t*5);

n=length(t1)+length(t2);

co = zeros(n,1);
sum=0;

for ii=1:n
    
  for jj=1:ii
      
     if(jj < ii && jj < length(t1)-1)
         
         sum = sum + t1(jj) * t2(ii-jj);
         
     end
     
  end
  
  co(ii) = sum;
  
  sum=0;
      
end
    

cob=conv(sin(t1),sin(t2));