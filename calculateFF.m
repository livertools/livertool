function [FF, rhoW, rhoF, Rsq]  = calculateFF(Signal,Techoes)
% inputs de calculo: S(te)[],  TE[], Cn[], fppmn[], B0, gammaH
% outputs: FF, rhoW, rhoF, Rsq


%dixon
rhoW = (S(2) + S(1)) / 2;
rhoF = (S(2) - S(1)) / 2;
Rsq = 1;


%triple echo
deltaTE = Techoes(2)-Techoes(1);
%if S = 3 pt
    T2star = deltaTE*log(S(1) / S(3));
%else if S >= 4 pt

    T2star = deltaTE*log(S(2) / S(4));    
%end
rhoW = (S(2)*exp(Techoes(2)/T2star) + S(1)*exp(Techoes(1)/T2star)) / 2;
rhoF = (S(2)*exp(Techoes(2)/T2star) - S(1)*exp(Techoes(1)/T2star)) / 2;


%FF
FF = rhoF / (rhoW + rhoF);
end
