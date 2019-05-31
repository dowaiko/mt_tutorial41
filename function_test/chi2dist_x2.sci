
clear;

printf('************** Chi-square Distribution Function ****************');
printf('\n');

df = input('Enter a Degree of Freedom : ');
q = input('Enter a Level of Significance : ');


x = cdfchi( "X", df, 1-q, q),
    




printf('x =');
disp(string(x));
printf('\n');
