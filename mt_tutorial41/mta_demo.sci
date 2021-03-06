
clear;

printf('\n');

printf('************** mta demo ****************');
printf('\n');

printf('Enter a File Name of UNIT SPACE Material');
UnitSpaceFile = input('File Name(.xls)?: ',"string");

printf('./' +UnitSpaceFile+'.xls\n');

MTA_Mat_Sheets   = readxls('./' + UnitSpaceFile + '.xls');  // EXELファイルの読み出し

Sheet           = MTA_Mat_Sheets(1);         // Sheetの抜き出し
MTAMate          = Sheet.value;              // 数値の取り出し

SampleCount = size( MTAMate, 1);
ItemCount   = size( MTAMate, 2);

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
        x1( 1, j) = x1( 1, j) + MTAMate( i, j),      // 1乗の総和を求める
        x2( 1, j) = x2( 1, j) + MTAMate( i, j)^2;    // 2乗の総和を求める
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

// 正規化
for j = 1: ItemCount,
    for i = 1: SampleCount,
        u( i, j) = MTAMate( i, j) - Ave( 1, j);
    end;
end

//分散共分散行列
for i = 1: ItemCount,
    ui  = (u(:,i))',
    for j = 1: ItemCount,
        uj  = u(:,j),
        S( i, j) = ui*uj/SampleCount,
    end;
end

//disp(S);
//printf('\n');

//余因子行列
m=1;
n=1;
for i = 1: ItemCount,
    for j = 1: ItemCount,
        for k = 1: ItemCount,
            for l = 1: ItemCount,
                if (k~=i && l~=j)
                then
                  A(m,n)    = S(k,l),
                  n=n+1,
                  if(n>ItemCount-1)
                  then
                    n=1,
                    m=m+1,
                    if(m>ItemCount-1)
                    then
                        m=1,
                        AJMt(i,j) = det(A)*((-1)^(i+j)),
//disp(A);
//printf('\n');
                    end;
                  end;     
                end;
            end;
        end;
    end;
end

AJM = AJMt';

//printf('AJM =');
//disp(AJM);
//printf('\n');


for i=1:SampleCount,
    Ut      = u( i, :),
    U       = Ut',
    D2(i,1) = Ut * AJM * U / ItemCount;
end




// MDmax for histplot
MDmax= 10;



clf;    // clear
//scf;    // add


