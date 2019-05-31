clear;

clf;    // clear
//scf;    // add

printf('\n');
printf('************** rt demo ****************');
printf('\n');

printf('Enter a File Name of Unit');
UnitSpaceFile = input('File Name(.xls)?: ',"string");


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
    for j = 1: ItemCount,
        L(i,1)   = L(i,1) + xy(i,j),
    end,
end

// BETA, BETAa, Sb
for i = 1: SampleCount,
    BETA(i,1)   = L(i,1)    / r,
    Sb(i,1)     = L(i,1)^2  / r,
end

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
//BETAa=1;
BETAa=0;

for i = 1: SampleCount,
    Se(i,1)     = Sg(i,1) - Sb(i,1),
    Ve(i,1)     = Se(i,1) / (ItemCount-1),
    //Ve(i,1)     = Se(i,1) / (ItemCount),
    rVe(i,1)    = Ve(i,1)^0.5,
    rVea        = rVea + rVe(i,1),
    BETAa       = BETAa + BETA(i,1),
end
rVea    = rVea / SampleCount;
BETAa   = BETAa / SampleCount;

//printf("BETAa = ");
//disp(string(BETAa));
//printf("\n");
//printf("rVea = ");
//disp(string(rVea));
//printf("\n");


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

//printf("B = ");
//disp(string(B));
//printf("\n");

// u, ut, D2
Dsum=0
D2sum=0
for i = 1: SampleCount,
    u   = [ dBETA(i,1), ds(i,1)],
    ut  = u',
    D2(i,1) = 0.5 * u * B * ut,
    D(i,1)  = D2(i,1)^0.5,
    Dsum    = Dsum + D(i,1),
    D2sum   = D2sum + D2(i,1),
end

Dave   = (D2sum/SampleCount)^0.5;

//printf("Dave = ");
//disp(string(Dave));
//printf("\n");

j=0;
for z = 1.5: 0.5: 3.5,
    
    cnt=0;

    for i= 1: SampleCount,
        
        if D(i,1) > z * Dave then
            cnt=cnt+1;
        end,

    end,

    j=j+1;
    Syukei(j,1)=z;
    Syukei(j,2)=cnt;
    Syukei(j,3)=cnt/SampleCount;

end

printf("Syukei = ");
disp(string(Syukei));
printf("\n");


subplot(3,1,1);
plot( D, '.');
xlabel("Sample No,");
ylabel("RT Distance");


z = input('z? : ');

D(:,2)  = Dave * z;
plot( D(:,2), 'k-');




/* 信号空間1の検証 */

printf('Enter a File Name of RT Signal1');
RTSigFile = input('File Name(.xls)?: ',"string");

RTSig_Sheets   = readxls('./' + RTSigFile + '.xls');  // EXELファイルの読み出し

SigSheet        = RTSig_Sheets(1);         // Sheetの抜き出し
RTSig           = SigSheet.value;              // 数値の取り出し

SampleCount = size( RTSig, 1);
ItemCountS1   = size( RTSig, 2);

// 
printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCountS1));
printf('\n');

if ItemCount <> ItemCountS1 then
    printf(' RT Signal 1 is not Suitable\n'),
    break;    
end


// L
for j = 1: ItemCount,
    for i = 1: SampleCount,
        xys1( i, j) = Ave( 1, j) * RTSig( i, j),
    end,
end
for i = 1: SampleCount,
    Ls1(i,1)   = 0,
    for j = 1: ItemCount,
        Ls1(i,1)   = Ls1(i,1) + xys1(i,j),
    end,
end

// BETA, BETAa, Sb
for i = 1: SampleCount,
    BETAs1(i,1)   = Ls1(i,1)    / r,
    Sbs1(i,1)     = Ls1(i,1)^2  / r,
end

// Sg
for j = 1: ItemCount,
    for i = 1: SampleCount,
        y2s1( i, j) = RTSig( i, j)^2,
    end,
end
for i = 1: SampleCount,
    Sgs1(i,1)   = 0,
    for j = 1: ItemCount,
        Sgs1(i,1)   = Sgs1(i,1) + y2s1(i,j),
    end,
end

// Se, Ve, rVe, rVea
for i = 1: SampleCount,
    Ses1(i,1)     = Sgs1(i,1) - Sbs1(i,1),
    Ves1(i,1)     = Ses1(i,1) / (ItemCount-1),
    rVes1(i,1)    = Ves1(i,1)^0.5,
end

for i = 1: SampleCount,
    dBETAs1(i,1)     = BETAs1(i,1) - BETAa,
    dss1(i,1)         = rVes1((i,1)) - rVea,
end

for i = 1: SampleCount,
    u   = [ dBETAs1(i,1), dss1(i,1)],
    ut  = u',
    D2s1(i,1)   = 0.5 * u * B * ut,
    Ds1(i,1)    = D2s1(i,1)^0.5,
end

subplot(3,1,2);
plot( Ds1, '.');
xlabel("Sample No,");
ylabel("RT Distance");
plot( D(:,2), 'k-');


/* 信号空間2の検証 */

printf('Enter a File Name of RT Signal1');
RTSigFile = input('File Name(.xls)?: ',"string");

RTSig_Sheets   = readxls('./' + RTSigFile + '.xls');  // EXELファイルの読み出し

SigSheet        = RTSig_Sheets(1);         // Sheetの抜き出し
RTSig2           = SigSheet.value;              // 数値の取り出し

SampleCount = size( RTSig2, 1);
ItemCountS1   = size( RTSig2, 2);

// 
printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCountS1));
printf('\n');

if ItemCount <> ItemCountS1 then
    printf(' RT Signal 2 is not Suitable\n'),
    break;    
end


// L
for j = 1: ItemCount,
    for i = 1: SampleCount,
        xys2( i, j) = Ave( 1, j) * RTSig2( i, j),
    end,
end
for i = 1: SampleCount,
    Ls2(i,1)   = 0,
    for j = 1: ItemCount,
        Ls2(i,1)   = Ls2(i,1) + xys2(i,j),
    end,
end

// BETA, BETAa, Sb
for i = 1: SampleCount,
    BETAs2(i,1)   = Ls2(i,1)    / r,
    Sbs2(i,1)     = Ls2(i,1)^2  / r,
end

// Sg
for j = 1: ItemCount,
    for i = 1: SampleCount,
        y2s2( i, j) = RTSig2( i, j)^2,
    end,
end
for i = 1: SampleCount,
    Sgs2(i,1)   = 0,
    for j = 1: ItemCount,
        Sgs2(i,1)   = Sgs2(i,1) + y2s2(i,j),
    end,
end

// Se, Ve, rVe, rVea
for i = 1: SampleCount,
    Ses2(i,1)     = Sgs2(i,1) - Sbs2(i,1),
    Ves2(i,1)     = Ses2(i,1) / (ItemCount-1),
    rVes2(i,1)    = Ves2(i,1)^0.5,
end

for i = 1: SampleCount,
    dBETAs2(i,1)     = BETAs2(i,1) - BETAa,
    dss2(i,1)         = rVes2((i,1)) - rVea,
end

for i = 1: SampleCount,
    u   = [ dBETAs2(i,1), dss2(i,1)],
    ut  = u',
    D2s2(i,1)   = 0.5 * u * B * ut,
    Ds2(i,1)    = D2s2(i,1)^0.5,
end

subplot(3,1,3);
plot( Ds2, '.');
xlabel("Sample No,");
ylabel("RT Distance");
plot( D(:,2), 'k-');






