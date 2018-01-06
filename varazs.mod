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
var kiMegyKi{Lakosok},binary;
var maxEgyeniido;

#KORLÁTOZÁSOK

#max annyi növényt vihetek el a lelőhelyről, amennyi a lelőhelyen van
s.t. maxAmivan{h in Helyek,n in Novenyek}:
sum{l in Lakosok} kiHonnanMibolMennyitHoz[l,h,n] <= novenyMennyiseg[n,h];

#megadjuk melyik növényből mennyi kell
s.t. minNoveny{n in Novenyek}:
sum {h in Helyek,l in Lakosok} kiHonnanMibolMennyitHoz[l,h,n] >= novenykell[n];

#egy ember annyiszor megy egy helyre ahányszor kell teherbírás szerint
s.t. emberfordulo{l in Lakosok,h in Helyek}:
kiHanySzorMegy[l,h] = sum{n in Novenyek} kiHonnanMibolMennyitHoz[l,h,n] /  lakosTeherB[l];

#aki akár egyszer kimegy növényt szerdni, az nem marad védeni
s.t. kimegykisum{l in Lakosok}:
kiMegyKi[l]>= (sum{h in Helyek}kiHanySzorMegy[l,h])/1000; 
#ha nem megy ki egyik helyre se akkor a sum után 0 van ezért 1 lesz a jobb fele, ha egy a jobb fele akkor a bal is az, azaz az adott lakos véd
# ha nem nulla a kihanyszormegy akkor mindig nagyobb mint 1 és ja kevesebb mint 1000x megy ki, akkor a kimegyki az 1 re vált.
#ha meg 0 a kihaynszormegyki, akkor hiába osztom el 1000 el az is nulla marad, ezért a kimegyki 0 lesz.

#min def a faluban
s.t. minEroSzam:
sum{l in Lakosok} ((1-kiMegyKi[l]) * lakosEro[l]) >= minFaluEro;

#amit nem ismer fel, azt nem gyűjtheti be a táblázat szerint
s.t. nemIsmeriNemGyujti{l in Lakosok,h in Helyek, n in Novenyek : felismerokepesseg[l,n] = 0}:
kiHonnanMibolMennyitHoz[l,h,n] = 0;

s.t. seged{l in Lakosok}:
maxEgyeniido >= sum { h in Helyek} kiHanySzorMegy[l,h]*lelohelyTavolsag[h]*lakosIram[l]*2;

#CÉLFÜGGVÉNY  azt akarjuk, hogy a lehető leggyorsabban gyűjtsék be az anyagokat.
minimize idoKoltseg:
maxEgyeniido;


solve;

for{l in Lakosok}
{
printf "LAKOS NEVE: %s Kimegy?:%d\n",l,kiMegyKi[l];
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
printf "Lakosok   erő: %d \n",sum{l in Lakosok} ((1-kiMegyKi[l]) * lakosEro[l]);

printf "%d perc alatt teljesítik a beszerzést. \n\n\n", maxEgyeniido;

end;
