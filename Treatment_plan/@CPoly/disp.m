function disp(a)
%DISP(a)
%   Displays the polynomial
output = '';

a = reduce(a);

for i = 1:length(a.coefficients)
   if imag(a.coefficients(i)) == 0
        output = [output, sprintf('%f', real(a.coefficients(i)))];
   elseif imag(a.coefficients(i))<0
          output = [output, sprintf('(%.1f%.1fi)', real(a.coefficients(i)), ...
                                              imag(a.coefficients(i))    )];
   else
        output = [output, sprintf('(%.1f+%.1fi)', real(a.coefficients(i)), ...
                                                  imag(a.coefficients(i)) )];
   end
   if ~isempty(a.monom{i}) %Isn't a constant
       for j = 1:length(a.monom{i})
           output = [output ' Z'];
           output = [output sprintf('%s',subsub(abs(a.monom{i}(j))))];
           if a.monom{i}(j) < 0
               output = [output '*'];
           end
       end
   end
   if i ~= length(a.coefficients);
      output = [output ' + '];
   end
end

disp(output);

end

function s = subsub(x)
    sub = char(8320:8329);
    nosub = '0123456789';
    
    s = num2str(x);
    for i = 1:10
        s = strrep(s, nosub(i), sub(i));
    end
end
