--Linky Ukiki Flowey
local cid,id=GetID()
function cid.initial_effect(c)
 --link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),2,2)
	c:EnableReviveLimit()
--ATK & DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTarget(cid.tg1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetTarget(cid.tg1)
	e2:SetValue(500)
	c:RegisterEffect(e2) 
--ATK & DEF
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTarget(cid.tg2)
	e3:SetValue(-400)
	c:RegisterEffect(e3) 
local e4=e3:Clone()
e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetTarget(cid.tg2)
	e4:SetValue(-400)
	c:RegisterEffect(e4) 
 
 local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,id)
	e5:SetCondition(cid.condition)
	e5:SetCost(cid.cost)
	e5:SetTarget(cid.target)
	e5:SetOperation(cid.operation)
	c:RegisterEffect(e5)  
end
function cid.tg1(e,c)
	return ( c:IsSetCard(0x37b) or c:IsSetCard(0x57b)) or e:GetHandler()==c 
end
function cid.tg2(e,c)
	return not ( c:IsSetCard(0x37b) or c:IsSetCard(0x57b))  and not e:GetHandler()==c 
end

function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)~=0 and Duel.GetCurrentPhase()==PHASE_END
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN_MONSTER,2000,0,3,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,id+i)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
