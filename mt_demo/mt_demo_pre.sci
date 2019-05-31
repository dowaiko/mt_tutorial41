clear;

printf('\n');
printf('************** mt_demo pre ****************');
printf('\n');

//printf('Enter a File Name of Material\n');
//UnitSpaceFile = input('File Name(.xls)?: ',"string");

//printf('./' +UnitSpaceFile+'.xls\n');
printf('Loading <./mt_demo_pre.xls>\n');

MT_Mat_Sheets   = readxls('./mt_demo_pre.xls');  // EXELファイルの読み出し

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
//これでもいけそう。要、あとで検証
//Ave = x1( 1, ;) / SampleCount;

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


printf("D(A) = ");
disp(string((D2(40,1)*ItemCount)^0.5));
printf("\n");
printf("D2(A) = ");
disp(string(D2(40,1)*ItemCount));
printf("\n");

printf("D(B) = ");
disp(string((D2(30,1)*ItemCount)^0.5));
printf("\n");
printf("D2(B) = ");
disp(string(D2(30,1)*ItemCount));
printf("\n");

printf("D2min = ");
disp(string(min(D2*ItemCount)));
printf("\n");

printf("D2max = ");
disp(string(max(D2*ItemCount)));
printf("\n");
clf;    // clear
//scf;    // add

subplot( 3, 1, 1);
plot( MTMate(:,1), MTMate(:,2), '.');
plot( MTMate(40,1), MTMate(40,2), 'g.');
plot( MTMate(30,1), MTMate(30,2), 'r.');
a=get("current_axes");
a.data_bounds=[0,0;100,100]
xlabel("Mathematics");
ylabel("Science");

[ p, q] = reglin( MTMate(:,1)', MTMate(:,2)');
kaiki   = p * MTMate(:,1) + q;
plot( MTMate(:,1), kaiki, 'k--');



subplot( 3, 1, 2);
plot( (D2*ItemCount)^0.5, '.');
plot( 40, (D2(40,1)*ItemCount)^0.5, 'g.');
plot( 30, (D2(30,1)*ItemCount)^0.5, 'r.');
xlabel("Student No,");
ylabel("Mahalanobis Distance");



subplot( 3, 1, 3);
histplot( 0:1:15, (D2(:,1)*ItemCount)');

for x = 1: 15,

    Total( x, 1)    = cdfchi( "PQ", x, ItemCount);
    
    if x==1 then
        Dist( x, 1) =  Total( x, 1);
    else 
        Dist( x, 1) =  Total( x, 1) - Total( x-1, 1); 
    end,   

end


plot( Dist, '.');
xlabel("Mahalanobis Distance^2");
