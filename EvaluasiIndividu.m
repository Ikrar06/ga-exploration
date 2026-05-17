%=================================================================
% Mengevaluasi individu sehingga didapatkan nilai fitness-nya
%
% Masukan
%   x        : individu
%   BilKecil : bilangan kecil digunakan untuk menghindari pembagian dengan 0
%
% Keluaran
%   fitness : nilai fitness
%=================================================================
function fitness = EvaluasiIndividu(x, BilKecil)
    % Fungsi h(x1,x2) = 1000*(x1 - 2*x2)^2 + (1 - x1)^2
    % Minimum global: h=0 saat x1=1, x2=0.5
    fitness = 1 / ((1000*(x(1) - 2*x(2))^2 + (1 - x(1))^2) + BilKecil);
end