subplot(3,2,1);
histplot( 30, D2(:,1)');
xlabel("Mahalanobis Distance^2");






/* 信号空間の検証 */

printf('Enter a File Name of MTA Signal Material');
MTASigFile = input('File Name(.xls)?: ',"string");

printf('./' +MTASigFile+'.xls\n');

MTASig_Sheets   = readxls('./' + MTASigFile + '.xls');  // EXELファイルの読み出し

SigSheet        = MTASig_Sheets(1);         // Sheetの抜き出し
MTASig           = SigSheet.value;              // 数値の取り出し

SampleCountS = size( MTASig, 1);
ItemCountS   = size( MTASig, 2);

printf('SampleCountS =');
disp(string(SampleCountS));
printf('ItemCountS =');
disp(string(ItemCountS));

printf('\n');

//
if ItemCount+1 <> ItemCountS then
    printf(' MTA Signal Material is not Suitable\n'),
    break;    
end



// 正規化
for j = 1: ItemCountS-1,
    for i = 1: SampleCountS,
        v( i, j) = MTASig( i, j) - Ave( 1, j);
    end;
end

for i=1:SampleCountS,
    Vt      = v( i, :),
    V       = Vt',
    SD2(i,1) = Vt * AJM * V / ItemCount;
end


subplot(3,2,2);
histplot( 30, SD2(:,1)');
xlabel("Mahalanobis Distance^2");





// マハラノビス距離と信号空間の予測対象との相関

for i=1:SampleCountS,
    RegAna(i,1) = SD2(i,1)^0.5,
    RegAna(i,2) = MTASig(i,ItemCountS);
end

Sx=0;
Sy=0;
Sxy=0;
sx=0;
sy=0;

SxZ=0;
//SyZ=0;
sxyZ=0;

for i=1:SampleCountS,
    Sx  = Sx + RegAna(i,1)^2,
    Sy  = Sy + RegAna(i,2)^2,
    Sxy = Sxy + RegAna(i,1)*RegAna(i,2),
    sx  = sx + RegAna(i,1),
    sy  = sy + RegAna(i,2);

    SxZ  = SxZ + RegAna(i,1)^2,
    //SyZ  = SyZ + RegAna(i,2)^2,
    sxyZ  = sxyZ + RegAna(i,1)*RegAna(i,2),
end

Sx  = Sx - sx^2/SampleCountS;
Sy  = Sy - sy^2/SampleCountS;
Sxy = Sxy - sx*sy/SampleCountS;

CorCoe  = Sxy/(Sx*Sy)^0.5;

Sr  = sxyZ^2/SxZ - sy^2/SampleCountS
R2  = Sr/Sy

printf('CorCoe =');
disp(string(CorCoe));

printf('sxyZ/SxZ =');
disp(string(sxyZ/SxZ));

printf('R2 =');
disp(string(R2));
printf('\n');


// マハラノビス距離と信号空間の予測対象との散布図
subplot(3,2,3);
plot( RegAna(:,1), RegAna(:,2), '.');
//plot( RegAna(:,1),Sxy/Sx*RegAna(:,1), 'k-');
plot( RegAna(:,1),sxyZ/SxZ*RegAna(:,1), 'k-');
xlabel("Mahalanobis Distance^2");
ylabel("Peak Power Demand[10^4KW]");



// 信号空間の予測対象と実測の相関
for i=1:SampleCountS,
    RegAna(i,3) = sxyZ/SxZ*RegAna(i,1),
end

PredCoe=sxyZ/SxZ;

Sx=0;
Sy=0;
Sxy=0;
sx=0;
sy=0;

SxZ=0;
//SyZ=0;
sxyZ=0;

for i=1:SampleCountS,
    Sx  = Sx + RegAna(i,3)^2,
    Sy  = Sy + RegAna(i,2)^2,
    Sxy = Sxy + RegAna(i,3)*RegAna(i,2),
    sx  = sx + RegAna(i,3),
    sy  = sy + RegAna(i,2);

    SxZ  = SxZ + RegAna(i,3)^2,
    //SyZ  = SyZ + RegAna(i,2)^2,
    sxyZ  = sxyZ + RegAna(i,3)*RegAna(i,2),
end

Sx  = Sx - sx^2/SampleCountS;
Sy  = Sy - sy^2/SampleCountS;
Sxy = Sxy - sx*sy/SampleCountS;

CorCoe  = Sxy/(Sx*Sy)^0.5;

Sr  = sxyZ^2/SxZ - sy^2/SampleCountS
R2  = Sr/Sy

printf('CorCoe =');
disp(string(CorCoe));

printf('sxyZ/SxZ =');
disp(string(sxyZ/SxZ));

printf('R2 =');
disp(string(R2));

// 信号空間の予測値と実測値の散布図
subplot(3,2,4);
plot( RegAna(:,3), RegAna(:,2), '.');
plot( RegAna(:,3),sxyZ/SxZ*RegAna(:,3), 'k-');
xlabel("Predicted PPD[10^4KW]");
ylabel("Actual PPD[10^4KW]");

printf('\n');




/* 評価対象の検証 */
printf('Enter a File Name of MTA Evaluation Material');
MTAEvaFile = input('File Name(.xls)?: ',"string");

printf('./' +MTAEvaFile+'.xls\n');

MTAEva_Sheets   = readxls('./' + MTAEvaFile + '.xls');  // EXELファイルの読み出し

EvaSheet        = MTAEva_Sheets(1);         // Sheetの抜き出し
MTAEva          = EvaSheet.value;              // 数値の取り出し

SampleCountE = size( MTAEva, 1);
ItemCountE   = size( MTAEva, 2);

printf('SampleCountE =');
disp(string(SampleCountE));
printf('ItemCountE =');
disp(string(ItemCountE));
printf('\n');

//
if ItemCount <> ItemCountE then
    printf(' MTA Evaluation Material is not Suitable\n'),
    break;    
end

// 正規化
for j = 1: ItemCountE,
    for i = 1: SampleCountE,
        w( i, j) = MTAEva( i, j) - Ave( 1, j);
    end;
end

for i=1:SampleCountE,
    Wt      = w( i, :),
    W       = Wt',
    ED2(i,1) = Wt * AJM * W / ItemCountE;
end

//予測結果
for i=1:SampleCountE,
    PredAna(i,1) = ED2(i,1)^0.5,
    PredAna(i,3) = PredCoe*PredAna(i,1),
end

//printf('PredAna =');
//disp(PredAna);
//printf('\n');

subplot(3,2,5);
plot( PredAna(:,1),PredAna(:,3), 'k-');
xlabel("Mahalanobis Distance^2");
ylabel("Predicted PPD[10^4KW]");


/* 実績の取得 */
printf('Enter a File Name of MTA Actual Data');
MTAActFile = input('File Name(.xls)?: ',"string");
MTAAct_Sheets   = readxls('./' + MTAActFile + '.xls');  // EXELファイルの読み出し
ActSheet        = MTAAct_Sheets(1);         // Sheetの抜き出し
MTAAct          = ActSheet.value;              // 数値の取り出し

SampleCountA = size( MTAEva, 1);
ItemCountA   = size( MTAEva, 2);

printf('SampleCountA =');
disp(string(SampleCountA));
printf('ItemCountA =');
disp(string(ItemCountA));
printf('\n');

if SampleCountA <> SampleCountE then
    printf(' MTA Actual Material is not Suitable\n'),
    break;    
end

PredAna(:,2) = MTAAct( :, 1);

subplot(3,2,6);

plot( PredAna(:,3), PredAna(:,2), '.');
plot( PredAna(:,3), PredAna(:,3), 'k-');
xlabel("Predicted PPD[10^4KW]");
ylabel("Actual PPD[10^4KW]");
