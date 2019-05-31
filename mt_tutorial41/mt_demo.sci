clear;

printf('\n');
printf('************** mt demo ****************');
printf('\n');

printf('Enter a File Name of UNIT SPACE');

UnitSpaceFile = input('File Name(.xls)?: ',"string");
//printf('./' +UnitSpaceFile+'.xls\n');

MT_Mat_Sheets   = readxls('./' + UnitSpaceFile + '.xls');  // EXELファイルの読み出し

Sheet           = MT_Mat_Sheets(1);         // Sheetの抜き出し
MTMate          = Sheet.value;              // 数値の取り出し

SampleCount = size( MTMate, 1);
ItemCount   = size( MTMate, 2);

printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCount));
printf('\n');

// 予備計算
for j = 1: ItemCount,
    x1( 1, j) = 0, //行列の初期化
    x2( 1, j) = 0, //行列の初期化
    for i = 1: SampleCount,
        x1( 1, j) = x1( 1, j) + MTMate( i, j),      // 1乗の総和を求める
        x2( 1, j) = x2( 1, j) + MTMate( i, j)^2;    // 2乗の総和を求める
    end,
end

// 算術平均
for j = 1: ItemCount,
    Ave( 1, j) = x1( 1, j) / SampleCount;
end

// 標準偏差(MT法)
for j = 1: ItemCount,
    StDevM( 1, j) = (( x2( 1, j) - (x1( 1, j)^2)/SampleCount) /SampleCount)^0.5;
end

// 基準化
for j = 1: ItemCount,
    for i = 1: SampleCount,
        u( i, j) = (MTMate( i, j) - Ave( 1, j)) / StDevM( 1, j);
    end;
end

//
for k= 1: ItemCount
    for j = 1: ItemCount,
        for i = 1: SampleCount,
            uxu( i, j, k) = u( i, j) * u( i, k);
        end;
    end
end


// 単位空間生成
for j = 1: ItemCount,
    for i = 1: ItemCount,
       R ( i, j) = 0;       // 初期化
    end;
end

for k= 1: ItemCount,
    for j = 1: ItemCount,
        for i = 1: SampleCount,
            R ( j, k) = R ( j, k) + uxu( i, j, k);
        end,
        R ( j, k) = R ( j, k) / SampleCount;
    end;
end

// 単位空間をprint
//disp("R =");
//printf("R =");
//disp(R);
//printf("\n");

// 単位空間の検証
for i=1:SampleCount,
    Ut      = u( i, :),
    U       = Ut',
    D2(i,1) = Ut * inv(R) * U / ItemCount;
end


AveD    = 0;
for i=1:SampleCount,
    AveD    = AveD + D2(i,1);
end
AveD    = AveD / SampleCount;

// 単位空間の検証結果　AveD==1ならGood
printf("AveD = ");
disp(string(AveD));
printf("\n");




/* Chi2 Distribution */

printf("Significance level @0.05");
pro=0.05;
sl=cdfchi( "X", ItemCount, 1-pro, pro);
disp(string(sl));

printf("Significance level @0.01");
pro=0.01;
sl=cdfchi( "X", ItemCount, 1-pro, pro);
disp(string(sl));
printf("\n");

// MDmax for histplot
MDmax= sl*2;

for x = 1: MDmax,

    Total( x, 1)    = cdfchi( "PQ", x, ItemCount);
    
    if x==1 then
        Dist( x, 1) =  Total( x, 1);
    else 
        Dist( x, 1) =  Total( x, 1) - Total( x-1, 1); 
    end,   

end


/* 信号空間1の検証 */

printf('Enter a file name of 1st Signal');
MTSigFile = input('File Name(.xls)?: ',"string");

//printf('./' +MTSigFile+'.xls\n');

MTSig_Sheets   = readxls('./' + MTSigFile + '.xls');  // EXELファイルの読み出し

SigSheet    = MTSig_Sheets(1);         // Sheetの抜き出し
MTSig       = SigSheet.value;              // 数値の取り出し

SampleCount = size( MTSig, 1);
ItemCount   = size( MTSig, 2);

printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCount));

printf('\n');


// 基準化
for j = 1: ItemCount,
    for i = 1: SampleCount,
        v( i, j) = (MTSig( i, j) - Ave( 1, j)) / StDevM( 1, j);
    end;
end


for i=1:SampleCount,
    Vt      = v( i, :),
    V       = Vt',
    S1D2(i,1) = Vt * inv(R) * V / ItemCount;
end

clf;    // clear
//scf;    // add


subplot(2,1,1);
histplot( 0:1:MDmax, (S1D2(:,1)*ItemCount)');
plot( Dist, '.');
xlabel("Mahalanobis Distance^2");


/* 信号空間2の検証 */

printf('Enter a file name of 2nd Signal');
MTSigFile = input('File Name(.xls)?: ',"string");

//printf('./' +MTSigFile+'.xls\n');

MTSig_Sheets   = readxls('./' + MTSigFile + '.xls');  // EXELファイルの読み出し

SigSheet    = MTSig_Sheets(1);         // Sheetの抜き出し
MTSig       = SigSheet.value;              // 数値の取り出し

SampleCount = size( MTSig, 1);
ItemCount   = size( MTSig, 2);

printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCount));

printf('\n');


// 基準化
for j = 1: ItemCount,
    for i = 1: SampleCount,
        v( i, j) = (MTSig( i, j) - Ave( 1, j)) / StDevM( 1, j);
    end;
end


for i=1:SampleCount,
    Vt      = v( i, :),
    V       = Vt',
    S2D2(i,1) = Vt * inv(R) * V / ItemCount;
end

subplot(2,1,2);
histplot( 0:1:MDmax, (S2D2(:,1)*ItemCount)');
plot( Dist, '.');
xlabel("Mahalanobis Distance^2");
