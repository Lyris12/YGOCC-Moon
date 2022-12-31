--Abella, Reaper of Steam
--Scripted by NatalieWINS
function c130734001.initial_effect(c)
	--Must be Fusion Summoned.
	c:EnableReviveLimit()
	--1 FIRE Zombie monster + 1 WATER Machine monster
	aux.AddFusionProcFun2(c,c130734001.material1,c130734001.material2,true)
	--Cannot be destroyed by battle.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--At the start of each Battle Phase, (Special Summon as many "Ghoulem Token(s)" (Machine/FIRE/Level 1/ATK 0/DEF 100) as possible with the following effects.)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c130734001.e2operation)
	c:RegisterEffect(e2)
end

--

function c130734001.material1(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function c130734001.material2(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_WATER)
end

function c130734001.e2operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,130734002,0,16401,0,100,1,RACE_MACHINE,ATTRIBUTE_FIRE) then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	for i=1,ft do
		local token=Duel.CreateToken(tp,130734002)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		--● Any battle damage you take from battles involving this card inflicts equal effect damage to your opponent.
		local e1=Effect.CreateEffect(token)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DAMAGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(c130734001.damcon)
		e1:SetOperation(c130734001.e2tokene1operation)
		token:RegisterEffect(e1)
		--At the end of each Battle Phase, destroy this card.
		local e2=Effect.CreateEffect(token)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCategory(CATEGORY_DESTROY)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		e2:SetTarget(c130734001.destarget)
		e2:SetOperation(c130734001.desoperation)
		token:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end

function c130734001.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==tp
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end

function c130734001.e2tokene1operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end

function c130734001.destarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c130734001.desoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end