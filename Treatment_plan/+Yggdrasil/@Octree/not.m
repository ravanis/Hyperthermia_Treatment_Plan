function oct = not(oct)
%oct = NOT(oct)
%  Swtiches non-zero values to zeroes and zeroes to ones
    oct.data = oct.data==0;
end
