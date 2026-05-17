%=================================================================
% EKSPERIMEN 1: Pengaruh Mutation Rate terhadap Performa GA
%
% Fungsi: h(x1,x2) = 1000*(x1-2*x2)^2 + (1-x1)^2
% Minimum global: h=0 saat x1=1, x2=0.5
%=================================================================

clc; clear all; close all;

%% Parameter tetap (baseline)
Nvar     = 2;
Nbit     = 10;
JumGen   = Nbit * Nvar;
Rb       = -5.12;
Ra       =  5.12;
UkPop    = 200;
Psilang  = 0.8;
MaxG     = 100;
BilKecil = 10^-1;
Fthreshold = 1/BilKecil;
nRun     = 10;   % Jumlah run per konfigurasi (untuk rata-rata)

%% Variasi Mutation Rate yang diuji
MutationRates = [0.001, 0.01, 0.05, 0.1, 0.2, 0.5];
nConfig = length(MutationRates);

%% Struktur penyimpanan hasil
results = struct();
for c = 1:nConfig
    results(c).Pmutasi       = MutationRates(c);
    results(c).bestFitness   = zeros(1, nRun);
    results(c).bestX1        = zeros(1, nRun);
    results(c).bestX2        = zeros(1, nRun);
    results(c).minH          = zeros(1, nRun);
    results(c).genConverge   = zeros(1, nRun);
    results(c).fitnessHistory = zeros(nRun, MaxG);
end

%% Loop eksperimen
fprintf('=== EKSPERIMEN 1: Pengaruh Mutation Rate ===\n\n');

for c = 1:nConfig
    Pmutasi = MutationRates(c);
    fprintf('Pmutasi = %.3f | Running %d kali...\n', Pmutasi, nRun);

    for r = 1:nRun
        Populasi = InisialisasiPopulasi(UkPop, JumGen);
        fitnessHist = zeros(1, MaxG);
        genConv = MaxG;

        for generasi = 1:MaxG
            x = DekodekanKromosom(Populasi(1,:), Nvar, Nbit, Ra, Rb);
            Fitness(1) = EvaluasiIndividu(x, BilKecil);
            MaxF = Fitness(1); MinF = Fitness(1);
            IndeksIndividuTerbaik = 1;
            BestX = x;

            for ii = 2:UkPop
                Kromosom = Populasi(ii,:);
                x = DekodekanKromosom(Kromosom, Nvar, Nbit, Ra, Rb);
                Fitness(ii) = EvaluasiIndividu(x, BilKecil);
                if Fitness(ii) > MaxF
                    MaxF = Fitness(ii);
                    IndeksIndividuTerbaik = ii;
                    BestX = x;
                end
                if Fitness(ii) < MinF, MinF = Fitness(ii); end
            end

            fitnessHist(generasi) = MaxF;

            if MaxF >= Fthreshold && genConv == MaxG
                genConv = generasi;
            end

            if MaxF >= Fthreshold, break; end

            % Elitisme
            TempPopulasi = Populasi;
            if mod(UkPop,2)==0
                IterasiMulai = 3;
                TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
                TempPopulasi(2,:) = Populasi(IndeksIndividuTerbaik,:);
            else
                IterasiMulai = 2;
                TempPopulasi(1,:) = Populasi(IndeksIndividuTerbaik,:);
            end

            LinearFitness = LinearFitnessRanking(UkPop, Fitness, MaxF, MinF);

            for jj = IterasiMulai:2:UkPop
                IP1 = RouletteWheel(UkPop, LinearFitness);
                IP2 = RouletteWheel(UkPop, LinearFitness);
                if rand < Psilang
                    Anak = PindahSilang(Populasi(IP1,:), Populasi(IP2,:), JumGen);
                    TempPopulasi(jj,:)   = Anak(1,:);
                    TempPopulasi(jj+1,:) = Anak(2,:);
                else
                    TempPopulasi(jj,:)   = Populasi(IP1,:);
                    TempPopulasi(jj+1,:) = Populasi(IP2,:);
                end
            end

            for kk = IterasiMulai:UkPop
                TempPopulasi(kk,:) = Mutasi(TempPopulasi(kk,:), JumGen, Pmutasi);
            end

            Populasi = TempPopulasi;
        end

        % Simpan sisa generasi dengan nilai terakhir
        if generasi < MaxG
            fitnessHist(generasi+1:end) = MaxF;
        end

        results(c).bestFitness(r)      = MaxF;
        results(c).bestX1(r)           = BestX(1);
        results(c).bestX2(r)           = BestX(2);
        results(c).minH(r)             = (1/MaxF) - BilKecil;
        results(c).genConverge(r)      = genConv;
        results(c).fitnessHistory(r,:) = fitnessHist;
    end

    results(c).meanFitness  = mean(results(c).bestFitness);
    results(c).stdFitness   = std(results(c).bestFitness);
    results(c).meanMinH     = mean(results(c).minH);
    results(c).meanGenConv  = mean(results(c).genConverge);
    results(c).successRate  = sum(results(c).bestFitness >= Fthreshold) / nRun * 100;
    results(c).avgHistory   = mean(results(c).fitnessHistory, 1);

    fprintf('  -> Mean fitness: %.4f | Std: %.4f | Success: %.0f%% | Avg gen konvergen: %.1f\n', ...
        results(c).meanFitness, results(c).stdFitness, ...
        results(c).successRate, results(c).meanGenConv);
