clear;

printf('Enter a File Name of UNIT SPACE Material');
UnitSpaceFile = input('File Name(.xls)?: ',"string");

printf('./' +UnitSpaceFile+'.xls\n');

RT_Mat_Sheets   = readxls('./' + UnitSpaceFile + '.xls');  // EXELファイルの読み出し

Sheet           = RT_Mat_Sheets(1);         // Sheetの抜き出し
RTMate          = Sheet.value;              // 数値の取り出し

SampleCount = size( RTMate, 1);
ItemCount   = size( RTMate, 2);

// 
printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCount));
printf('\n');

// 予備計算
for j = 1: ItemCount,
    x1( 1, j) = 0, //行列の初期化
    for i = 1: SampleCount,
        x1( 1, j) = x1( 1, j) + RTMate( i, j),      // 1乗の総和を求める
    end,
end

// 算術平均
for j = 1: ItemCount,
    Ave( 1, j) = x1( 1, j) / SampleCount;
end

// r
r=0;
for j = 1: ItemCount,
    r   = r + Ave(1,j)^2,
end

// L
for j = 1: ItemCount,
    for i = 1: SampleCount,
        xy( i, j) = Ave( 1, j) * RTMate( i, j),
    end,
end
for i = 1: SampleCount,
    L(i,1)   = 0,
end
for i = 1: SampleCount,
    L(i,1)   = 0,
    for j = 1: ItemCount,
        L(i,1)   = L(i,1) + xy(i,j),
    end,
end

// BETA, BETAa, Sb
for i = 1: SampleCount,
    BETA(i,1)   = L(i,1)    / r,
    Sb(i,1)     = L(i,1)^2  / r,
end
BETAa=1;

// Sg
for j = 1: ItemCount,
    for i = 1: SampleCount,
        y2( i, j) = RTMate( i, j)^2,
    end,
end
for i = 1: SampleCount,
    Sg(i,1)   = 0,
    for j = 1: ItemCount,
        Sg(i,1)   = Sg(i,1) + y2(i,j),
    end,
end

// Se, Ve, rVe, rVea
rVea=0;
for i = 1: SampleCount,
    Se(i,1)     = Sg(i,1) - Sb(i,1),
    Ve(i,1)     = Se(i,1) / (ItemCount-1),
    rVe(i,1)    = Ve(i,1)^0.5,
    rVea        = rVea + rVe(i,1),
end
rVea    = rVea / SampleCount;

//dBEATA, dBEATA2, ds, ds2, V11, V12(=V21), V22
V11 = 0; 
V12 = 0;
V22 = 0;
for i = 1: SampleCount,
    dBETA(i,1)     = BETA(i,1) - BETAa,
    dBETA2(i,1)     = dBETA(i,1)^2,
    ds(i,1)         = rVe((i,1)) - rVea,
    ds2(i,1)        = ds(i,1)^2,
    dBETAds(i,1)    = dBETA(i,1)*ds(i,1),

    V11 = V11 + dBETA2(i,1),
    V12 = V12 + dBETAds(i,1),
    V22 = V22 + ds2(i,1),
end
V11 = V11 / (SampleCount-1);
V12 = V12 / (SampleCount-1);
V22 = V22 / (SampleCount-1);

// V, B
V   = [V11, V12; V12, V22];
B   = [V22, -V12; -V12, V11];

printf("B = ");
disp(string(B));
printf("\n");

// u, ut, D2
Dsum=0
D2sum=0
for i = 1: SampleCount,
    u   = [ dBETA(i,1), ds(i,1)],
    ut  = u',
    //D2(i,1) = 0.5 * u * inv(V) * ut,
    D2(i,1) = 0.5 * u * B * ut,
    D(i,1)  = D2(i,1)^0.5,
    Dsum    = Dsum + D(i,1),
    D2sum   = D2sum + D2(i,1),
end

Dave   = (D2sum/SampleCount)^0.5;

printf("Dave = ");
disp(string(Dave));
printf("\n");

