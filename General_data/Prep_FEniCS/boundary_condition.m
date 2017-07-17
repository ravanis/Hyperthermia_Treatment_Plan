function [ h_trans ] = boundary_condition( )
% The constants for Newton's law of cooling for different combination of
% skin water and air

% Source https://books.google.se/books?id=OSzjBwAAQBAJ&pg=PA156&lpg=PA156&...
% dq=heat+transfer+coefficient+skin+water&source=bl&ots=na8atN20Io&sig=cx_...
% 6N80Ds633VvQnWsrqbdJR7zI&hl=en&sa=X&ved=0ahUKEwjdjvjFmN_NAhXuZpoKHUXzAvg...
% Q6AEIRDAJ#v=onepage&q=heat%20transfer%20coefficient%20skin%20water&f=false
% (2016-07-06)
h_trans_skin_water = 800;%2*0.6*0.37/(0.6+0.37);%64; % W/(m^2 * degree C)

% Source http://escholarship.org/uc/item/9hn3s947#page-3 (2016-07-06)
h_trans_skin_air = 70;%2*0.03*0.37/(0.03+0.37);%4.3; % W/(m^2 * degree C)

h_trans_inside_body = h_trans_skin_water *100;

h_trans = [h_trans_inside_body h_trans_skin_air h_trans_skin_water];

end

