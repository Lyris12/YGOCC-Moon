--Cell DE.V.Asion
function c212170.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c212170.cost)
	e1:SetTarget(c212170.target)
	e1:SetCountLimit(1,212170)
	e1:SetOperation(c212170.activate)
	c:RegisterEffect(e1)
end
function c212170.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_FAIRY) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_FAIRY)
	Duel.Release(g,REASON_COST)
end
function c212170.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,212100,0x258,0x4011,800,800,1,RACE_FAIRY,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function c212170.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,212100,0x258,0x4011,800,800,1,RACE_FAIRY,ATTRIBUTE_DARK) then
		for i=1,2 do
			local token=Duel.CreateToken(tp,212100)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end
