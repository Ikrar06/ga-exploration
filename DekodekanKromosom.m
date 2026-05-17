%=================================================================
% Mendekodekan kromosom yang berisi bilangan biner menjadi individu x
% yang bernilai real dalam interval yang ditentukan [Ra,Rb]
%
% Masukan
%   Kromosom : kromosom, matriks berukuran 1 x JumGen
%   Nvar     : jumlah variabel
%   Nbit     : jumlah bit yang mengkodekan satu variabel
%   Ra       : batas atas interval
%   Rb       : batas bawah interval
%
% Keluaran
%   x : individu hasil dekode kromosom
%=================================================================
function x = DekodekanKromosom(Kromosom, Nvar, Nbit, Ra, Rb)
    for ii = 1:Nvar
        x(ii) = 0;
        for jj = 1:Nbit
            x(ii) = x(ii) + Kromosom((ii-1)*Nbit + jj) * 2^(-jj);
        end
        x(ii) = Rb + (Ra - Rb) * x(ii);
    end
end
