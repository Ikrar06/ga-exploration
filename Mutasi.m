%=================================================================
% Mutasi gen dengan probabilitas sebesar Pmutasi
% Gen-gen yang terpilih diubah nilainya: 0 menjadi 1, dan 1 menjadi 0
%
% Masukan
%   Kromosom : kromosom, matriks berukuran 1 x JumGen
%   JumGen   : jumlah gen
%   Pmutasi  : Probabilitas mutasi
%
% Keluaran
%   MutKrom : kromosom hasil mutasi, matriks berukuran 1 x JumGen
%=================================================================
function MutKrom = Mutasi(Kromosom, JumGen, Pmutasi)
    MutKrom = Kromosom;
    for ii = 1:JumGen
        if (rand < Pmutasi)
            if Kromosom(ii) == 0
                MutKrom(ii) = 1;
            else
                MutKrom(ii) = 0;
            end
        end
    end
end
