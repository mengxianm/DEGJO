%% GOLDEN JACKAL OPTIMIZATION ALGORITHM %% 
%___________________________________________________________________%      
%  Developed in MATLAB R2018a                                       
%  Authors: Nitish Chopra and Muhammad Mohsin Ansari
%  Programmer: Nitish Chopra                            

%   Main paper: Chopra, Nitish, and Muhammad Mohsin Ansari. "Golden Jackal Optimization: A
%              Novel Nature-Inspired Optimizer for Engineering Applications." 
%              Expert Systems with Applications (2022): 116924. 
%
%               DOI: https://doi.org/10.1016/j.eswa.2022.116924             
%___________________________________________________________________%
function [Male_Jackal_score,Male_Jackal_pos,Convergence_curve]=DEGJO(SearchAgents_no,Max_iter,lb,ub,dim,fobj)

%% initialize Golden jackal pair
Male_Jackal_pos=zeros(1,dim);
Male_Jackal_score=inf; 
Female_Jackal_pos=zeros(1,dim);  
Female_Jackal_score=inf; 

%% Initialize the positions of search agents
Positions=initialization(SearchAgents_no,dim,ub,lb);

Convergence_curve=zeros(1,Max_iter);

l=0;% Loop counter

% Main loop
while l<Max_iter
        for i=1:size(Positions,1)  

           % boundary checking
            Flag4ub=Positions(i,:)>ub;
            Flag4lb=Positions(i,:)<lb;
            Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;               

            % Calculate objective function for each search agent
            fitness=fobj(Positions(i,:));

            % Update Male Jackal 
            if fitness<Male_Jackal_score 
                Male_Jackal_score=fitness; 
                Male_Jackal_pos=Positions(i,:);
            end  
             if fitness>Male_Jackal_score && fitness<Female_Jackal_score 
                Female_Jackal_score=fitness; 
                Female_Jackal_pos=Positions(i,:);
            end
        end
    
%          E1=exp(-l/Max_iter);
          E1=1.5*(1-sqrt(l/Max_iter));
%       E1=1.5*(1-(l/Max_iter));
       RL=0.05*levy(SearchAgents_no,dim,1.5);
     
    for i=1:size(Positions,1)
        for j=1:size(Positions,2)     
           theta=360*rand();            
           r1=rand(); % r1 is a random number in [0,1]
           E0=2*r1-1;            
           E=E1*E0; % Evading energy
            
             if abs(E)<1
              %% EXPLOITATION
              
                D_male_jackal=abs((RL(i,j)*Male_Jackal_pos(j)-Positions(i,j))); 
                Male_Positions(i,j)=(Male_Jackal_pos(j)-E*D_male_jackal)*cos(theta*pi/180);
                D_female_jackal=abs((RL(i,j)*Female_Jackal_pos(j)-Positions(i,j))); 
                Female_Positions(i,j)=(Female_Jackal_pos(j)-E*D_female_jackal)*cos(theta*pi/180);
                
             else
              %% EXPLORATION
                D_male_jackal=abs( (Male_Jackal_pos(j)- RL(i,j)*Positions(i,j)));
                Male_Positions(i,j)=Male_Jackal_pos(j)-E*D_male_jackal;
                D_female_jackal=abs( (Female_Jackal_pos(j)- RL(i,j)*Positions(i,j)));
                Female_Positions(i,j)=Female_Jackal_pos(j)-E*D_female_jackal;
             end
            Positions(i,j)=(Male_Positions(i,j)+Female_Positions(i,j))/2;
             
        end
    end
     [Positions,Male_Jackal_score,Male_Jackal_pos]=DE(Positions,Male_Jackal_score,Male_Jackal_pos,lb,ub,fobj); 
    
    l=l+1;    
        
    Convergence_curve(l)=Male_Jackal_score;
end
end


function [Positions,Leader_score,Leader_pos]=DE(Positions,Leader_score,Leader_pos,lb,ub,fobj)
F=0.5;
CR=0.9; 
DEMax_iter=5;
DEPositions=zeros(size(Positions));
t=0;% Loop counter
while t<DEMax_iter
    for i=1:size(Positions,1)           
            kkk=randperm(size(Positions,1));
            kkk(i==kkk)=[];
            jrand=randi(size(Positions,2));  
            for j=1:size(Positions,2)        
                  if (rand<=CR)||(jrand==j)
                   DEPositions(i,j)=Positions(kkk(1),j)+F*(Positions(kkk(2),j)-Positions(kkk(3),j));
%                  DEPositions(i,j)=Leader_pos(j)+F*(Positions(kkk(1),j)-Positions(kkk(2),j));
%                  DEPositions(i,j)=Leader_pos(j)+F*(Positions(kkk(1),j)-Positions(i,j))+F*(Positions(kkk(2),j)-Positions(kkk(3),j));
                  else
                   DEPositions(i,j)=Positions(i,j);             
                  end
            end           
            % Return back the search agents that go beyond the boundaries of the search space       
             Flag4ub=DEPositions(i,:)>ub; Flag4lb=DEPositions(i,:)<lb;             
             DEPositions(i,:)=(DEPositions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;        
             if fobj(DEPositions(i,:))<fobj(Positions(i,:))
                   Positions(i,:)=DEPositions(i,:);    
                   if fobj(Positions(i,:))<Leader_score
                        Leader_score=fobj(Positions(i,:));
                        Leader_pos=Positions(i,:);
                   end 
             end               
    end     
t=t+1; 
end
end

function [z] = levy(n,m,beta)

    num = gamma(1+beta)*sin(pi*beta/2); % used for Numerator 
    
    den = gamma((1+beta)/2)*beta*2^((beta-1)/2); % used for Denominator

    sigma_u = (num/den)^(1/beta);% Standard deviation

    u = random('Normal',0,sigma_u,n,m); 
    
    v = random('Normal',0,1,n,m);

    z =u./(abs(v).^(1/beta));
  
  end