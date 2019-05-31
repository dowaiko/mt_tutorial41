clear;

printf('************** Chi-square Distribution Function ****************');
printf('\n');

df = input('Enter a Degree of Freedom : ');

for x = 1: 20,

    Total( x, 1)    = cdfchi( "PQ", x, df);
    
    if x==1 then
        Dist( x, 1) =  Total( x, 1);
    else 
        Dist( x, 1) =  Total( x, 1) - Total( x-1, 1); 
    end,   

end


printf('Total =');
disp(string(Total));
printf('\n');
printf('Dist =');
disp(string(Dist));
printf('\n');

clf;    // clear
//scf;    // add


plot2d(Dist);
