set Lakosok;
set Novenyek;
set Helyek;

param lakosTeherB{Lakosok};
param lelohelyTavolsag{Helyek};
param novenyMennyiseg{Novenyek,Helyek};
param novenykell{Novenyek};
param lakosIram{Lakosok};
param lakosEro{Lakosok};
param minFaluEro;
param felismerokepesseg{Lakosok,Novenyek};

#VÁLTOZÓK, DÖNTÉSEK
var kiHonnanMibolMennyitHoz{Lakosok,Helyek,Novenyek}, >=0;
var kiHanySzorMegy{Lakosok,Helyek},integer,>=0; # mert lehet többször fordul valaki.
var kiMaradVedeni{Lakosok},binary;

#KORLÁTOZÁSOK

#max annyi növényt vihetek el a lelőhelyről, amennyi a lelőhelyen van
s.t. maxAmivan{h in Helyek,n in Novenyek}:
sum{l in Lakosok} kiHonnanMibolMennyitHoz[l,h,n] <= novenyMennyiseg[n,h];

#megadjuk melyik növényből mennyi kell
s.t. minNoveny{n in Novenyek}:
sum {h in Helyek,l in Lakosok} kiHonnanMibolMennyitHoz[l,h,n] >= novenykell[n];

#egy ember annyiszor megy egy helyre ahányszor kell teherbírás szerint
s.t. emberfordulo{l in Lakosok,h in Helyek}:
kiHanySzorMegy[l,h] >= sum{n in Novenyek} kiHonnanMibolMennyitHoz[l,h,n] /  lakosTeherB[l];

#aki akár egyszer kimegy növényt szerdni, az nem marad védeni
s.t. kimegykisum{l in Lakosok}:
(1- sum{h in Helyek}kiHanySzorMegy[l,h])<= kiMaradVedeni[l];

#min def a faluban
s.t. minEroSzam:
sum{l in Lakosok} kiMaradVedeni[l] * lakosEro[l] <= minFaluEro;

#amit nem ismer fel, azt nem gyűjtheti be a táblázat szerint
s.t. nemIsmeriNemGyujti{l in Lakosok,h in Helyek, n in Novenyek : felismerokepesseg[l,n] = 0}:
kiHonnanMibolMennyitHoz[l,h,n] = 0;

#CÉLFÜGGVÉNY  azt akarjuk, hogy a lehető leggyorsabban gyűjtsék be az anyagokat.
minimize idoKoltseg:
sum {l in Lakosok, h in Helyek}  kiHanySzorMegy[l,h]*lelohelyTavolsag[h]*lakosIram[l]*2;


solve;

for{l in Lakosok}
{
printf "LAKOS NEVE: %s Véd?:%d\n",l,kiMaradVedeni[l];
	for{h in Helyek : kiHanySzorMegy[l,h] >=1}
	{
		printf "\tHELY NEVE: %sre %dx megy a következő növényekért:\n",h,kiHanySzorMegy[l,h];
		
		for{n in Novenyek : kiHonnanMibolMennyitHoz[l,h,n] >=1}
		{
			printf "\t\t%s %d \n",n, kiHonnanMibolMennyitHoz[l,h,n];
		}
	}
	printf "\n";
}

printf "Szükséges erő: %d \n",minFaluEro;    
printf "Lakosok   erő: %d \n",sum{l in Lakosok} kiMaradVedeni[l] * lakosEro[l];

printf "%d perc alatt teljesítik a beszerzést. \n\n\n", (sum {l in Lakosok, h in Helyek}  kiHanySzorMegy[l,h]*lelohelyTavolsag[h]/lakosIram[l]);


end;
