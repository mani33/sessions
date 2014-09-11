%{
acq.Animals (manual) # my newest table
animal_id : int unsigned # mouse or rat id - internal to database
-----
dob=Null: date # date of birth in the format: 'YYYY-MM-DD'
sex="unknown": enum('M','F','unknown') # male or female
species:enum('mouse','rat') # mouse or rat
father_id=Null: int unsigned # father 
mother_id=Null: int unsigned # mommy
genotype= "unknown": varchar(256) # genotype e.g. DAT+/-
strain= "unknown" : varchar(256) # mouse or rat strain name C57
line= "unknown": varchar(256) # genetic line the animal belongs to. e.g. DAT-Cre
source=Null : varchar(256) # from where the animals came from
notes=Null: varchar(1024) # any special note about the animal
other_id=Null: varchar(256) # any other alternative id
animals_ts=CURRENT_TIMESTAMP :  timestamp # automatically generated
%}

classdef Animals < dj.Relvar
end