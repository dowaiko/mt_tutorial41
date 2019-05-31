
clear;

printf('\n');

printf('************** t_1.sci Start! ****************');
printf('\n');

printf('Enter a File Name of UNIT SPACE Material');
UnitSpaceFile = input('File Name(.xls)?: ',"string");

printf('./' +UnitSpaceFile+'.xls\n');

T_Mat_Sheets   = readxls('./' + UnitSpaceFile + '.xls');  // EXELファイルの読み出し

Sheet   = T_Mat_Sheets(1);         // Sheetの抜き出し
TMate   = Sheet.value;              // 数値の取り出し

SampleCount = size( TMate, 1);
ItemCount   = size( TMate, 2);

printf('SampleCount =');
disp(string(SampleCount));
printf('ItemCount =');
disp(string(ItemCount));
printf('\n');


// 予備計算
for j = 1: ItemCount,
    x1( 1, j) = 0, //行列の初期化
    //x2( 1, j) = 0, //行列の初期化
    for i = 1: SampleCount,
        x1( 1, j) = x1( 1, j) + TMate( i, j),      // 1乗の総和を求める
        //x2( 1, j) = x2( 1, j) + MTAMate( i, j)^2;    // 2乗の総和を求める
    end,
end


// 算術平均
for j = 1: ItemCount,
    m( 1, j) = x1( 1, j) / SampleCount;
end


printf('m =');
disp(string(m));
printf('\n');



/* 信号空間の検証 */

printf('Enter a File Name of T Signal Material');
TSigFile = input('File Name(.xls)?: ',"string");

printf('./' +TSigFile+'.xls\n');

TSig_Sheets   = readxls('./' + TSigFile + '.xls');  // EXELファイルの読み出し

SigSheet    = TSig_Sheets(1);         // Sheetの抜き出し
TSig        = SigSheet.value;              // 数値の取り出し

SampleCountS = size( TSig, 1);
ItemCountS   = size( TSig, 2);

printf('SampleCountS =');
disp(string(SampleCountS));
printf('ItemCountS =');
disp(string(ItemCountS));

printf('\n');

//
if ItemCount <> ItemCountS then
    printf(' T Signal Material is not Suitable\n'),
    break;    
end


// 正規化
for j = 1: ItemCountS,
    for i = 1: SampleCountS,
        u( i, j) = TSig( i, j) - m( 1, j);
    end;
end

//printf('u =');
//disp(string(u));

//printf('\n');

r=0;
for i = 1: SampleCountS,
        r = r + u( i, ItemCountS)^2;
end


L=zeros(1,ItemCountS-1);
St=zeros(1,ItemCountS-1);
Beta=zeros(1,ItemCountS-1);
Sb=zeros(1,ItemCountS-1);
Ve=zeros(1,ItemCountS-1);
Eta=zeros(1,ItemCountS-1);

for j = 1: ItemCountS-1,
    for i = 1: SampleCountS,
        L( 1, j) = L( 1, j) + u( i, ItemCountS)*u(i,j),
        St( 1, j) = St( 1, j) + u(i,j)^2,
    end,
    Beta( 1, j) = L( 1, j) / r,
    Sb( 1, j)   = Beta( 1, j)*L( 1, j),
    Ve( 1, j)   = (St( 1, j)-Sb( 1, j))/(SampleCountS-1),
    Eta( 1, j)  = (Sb( 1, j)-Ve( 1, j))/(Ve( 1, j)*r),
    if Eta( 1, j)<0 then    Eta( 1, j)=0; end;
end



//printf('Beta =');
//disp(string(Beta));
//printf('Eta =');
//disp(string(Eta));

printf('\n');


/* 評価対象の検証 */
printf('Enter a File Name of T Evaluation Material');
TEvaFile = input('File Name(.xls)?: ',"string");

printf('./' +TEvaFile+'.xls\n');

TEva_Sheets   = readxls('./' + TEvaFile + '.xls');  // EXELファイルの読み出し

EvaSheet    = TEva_Sheets(1);         // Sheetの抜き出し
TEva        = EvaSheet.value;              // 数値の取り出し

SampleCountE = size( TEva, 1);
ItemCountE   = size( TEva, 2);

printf('SampleCountE =');
disp(string(SampleCountE));
printf('ItemCountE =');
disp(string(ItemCountE));
printf('\n');

//
if ItemCount <> ItemCountE then
    printf(' T Evaluation Material is not Suitable\n'),
    break;    
end

// 正規化
for j = 1: ItemCountE-1,
    for i = 1: SampleCountE,
        w( i, j) = TEva( i, j) - m( 1, j);
    end;
end

// 予測
Mn  = zeros(SampleCountE,1);
Md  = zeros(SampleCountE,1);

for i = 1: SampleCountE,
    for j = 1: ItemCountE-1,
        Mn( i, 1)   = Mn( i, 1) + Eta( 1, j) * w( i, j) / Beta( 1, j),
        Md( i, 1)   = Md( i, 1) + Eta( 1, j);
    end,
    M( i, 1)    = Mn( i, 1)  / Md( i, 1),
    Z( i, 1)    = M( i, 1) + m( 1, ItemCount);
end

clf;    // clear
//scf;    // add

plot( Z( :, 1), TEva( :, ItemCountE),   '.');
plot( Z( :, 1), Z( :, 1),               'k-');
a=get("current_axes");
a.data_bounds=[3000,3000;6000,6000]
