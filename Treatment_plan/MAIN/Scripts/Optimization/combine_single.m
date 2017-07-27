function [HTQval,x] = combine_single(freq, modelType)
% Combines efields optimized with EF_optimization_single using particleSwarm.
% ----INPUTS---------------------------------------------
% freq:      vector of frequencies to be combined
% modelType: string with modelType. duke or child models accepted
% -------------------------------------------------------

% Get root path
filename = which('combine_single');
[rootpath,~,~] = fileparts(filename);
resultpath = [rootpath filesep '..' filesep '..' filesep 'Results' filesep 'P_and_unscaled_settings'];
datapath = [rootpath filesep '..' filesep '..' filesep 'Data'];

% Load information of where tumor is, and healthy tissue
tissue_mat = Yggdrasil.Utils.load([datapath filesep 'tissue_mat_' modelType '.mat']);
if startsWith(modelType, 'duke') == 1
    water_ind = 81;
    ext_air_ind = 1;
    int_air_ind = 2;
    tumor_ind = 80;
    salt_ind = 82;
elseif startsWith(modelType,'child') == 1
    water_ind = 30;
    ext_air_ind = 1;
    int_air_ind = 5;
    tumor_ind = 9;
end

healthy_tissue_mat = tissue_mat~=water_ind & ...
    tissue_mat~=ext_air_ind & ...
    tissue_mat~=tumor_ind & ...
    tissue_mat~=int_air_ind & tissue_mat~=salt_ind;
tumor_mat = tissue_mat==tumor_ind;
healthy_tissue_oct = Yggdrasil.Octree(single(healthy_tissue_mat));
tumor_oct = Yggdrasil.Octree(single(tumor_mat));

% Initialize and load optimized Efields
n=length(freq);
e_vec=cell(1,n);

for i=1:n
    f=freq(i);
    eFieldName=['E_' modelType '_' num2str(freq) 'MHz.oct'];
    e_vec{i}=Yggdrasil.Utils.load([resultpath filesep eFieldName]);
end

% Compute function for particleswarm: HTQ for total Efield, each frequency
% contribution weighted with x(f) (x a number between 0 and 1)
f = @(x)(HTQ(abs_sq(add_eField(x,e_vec,n)),tumor_oct,healthy_tissue_oct));

% Optimize x
maxIt=n*3;
lb = zeros(n,1);
ub = ones(n,1);
options = optimoptions('particleswarm','SwarmSize',5,'PlotFcn',...
    @pswplotbestf,'MaxIterations', maxIt, 'MaxStallIterations', maxIt);
x = particleswarm(f,n,lb,ub,options);
x=x/sum(x);

e_tot = add_eField(x,e_vec,n);
p_tot = abs_sq(e_tot);
HTQval = HTQ(p_tot,tumor_mat,healthy_tissue_mat);

disp(['Frequencies combined:  ' num2str(freq)])
disp(['Time shares:           ' num2str(x)])
disp(['HTQ of combined field: ' num2str(HTQval)])

%find settings to each field that has time share>0
settingIndex=find(x~=0);
nbrAntennas = length(e_vec{1}.C.keys);
Amp=zeros(nbrAntennas,1);
Pha=zeros(nbrAntennas,1);
settingMat=zeros(nbrAntennas, length(settingIndex)*2);

for i=settingIndex
    wave_opt = e_vec{i}.C.values; %Complex amplitudes
    ant_opt = e_vec{i}.C.keys; %Corresponding antennas
    for j=1:length(wave_opt)
        Amp(j) = abs(wave_opt(j));
        Pha(j) = rad2deg(phase(wave_opt(j)));
    end
    settings = [Amp Pha ant_opt']; 
    settings = sortrows(settings,3);
    settingMat(:,2*i-1)=settings(:,1);
    settingMat(:,2*i)=settings(:,2);
end

% save results
writeSettings(resultpath, settingMat, modelType, freq(settingIndex), x(settingIndex))
mat_1=p_tot.to_mat;
freqvec = regexprep(num2str(freq),'[^\w'']','');
save([resultpath filesep 'P_combineSingle_' modelType '_' freqvec 'MHz.mat'], 'mat_1', '-v7.3');
    
end

    function [e_tot] = add_eField(x,eFields,n)
        % weight eFields with x and add all n fields.
        e_tot = Yggdrasil.Math.weight(eFields{1},x(1));
        for i=2:n
            e_tot = e_tot + Yggdrasil.Math.weight(eFields{i},x(i));
        end
    end