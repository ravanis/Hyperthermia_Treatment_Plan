% This function finds hotspots within a SAR matrix by using settings
% applied by the user. Starting from the highest SAR value the function
% searches the neighboring elements in a 30x30x30 box surrounding the
% hotspot element. If enough elements are higher than the hotspot value, 
% the hotspot is stored. Otherwise, the function finds
% the next highest SAR and evaluates its' neighbors etc until the correct
% number of hotspots are found.
%
%
%  -------------- INPUT ---------------
% SARmatrix - 3D matrix containing SAR (or PLD) from model
%
% nbrOfHotspots - number of hotspots to be found
%
% limit - set a limit for what is considered a hotspot. If the program
%         doesn't find a value over this, the function will stop looking (default = 30).
%
% 
% nbrOfHSneighbors - number of neighboring elements above limit required for the
%                    area to be considered a hotspot
%
%
% 
% -------------- OUTPUT --------------- 
% 
% output - (nbrOfHotspots +2) x 1 cell 
%
%           {1:nbrOfHotspots} - contains the hotspot SAR matrix (all other elements = 0)
%                               for the respective hotspot. 
%                               Size for each matrix: as input SAR matrix.
%                               
%
%           {nbrOfHotspots+1} - center points coordinates for the hotspots.
%                               Size: nbrOfHotspots x 3
%
%           {nbrOfHotspots+2} - maximum SAR value and mean value in each of the hotspots.
%                               Size: nbrOfHotspots x 2
% 
%           {nbrOfHotspots+3} - number of hotspots found
% 



function [output]=findHotspot(SARmatrix, nbrOfHotspots, limit, nbrOfHSneighbors)


% --- Initialize variables ---
output=cell(nbrOfHotspots+2,1);
centerPoints=zeros(nbrOfHotspots,3);
values=zeros(nbrOfHotspots,2);
i=1;
ii=0;
box_width=15; % Size of the surrounding box where elements are evaluated
tempSARmatrix=SARmatrix;

% --- Sort SAR matrix into a vector ---
SARvector=reshape(SARmatrix,size(SARmatrix,1).*size(SARmatrix,2).*size(SARmatrix,3),1);
sortSARvector=sort(SARvector,'descend');
hotspots_found=nbrOfHotspots;


while ii<nbrOfHotspots % Repeat until correct nbr of hotspots found

    if sortSARvector(i)>limit % Make sure that one can find hotspots over the limit value

        [row, col]=find(tempSARmatrix==sortSARvector(i)); % Extract hotspot centerpoint

        if ~isempty(row)
            centerPoint=[row, mod(col,size(tempSARmatrix,2)), ceil(col/size(tempSARmatrix,2))]; % change row/col into x/y/z coords

            % Check surroundings to see if the point is a hotspot
            box_surr=centerPoint+box_width;
            box_surr=size(SARmatrix)-box_surr;

            if sum(centerPoint>box_width)==3 && sum(box_surr>0)==3   % make sure that the centerPoint lies at least a box_width from the model edge
                surround_mask=zeros(size(SARmatrix));
                surround_mask(centerPoint(1)-box_width:centerPoint(1)+box_width,...
                              centerPoint(2)-box_width:centerPoint(2)+box_width,...
                              centerPoint(3)-box_width:centerPoint(3)+box_width)=1; % Create surrounding mask

                surrounding=tempSARmatrix.*surround_mask;
                surr_over_limit=surrounding>limit; % Find surrounding points that are hotspot elements

                nbrOfElements=sum(surr_over_limit(:));
                if nbrOfElements>nbrOfHSneighbors % If the surrounding contains enough hotspot elements


                    tempSARmatrix=(surr_over_limit==0).*tempSARmatrix;
                    ii=ii+1;


                    output{ii}=surr_over_limit.*SARmatrix;
                    centerPoints(ii,:)=centerPoint;
                    values(ii,:)=[max(max(max(surr_over_limit.*SARmatrix))), sum(sum(sum(surr_over_limit.*SARmatrix)))/nbrOfElements];

                end

            end
        end
        i=i+1;

      else
         disp('No more hotspots found above given limit')
         hotspots_found=ii;
         break
    end

end


output{nbrOfHotspots+1}=centerPoints;
output{nbrOfHotspots+2}=values;
output{nbrOfHotspots+3}=hotspots_found;

end


