POLY = hex2dec('1EDC6F41');
DATA_WIDTH = 256;   % 可调整位宽

% 1. 构造 polyC（dec2bin 不补前导零，所以长度是 29，现在的写法是对的）
polyC = str2num(dec2bin(POLY)');   % 29×1

% 2. 构造 F（32×32）
F = zeros(32, 32);
F(1:31, 2:32) = eye(31);
F(4:32, 1) = polyC;               % 前 3 位是 0，所以不用显式写 F(:,1)=polyC
F_gf = gf(F);

% 3. 计算 A = F^256
A_gf = F_gf ^ DATA_WIDTH;

% 4. 计算 B（32×256）
g = F_gf(:, 1);                   % 输入影响向量
B_gf = gf(zeros(32, DATA_WIDTH));
for i = 1:DATA_WIDTH
    % 第 i 列对应 data[DATA_WIDTH-i]，影响是 F^(DATA_WIDTH-i) * g
    B_gf(:, i) = F_gf ^ (DATA_WIDTH - i) * g;
end

% 5. 转回 double（0/1 矩阵）
A_mat = double(A_gf.x);
B_mat = double(B_gf.x);

%%__%%
% 位反转变换，对齐 GenCRC32.v / CRC32.py 的
A_rev = flip(flip(A_mat, 1), 2);
B_rev = flip(flip(B_mat, 1), 2);

fid = fopen('crc32_parallel_256.v', 'w');
% ____
fprintf(fid, '// Auto-generated 256-bit parallel CRC-32C (Castagnoli)\n');
fprintf(fid, '// Polynomial: 0x1EDC6F41\n');
fprintf(fid, '// Aligned with GenCRC32.v / CRC32.py bit ordering\n');
fprintf(fid, 'module crc32_parallel_256 (\n');
fprintf(fid, '    input  [31:0]  crcIn,\n');
fprintf(fid, '    input  [255:0] data,\n');
fprintf(fid, '    output [31:0]  crcOut\n');
fprintf(fid, ');\n\n');

for j = 1:32
    a_bits = find(A_rev(j, :) == 1) - 1;   % crcIn 位号
    b_bits = find(B_rev(j, :) == 1) - 1;   % data 位号（data[255] 对应 B_rev 第1列）
    
    terms = {};
    for k = 1:length(a_bits)
        terms{end+1} = sprintf('crcIn[%d]', a_bits(k));
    end
    for k = 1:length(b_bits)
        terms{end+1} = sprintf('data[%d]', b_bits(k));
    end
    
    fprintf(fid, '    assign crcOut[%d] = ', j-1);
    if isempty(terms)
        fprintf(fid, '1''b0');
    else
        fprintf(fid, '%s', strjoin(terms, ' ^ '));
    end
    fprintf(fid, ';\n');
end

fprintf(fid, '\nendmodule\n');
fclose(fid);
disp('Generated: crc32_parallel_256.v');