/*
c1p5=0;
c2p0=0;
c2p5=0;
c3p0=0;

printf('Dave ='+string(Dave)+'\n');
printf('\n');

for i = 1: SampleCount,
    printf('D'+string(i)+'='+string(D(i,1))),
    if Dave*1.5 <= D(i,1)    then c1p5 = c1p5 + 1,    printf('*');   end,
    if Dave*2.0 <= D(i,1)    then c2p0 = c2p0 + 1,    printf('*');   end,
    if Dave*2.5 <= D(i,1)    then c2p5 = c2p5 + 1,    printf('*');   end,
    if Dave*3.0 <= D(i,1)    then c3p0 = c3p0 + 1,    printf('*');   end,
    printf('\n'),
end

printf('\n');

printf('c1p5 ='+string(c1p5)+'\n');
printf('c2p0 ='+string(c2p0)+'\n');
printf('c2p5 ='+string(c2p5)+'\n');
printf('c3p0 ='+string(c3p0)+'\n');

printf('\n');
*/

printf('Enter a File Name of RT Signal Material');
RTSigFile = input('File Name(.xls)?: ',"string");

printf('./' +RTSigFile+'.xls\n');

RTSig_Sheets   = readxls('./' + RTSigFile + '.xls');  // EXELファイルの読み出し

SigSheet        = RTSig_Sheets(1);         // Sheetの抜き出し
RTSig           = SigSheet.value;              // 数値の取り出し

SampleCount = size( RTSig, 1);
ItemCount   = size( RTSig, 2);

// 
printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCount));
printf('\n');

// 予備計算
for j = 1: ItemCount,
    x1( 1, j) = 0, //行列の初期化
    for i = 1: SampleCount,
        x1( 1, j) = x1( 1, j) + RTSig( i, j),      // 1乗の総和を求める
    end,
end

// 算術平均
for j = 1: ItemCount,
    Ave( 1, j) = x1( 1, j) / SampleCount;
end

// r
r=0;
for j = 1: ItemCount,
    r   = r + Ave(1,j)^2,
end

// L
for j = 1: ItemCount,
    for i = 1: SampleCount,
        xy( i, j) = Ave( 1, j) * RTSig( i, j),
    end,
end
for i = 1: SampleCount,
    L(i,1)   = 0,
end
for i = 1: SampleCount,
    L(i,1)   = 0,
    for j = 1: ItemCount,
        L(i,1)   = L(i,1) + xy(i,j),
    end,
end

// BETA, BETAa, Sb
for i = 1: SampleCount,
    BETAx(i,1)   = L(i,1)    / r,
    Sb(i,1)     = L(i,1)^2  / r,
end
BETAa=1;

// Sg
for j = 1: ItemCount,
    for i = 1: SampleCount,
        y2( i, j) = RTSig( i, j)^2,
    end,
end
for i = 1: SampleCount,
    Sg(i,1)   = 0,
    for j = 1: ItemCount,
        Sg(i,1)   = Sg(i,1) + y2(i,j),
    end,
end

// Se, Ve, rVe, rVea
rVea=0;
for i = 1: SampleCount,
    Se(i,1)     = Sg(i,1) - Sb(i,1),
    Ve(i,1)     = Se(i,1) / (ItemCount-1),
    rVe(i,1)    = Ve(i,1)^0.5,
    rVea        = rVea + rVe(i,1),
end
rVea    = rVea / SampleCount;

for i = 1: SampleCount,
    dBETA(i,1)     = BETA(i,1) - BETAa,
    dBETA2(i,1)     = dBETA(i,1)^2,
    ds(i,1)         = rVe((i,1)) - rVea,
    ds2(i,1)        = ds(i,1)^2,
    dBETAds(i,1)    = dBETA(i,1)*ds(i,1),
end


for i = 1: SampleCount,
    u   = [ dBETA(i,1), ds(i,1)],
    ut  = u',
    D2(i,1)     = 0.5 * u * B * ut,
    Dx(i,1)     = D2(i,1)^0.5,
    RateX(i,1)  = Dx(i,1)/Dave,
end

subplot(1,2,1);
plot2d(Dx);
subplot(1,2,2);
histplot( 0:1:5, RateX(:,1)');

