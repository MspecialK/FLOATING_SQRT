function [myReq, ret] = invSqrtCode(num)

n = 1;
m = 7;
func = sqrt(num);

myReq = fix(rem(num*pow2(-(n-1):m),2)); 
ret = fix(rem(func*pow2(-(n-1):m),2));

end

% clc
% clear
% for num = 0.5:.125:(2-.125)
% [cod_i cod_o] = invSqrtCode(num);
% input = cod_i(1:4)
% output = cod_o(1:5)
% end