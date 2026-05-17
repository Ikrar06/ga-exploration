%=================================================================
% EKSPERIMEN 2: Pengaruh Crossover Rate terhadap Performa GA
%
% Fungsi: h(x1,x2) = 1000*(x1-2*x2)^2 + (1-x1)^2
%=================================================================

clc; clear all; close all;

%% Parameter tetap (baseline)
Nvar     = 2;
Nbit     = 10;
JumGen   = Nbit * Nvar;
Rb       = -5.12;
Ra       =  5.12;
UkPop    = 200;
Pmutasi  = 0.05;   % mutation rate default dari buku
MaxG     = 100;
BilKecil = 10^-1;
Fthreshold = 1/BilKecil;
nRun     = 10;

%% Variasi Crossover Rate
CrossoverRates = [0.2, 0.4, 0.6, 0.8, 0.9, 1.0];
nConfig = length(CrossoverRates);

%% Struktur penyimpanan hasil
results2 = struct();
for c = 1:nConfig
    results2(c).Psilang       = CrossoverRates(c);
    results2(c).bestFitness   = zeros(1, nRun);
    results2(c).minH          = zeros(1, nRun);
    results2(c).genConverge   = zeros(1, nRun);
    results2(c).fitnessHistory = zeros(nRun, MaxG);
end

%% Loop eksperimen
fprintf('=== EKSPERIMEN 2: Pengaruh Crossover Rate ===\n\n');

for c = 1:nConfig
    Psilang = CrossoverRates(c);
    fprintf('Psilang = %.2f | Running %d kali...\n', Psilang, nRun);

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

        if generasi < MaxG
            fitnessHist(generasi+1:end) = MaxF;
        end

        results2(c).bestFitness(r)      = MaxF;
        results2(c).minH(r)             = (1/MaxF) - BilKecil;
        results2(c).genConverge(r)      = genConv;
        results2(c).fitnessHistory(r,:) = fitnessHist;
    end

    results2(c).meanFitness  = mean(results2(c).bestFitness);
    results2(c).stdFitness   = std(results2(c).bestFitness);
    results2(c).meanMinH     = mean(results2(c).minH);
    results2(c).meanGenConv  = mean(results2(c).genConverge);
    results2(c).successRate  = sum(results2(c).bestFitness >= Fthreshold) / nRun * 100;
    results2(c).avgHistory   = mean(results2(c).fitnessHistory, 1);

    fprintf('  -> Mean fitness: %.4f | Std: %.4f | Success: %.0f%% | Avg gen konvergen: %.1f\n', ...
        results2(c).meanFitness, results2(c).stdFitness, ...
        results2(c).successRate, results2(c).meanGenConv);
end

%% === VISUALISASI ===
colors = lines(nConfig);
legends = cell(1, nConfig);

figure('Name', 'Eks2 - Kurva Konvergensi per Psilang', 'Position', [50 50 800 500]);
hold on;
for c = 1:nConfig
    plot(1:MaxG, results2(c).avgHistory, 'Color', colors(c,:), 'LineWidth', 2);
    legends{c} = sprintf('Psilang=%.2f', CrossoverRates(c));
end
xlabel('Generasi');
ylabel('Rata-rata Fitness Terbaik');
title('Pengaruh Crossover Rate terhadap Kurva Konvergensi (rata-rata 10 run)');
legend(legends, 'Location', 'southeast');
grid on;
hold off;
saveas(gcf, 'Eks2_KurvaKonvergensi.png');

figure('Name', 'Eks2 - Distribusi Fitness', 'Position', [100 100 800 450]);
allData = zeros(nRun, nConfig);
for c = 1:nConfig, allData(:,c) = results2(c).bestFitness; end
boxplot(allData, 'Labels', arrayfun(@(x) sprintf('%.2f',x), CrossoverRates, 'UniformOutput', false));
xlabel('Crossover Rate (Psilang)');
ylabel('Fitness Terbaik');
title('Distribusi Fitness Terbaik pada Berbagai Crossover Rate');
grid on;
saveas(gcf, 'Eks2_BoxplotFitness.png');

% --- Tradeoff: Crossover Rate vs Generasi Konvergensi ---
figure('Name', 'Eks2 - Crossover Rate vs Gen Konvergen', 'Position', [150 150 700 400]);
meanGenConvArr = arrayfun(@(x) x.meanGenConv, results2);
plot(CrossoverRates, meanGenConvArr, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Crossover Rate (Psilang)');
ylabel('Rata-rata Generasi Konvergen');
title('Crossover Rate vs Kecepatan Konvergensi');
grid on;
saveas(gcf, 'Eks2_CrossoverVsGenKonvergen.png');

%% === TABEL RINGKASAN ===
fprintf('\n========================================================\n');
fprintf('  RINGKASAN EKSPERIMEN 2: Pengaruh Crossover Rate\n');
fprintf('========================================================\n');
fprintf('%-10s %-14s %-10s %-14s %-12s\n', ...
    'Psilang', 'Mean Fitness', 'Std', 'Mean min-h', 'Success(%)');
fprintf('%s\n', repmat('-',1,62));
for c = 1:nConfig
    fprintf('%-10.2f %-14.4f %-10.4f %-14.6f %-12.1f\n', ...
        results2(c).Psilang, results2(c).meanFitness, results2(c).stdFitness, ...
        results2(c).meanMinH, results2(c).successRate);
end
fprintf('========================================================\n');

save('results_eks2_crossover.mat', 'results2', 'CrossoverRates');
fprintf('\nHasil disimpan ke results_eks2_crossover.mat\n');
