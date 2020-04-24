close all
clear all

Spain={'Andalucia','Aragon','Asturias','Baleares','Canarias','Cantabria',...
    'Castilla-La Mancha','Castilla y Leon','Catalunya','Ceuta','Comunitat Valenciana',...
    'Extremadura','Galicia','Madrid','Melilla','Murcia','Navarra','Euskadi',...
    'La Rioja','Total'};

population = [8414240 1319291 1022800 1149460 2153389 581078 2032863 2399548 7675217 84777 5003769 1067710 2699499 6663394 86487 1493898 654214 2207776 316798 47026208];

guardar = true;
txt = true;

filename = 'Data_Spain_v2.xlsx';
[~,~,DATA] = xlsread(filename,'Cases');
[~,~,DEATHS] = xlsread(filename,'Deaths');
names = DATA(1,:);
Avec = DATA(2:end,1);
A = zeros(length(Avec),1);
for i = 1:length(Avec)
    if ~isnumeric(Avec{i})
        A(i) = datenum(Avec{i},'dd/mm/yyyy');
    else
        A(i) = Avec{i};
    end
end

yF = ['./Reports Spain/' datestr(A(end),'dd_mm_yyyy') '_GitHub'];
if ~exist(yF, 'dir')
    mkdir(yF)
end
    
id = cell(length(Spain),4);

for i = 1:length(Spain)
    
    ID = find(strcmp(names,Spain{i}));
    data = cell2mat(DATA(2:end,ID));
    deaths = cell2mat(DEATHS(2:end,ID));
    [xp,yp,ep] = informe(A,data,deaths,Spain{i},population(i),guardar,yF);
    %% continue here
    break

    id{i,1} = Spain{i};
    id{i,2} = xp;
    id{i,3} = yp;
    id{i,4} = ep;
    
end

if txt

    DIA = datestr(A(end),'dd_mm_yyyy');
    fileID = fopen(['./Reports Spain/' DIA '_GitHub/prediccions.txt'],'w');
    for i = 1:size(id,1)
        if ~isempty(id{i,2})
            fprintf(fileID,'%s\n',id{i,1});
            for k = 1:length(id{i,2})
                fprintf(fileID,'%s %u [ %u - %u ]\n',datestr(id{i,2}(k),'dd-mm-yyyy'),round(id{i,3}(k)),round(id{i,3}(k)-id{i,4}(k,1)),round(id{i,3}(k)+id{i,4}(k,2)));
             end
        end
    end
    fclose(fileID);

end