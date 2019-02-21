
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

// 正規化
for j = 1: ItemCount,
    for i = 1: SampleCount,
        u( i, j) = MTMate( i, j) - Ave( 1, j);
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

printf('AJM =');
disp(AJM);
printf('\n');


for i=1:SampleCount,
    Ut      = u( i, :),
    U       = Ut',
    D2(i,1) = Ut * AJM * U / ItemCount;
end


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


// 正規化
for j = 1: ItemCount,
    for i = 1: SampleCount,
        v( i, j) = MTSig( i, j) - Ave( 1, j);
    end;
end

for i=1:SampleCount,
    Vt      = v( i, :),
    V       = Vt',
    SD2(i,1) = Vt * AJM * V / ItemCount;
end

//clf;    // clear
scf;    // add

subplot(2,2,1);
plot2d(D2);
subplot(2,2,2);
histplot( 30, D2(:,1)');

subplot(2,2,3);
plot2d(SD2);
subplot(2,2,4);
histplot( 30, SD2(:,1)');
