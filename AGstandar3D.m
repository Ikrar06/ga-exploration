%==============================================================
% Algoritma Genetika Standar (dengan grafis 3D) terdiri dari:
%
% 1. Satu populasi dengan UkPop kromosom
% 2. Binary encoding
% 3. Linear fitness ranking
% 4. Roulette-wheel selection
% 5. Pindah silang satu titik potong
% 6. Probabilitas pindah silang dan probabilitas mutasi bernilai tetap
% 7. Elitisme, satu atau dua buah kopi dari individu bernilai fitness tertinggi
% 8. Generational replacement: mengganti semua individu dengan individu baru
%
%==============================================================

clc             % Me-refresh command window
clear all       % Menghapus semua variabel yang sedang aktif

Nvar    = 2;                % Jumlah variabel pada fungsi yang dioptimasi
Nbit    = 10;               % Jumlah bit yang mengkodekan satu variabel
JumGen  = Nbit*Nvar;        % Jumlah gen dalam kromosom
Rb      = -5.12;            % Batas bawah interval
Ra      = 5.12;             % Batas atas interval

UkPop   = 200;              % Jumlah kromosom dalam populasi
Psilang = 0.8;              % Probabilitas pindah silang
Pmutasi = 0.05;             % Probabilitas mutasi
MaxG    = 100;              % Jumlah generasi

BilKecil    = 10^-1;        % Digunakan untuk menghindari pembagian dengan 0
Fthreshold  = 1/BilKecil;   % Threshold untuk nilai Fitness
Bgraf       = Fthreshold;   % Untuk menangani tampilan grafis

% Inisialisasi grafis 3D
hfig = figure;
hold on;
title('Optimasi fungsi menggunakan AG standar dengan grafis 3 dimensi')
set(hfig, 'DoubleBuffer', 'on');
delta = 0.02;
limit = fix(2*Ra/delta) + 1;
[xg, yg] = meshgrid(Rb:delta:Ra, Rb:delta:Ra);
zg = zeros(limit, limit);
for j = 1:limit
    for k = 1:limit
        zg(j,k) = EvaluasiIndividu([xg(j,k) yg(j,k)], BilKecil);
    end
end
surfl(xg, yg, zg)
colormap gray;
shading interp;
view([3 5 2]);
xind = zeros(UkPop, 3);
h_indplot = plot3(xind(:,1), xind(:,2), xind(:,3), 'k*');
hold off
drawnow

% Inisialisasi populasi
Populasi = InisialisasiPopulasi(UkPop, JumGen);

% Loop evolusi
for generasi = 1:MaxG,
    x = DekodekanKromosom(Populasi(1,:), Nvar, Nbit, Ra, Rb);
    Fitness(1) = EvaluasiIndividu(x, BilKecil);

    % xind digunakan untuk tampilan grafis
    xind(1,1) = x(1);
    xind(1,2) = x(2);
    xind(1,3) = Fitness(1);

    MaxF = Fitness(1);
    MinF = Fitness(1);
    IndeksIndividuTerbaik = 1;
    BestX = x;

    for ii = 2:UkPop,
        Kromosom = Populasi(ii,:);
        x = DekodekanKromosom(Kromosom, Nvar, Nbit, Ra, Rb);
        Fitness(ii) = EvaluasiIndividu(x, BilKecil);

        % xind digunakan untuk tampilan grafis
        xind(ii,1) = x(1);
        xind(ii,2) = x(2);
        xind(ii,3) = Fitness(ii);

        if (Fitness(ii) > MaxF),
            MaxF = Fitness(ii);
            IndeksIndividuTerbaik = ii;
            BestX = x;
        end
        if (Fitness(ii) < MinF),
            MinF = Fitness(ii);
        end
    end

    % Penanganan grafis 3D
    set(h_indplot, 'XData', xind(:,1), 'YData', xind(:,2), 'ZData', xind(:,3));
    drawnow;

    if MaxF >= Fthreshold,
        break;
    end

    TempPopulasi = Populasi;

    % Elitisme:
    % - Buat satu kopi kromosom terbaik jika ukuran populasi ganjil
    % - Buat dua kopi kromosom terbaik jika ukuran populasi genap
    if mod(UkPop,2)==0,         % ukuran populasi genap
        IterasiMulai = 3;
        TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
        TempPopulasi(2,:) = Populasi(IndeksIndividuTerbaik,:);
    else                        % ukuran populasi ganjil
        IterasiMulai = 2;
        TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
    end

    LinearFitness = LinearFitnessRanking(UkPop, Fitness, MaxF, MinF);

    % Roulette-wheel selection dan pindah silang
    for jj = IterasiMulai:2:UkPop,
        IP1 = RouletteWheel(UkPop, LinearFitness);
        IP2 = RouletteWheel(UkPop, LinearFitness);
        if (rand < Psilang),
            Anak = PindahSilang(Populasi(IP1,:), Populasi(IP2,:), JumGen);
            TempPopulasi(jj,:)   = Anak(1,:);
            TempPopulasi(jj+1,:) = Anak(2,:);
        else
            TempPopulasi(jj,:)   = Populasi(IP1,:);
            TempPopulasi(jj+1,:) = Populasi(IP2,:);
        end
    end

    % Mutasi dilakukan pada semua kromosom
    for kk = IterasiMulai:UkPop,
        TempPopulasi(kk,:) = Mutasi(TempPopulasi(kk,:), JumGen, Pmutasi);
    end

    % Generational Replacement: mengganti semua kromosom sekaligus
    Populasi = TempPopulasi;

end