    x = rand(1000,1)*4-2;  
    y = rand(1000,1)*4-2;
    z = 3*sin(x*15)+ randn(size(x));

    subplot(2,2,1)
    scatter(x,y,4,z,'filled'); box on;
    ylabel('y'); xlabel('x')
    title('data (coloring according to z-value)')
    subplot(2,2,2)
    hist(z,20)
    ylabel('frequency'); xlabel('z')
    title('histogram of z-values')
    subplot(2,2,3)
    d = variogram([x y],z,'plotit',true,'nrbins',50);
    title('Isotropic variogram')
    subplot(2,2,4)
    d2 = variogram([x y],z,'plotit',true,'nrbins',50,'anisotropy',true);
    title('Anisotropic variogram')
    
% % Birko starts here :)
% % All Z diffs
% [tmp1 tmp2] = meshgrid(z,z);
% V_mat = abs(tmp1 - tmp2);
% V_mat = V_mat';
% V_mat = (V_mat.^2)*0.5;
% 
% % All Distances
% [tmp1 tmp2] = meshgrid(x,x);
% X_difs = tmp1-tmp2;
% [tmp1 tmp2] = meshgrid(y,y);
% Y_difs = tmp1-tmp2;
% 
% Distances = (X_difs.^2+Y_difs.^2).^0.5;
% 
% % Find lag graph
% my_x = 0.02821:0.0625:2.7;
% my_values = zeros(size(my_x));
% curr_index = 1;
% 
% for lag=my_x
%     indices = find((Distances < lag-0.1) & (Distances < lag+0.1) & (Distances > 0));
%     my_values(curr_index) = sum(V_mat(indices))*(1/(size(indices,1)));
%     curr_index = curr_index+1;
% end
% 
% figure();
% plot(my_x,my_values,'-o');
% xlim([0 2.75])
% ylim([0 8])
% 
% % Plot just Variogram
% figure()
% variogram([x y],z,'plotit',true,'nrbins',50);
% 
