clear;

printf('Enter a File Name of UNIT SPACE Material');
UnitSpaceFile = input('File Name(.xls)?: ',"string");
//scanf('%s',UnitSpaceFile);

printf('./' +UnitSpaceFile+'.xls\n');
//f=findfiles(SCI,UnitSpaceFile+'.xls');


//MT_Mat_Sheets   = readxls('./mt_mat.xls');  // EXELファイルの読み出し
MT_Mat_Sheets   = readxls('./' + UnitSpaceFile + '.xls');  // EXELファイルの読み出し


Sheet           = MT_Mat_Sheets(1);         // Sheetの抜き出し
MTMate          = Sheet.value;              // 数値の取り出し

SampleCount = size( MTMate, 1);
ItemCount   = size( MTMate, 2);

// 
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
printf("R =");
disp(R);
printf("\n");

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


/* 信号空間の検証 */

printf('Enter a File Name of MT Signal Material');
MTSigFile = input('File Name(.xls)?: ',"string");

printf('./' +MTSigFile+'.xls\n');

MTSig_Sheets   = readxls('./' + MTSigFile + '.xls');  // EXELファイルの読み出し

SigSheet        = MTSig_Sheets(1);         // Sheetの抜き出し
MTSig           = SigSheet.value;              // 数値の取り出し

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
    SD2(i,1) = Vt * inv(R) * V / ItemCount;
end

//clf;    // clear
scf;    // add

subplot(2,2,1);
plot2d(D2);
subplot(2,2,2);
//histplot( 0:1:30, D2(:,1)');
histplot( 30, D2(:,1)');

subplot(2,2,3);
plot2d(SD2);
subplot(2,2,4);
//histplot( 0:1:30, SD2(:,1)');
histplot( 30, SD2(:,1)');
