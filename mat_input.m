%replace with code to refine beam data
data = readmatrix('0.trips-iter-50-1sec.csv');
num_pts = size(data);
num_pts = num_pts(1);

id = data(:,1);
time = data(:,2);
x_pos = data(:,3);
y_pos = data(:,4);

cars = max(id) - min(id) + 1;


num_pts = size(data);
num_pts = num_pts(1);

id = data(:,1);
time = data(:,2);
x_pos = data(:,3);
y_pos = data(:,4);

elapsed = max(time) - min(time);
offset_x = -x_pos(1);
offset_y = -y_pos(1);

mag = zeros(num_pts,1);
    x = x_pos + offset_x;
    y = y_pos + offset_y;
    mag = (x.^2 + y.^2).^(0.5);


%
%filtering magnitude graph
dist = max(mag);
c = 0;
d = 0;
col = 0;

car_data = zeros(4,cars);
%4 cols: start time, end time, trip time, car id
for (n = 1:cars)
    car_data(4,n) = n;
end

for b = 1:num_pts
    if (time(b) == min(time))
       col = col + 1; 
    end
    if ((mag(b) > 0) && (mag(b) < dist))
        if (mag(b-1) == min(mag))
            car_data(1,col) = time(b);
        end
        if (mag(b+1) == max(mag))
            car_data(2,col) = time(b);
            car_data(3,col) = car_data(2,col) - car_data(1,col);
        end
        c = c + 1;
    end
end


time_18 = (elapsed+1) * 18;
data_18 = zeros(elapsed+1,2);
for (n = 1:1:elapsed+1)
    data_18(n,1) = time(time_18 + n,1);
    data_18(n,2) = mag(time_18 + n,1);
end


car_id = 0;
trip_time = max(car_data(3,:));
f_data = zeros(c, 3);
for b = 1:num_pts
    if (time(b) == min(time))
       car_id = car_id + 1; 
    end
    if ((mag(b) > 0) && (mag(b) < dist))
        d = d + 1;
        f_data(d,1) = time(b);
        f_data(d,2) = car_id;
        f_data(d,3) = mag(b);
    end
end
f_data_t = sortrows(f_data);

num_pts_f = size(f_data);
num_pts_f = num_pts_f(1);

time_f = f_data(:,1);
id_f = f_data(:,2);
mag_f = f_data(:,3);


elapsed_f = max(time_f) - min(time_f);
%%
%

%replace with code to find car position: output is in cars at node
%We will need an output for each of the 60 nodes
spacing = 109.728;
dead_area = 4.572 / 2.0;
num_nodes = ceil(dist/spacing);

node = zeros(num_nodes, elapsed_f + 1);
node_tot = zeros(num_nodes, elapsed_f + 1);
for i=1:num_nodes
    for z=1:(num_pts_f)
        if (mag_f(z) > 0 && mag_f(z) < dist)
            if ( (mag_f(z) > (spacing * (i-1)+ dead_area)) && (mag_f(z) <= ((spacing * i) - dead_area) ) )
                pt = time_f(z) - min(time_f) + 1;
                node_tot(i, pt) = node_tot(i, pt) + 1; 
                if((node(i, pt) < 2) )
                    node(i,pt) = node(i,pt) + 1;
                end
            end
        end
    end
end

%%
%{
%person 18 data filtering
node_18 = zeros(num_nodes, elapsed+1);
node_tot18 = zeros(num_nodes,elapsed+1);
for i=1:num_nodes
    for z=1:(elapsed+1)
        if (data_18(z, 2) > 0 && data_18(z,2) < dist)
            if ( (data_18(z,2) > (spacing * (i-1)+ dead_area)) && (data_18(z,2) <= ((spacing * i) - dead_area) ) )
                pt = data_18(z,1) - min(data_18(:,1)) + 1;
                node_tot18(i, pt) = node_tot18(i, pt) + 1; 
                if((node_18(i, pt) < 2) )
                    node_18(i,pt) = node_18(i,pt) + 1;
                end
            end
        end
    end
end


name_18 = 'data_18.csv';
file18 = fopen(name_18,'w');
for (n = 1:1:num_nodes)
    fprintf(file18, '%g,', node_18(n,1:end-1));
    fprintf(file18, '%g\n', node_18(n,end));
end

fclose(file18);
%}

%%
%output formatting/graphing

handles = strings(elapsed + 1,1);
handles(1,1) = '2021-07-04 00:00:00';
handles(2:elapsed + 1,1) = '+1s';
out = zeros(elapsed + 1,3);
out_tot = zeros(elapsed_f + 1, 3);

pwr = zeros(elapsed_f + 1, 1);
tot = zeros(elapsed_f + 1, 1);


physical_nodes = 60;
power_draw = 200000;

for a=1:physical_nodes
    if (a <= (physical_nodes /2))
        name = 'load%d.player';
        name = sprintf(name,a);
    else
        name = 'load%dL.player';
        z = a - (physical_nodes/2);
        name = sprintf(name,z);
    end
    
    fileID = fopen(name,'w');
        for cntr=1:1:elapsed + 1
            if (cntr <= elapsed_f + 1)
                if a <= num_nodes
                    out(cntr,1) = node(a, cntr) * power_draw;
                    out_tot(cntr,1) = node_tot(a, cntr);
                else
                    out(cntr,1) = 0;
                    out_tot(cntr,1) = 0;
                end
                out(cntr,2) = out(cntr,1);
                out(cntr,3) = out(cntr,2);
                
                out_tot(cntr,2) = out_tot(cntr,1);
                out_tot(cntr,3) = out_tot(cntr,2);
            end
        
        fprintf(fileID,'%3s, %d+0j\r\n', handles(cntr), out(cntr,1));
        %, %d+0j, %d+0j\r\n',handles(cntr), out(cntr,1), out(cntr,2), out(cntr,3));
        end
    fclose(fileID);        
        

    pwr  = pwr + out(1:elapsed_f + 1, 2);
    tot = tot + out_tot(:, 2);
    pwr_tot = tot * 25000;

end


num = size(pwr);
num = num(1);

figure(1)
    plot(1:1:num, pwr)
    title('power supplied');
figure(2)
    plot(1:1:num, tot)
    title('cars over nodes');
figure(3)
    plot(1:1:num, pwr_tot)
    title('power with no limits');
figure(4)
    car_data_t = transpose(car_data);
    car_data_f = sortrows(car_data_t);
    plot((1:1:50), (car_data_f(:,3)))
    title('trip time per car');
figure(5)
    car_d = zeros(elapsed_f+1, 1);
    for (f = 1:1:cars)
        g = car_data_f(f,4);
        beg = (g-1) * (elapsed+1) + min(time_f) - min(time);
        fin = beg + elapsed_f;
        car_d(:,f) = mag(beg:fin);
        plot((1:1:elapsed_f+1), (car_d))
        hold on
    end
    hold off

    