end

%% === VISUALISASI ===
colors = lines(nConfig);
legends = cell(1, nConfig);

% --- Plot 1: Rata-rata kurva fitness per generasi ---
figure('Name', 'Eks1 - Kurva Konvergensi per Pmutasi', 'Position', [50 50 800 500]);
hold on;
for c = 1:nConfig
    plot(1:MaxG, results(c).avgHistory, 'Color', colors(c,:), 'LineWidth', 2);
    legends{c} = sprintf('Pmutasi=%.3f', MutationRates(c));
end
xlabel('Generasi');
ylabel('Rata-rata Fitness Terbaik');
title('Pengaruh Mutation Rate terhadap Kurva Konvergensi (rata-rata 10 run)');
legend(legends, 'Location', 'southeast');
grid on;
hold off;
saveas(gcf, 'Eks1_KurvaKonvergensi.png');

% --- Plot 2: Box plot mean fitness ---
figure('Name', 'Eks1 - Distribusi Fitness Terbaik', 'Position', [100 100 800 450]);
allData = zeros(nRun, nConfig);
for c = 1:nConfig
    allData(:,c) = results(c).bestFitness;
end
boxplot(allData, 'Labels', arrayfun(@(x) sprintf('%.3f',x), MutationRates, 'UniformOutput', false));
xlabel('Mutation Rate (Pmutasi)');
ylabel('Fitness Terbaik');
title('Distribusi Fitness Terbaik pada Berbagai Mutation Rate');
grid on;
saveas(gcf, 'Eks1_BoxplotFitness.png');

% --- Plot 3: Success rate bar chart ---
figure('Name', 'Eks1 - Success Rate', 'Position', [150 150 700 400]);
successRates = arrayfun(@(x) x.successRate, results);
bar(successRates, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.3f',x), MutationRates, 'UniformOutput', false));
xlabel('Mutation Rate (Pmutasi)');
ylabel('Success Rate (%)');
title('Success Rate Mencapai Fitness Threshold per Mutation Rate');
grid on;
ylim([0 110]);
for i = 1:nConfig
    text(i, successRates(i)+3, sprintf('%.0f%%', successRates(i)), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end
saveas(gcf, 'Eks1_SuccessRate.png');

%% === TABEL RINGKASAN ===
fprintf('\n========================================================\n');
fprintf('  RINGKASAN EKSPERIMEN 1: Pengaruh Mutation Rate\n');
fprintf('========================================================\n');
fprintf('%-10s %-14s %-10s %-14s %-10s\n', ...
    'Pmutasi', 'Mean Fitness', 'Std', 'Mean min-h', 'Success(%)');
fprintf('%s\n', repmat('-',1,60));
for c = 1:nConfig
    fprintf('%-10.3f %-14.4f %-10.4f %-14.6f %-10.1f\n', ...
        results(c).Pmutasi, results(c).meanFitness, results(c).stdFitness, ...
        results(c).meanMinH, results(c).successRate);
end
fprintf('========================================================\n');

save('results_eks1_mutasi.mat', 'results', 'MutationRates');
fprintf('\nHasil disimpan ke results_eks1_mutasi.mat\n');
fprintf('Gambar disimpan: Eks1_KurvaKonvergensi.png, Eks1_BoxplotFitness.png, Eks1_SuccessRate.png\n');
