%% 连通域分析
IMG4 = load('img_Bin.dat');

[L, num] = bwlabel(IMG4);  % 标记连通域

% 遍历每个连通域
for region = 1:num
    % 找到当前连通域的所有像素的坐标
    [rows, cols] = find(L == region);
    
    % 获取当前连通域的像素灰度值
    pixel_values = IMG4(L == region);
    
    % 像素数量
    N = length(rows);
    
    %不加权灰度值
    sum_x = sum(cols);
    sum_y = sum(rows);
    x = sum_x/N;
    y = sum_y/N;
    
    %二值化后每个连通域的x坐标累加值
    fprintf('连通域 %d 的x坐标累加值: %.3f\n',region ,sum_x);
    %二值化后每个连通域的y坐标累加值
    fprintf('连通域 %d 的y坐标累加值: %.3f\n',region ,sum_y);
    %二值化后每个连通域的亮度总和
    fprintf('连通域 %d 的面积总和: %.3f\n',region ,N);
    % 输出质心
    fprintf('连通域 %d 的形心: (%.2f, %.2f)\n\n', region, x, y);
   
    %作图
    hold on;plot(x,y,'*');

end
