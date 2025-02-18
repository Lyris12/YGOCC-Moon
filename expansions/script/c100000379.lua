--[[
Curseflame Ancient Loras
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,100000377)
	aux.RegisterCountersBeforeLeavingField(c,COUNTER_CURSEFLAME,LOCATION_MZONE,nil,id)
	--[[If this card is Ritual Summoned, or if a card(s) with a Curseflame Counter(s) on them leaves the field while you control this monster: You can banish 1 card from your GY for every face-up card
	on the field that does not have a Curseflame Counter(s) on them; place 3 Curseflame Counters on each face-up card on the field without Curseflame Counters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.RitualSummonedCond,s.ctcost,s.cttg,s.ctop)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e1a:SetCode(EVENT_LEAVE_FIELD)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e1a:SetCondition(aux.AlreadyInRangeEventCondition(aux.FilterBoolFunction(Card.HasFlagEffect,id)))
	c:RegisterEffect(e1a)
	--[[This card can make an additional attack on monsters for every 3 Curseflame Counters on the field, also if it attacks a Defense Position monster, inflict piercing battle damage to your
	opponent.]]
	c:SetMaximumNumberOfAttacksOnMonsters(s.atkval)
	c:Pierces()
	--[[If this card battles an opponent's monster while there are 30 or more Curseflame Counters on the field, neither monster is destroyed by that battle.]]
	aux.AddIllusionBattleEffect(c,s.indcon)
end
--E1
function s.noctfilter(c)
	return c:IsFaceup() and not c:HasCounter(COUNTER_CURSEFLAME)
end
function s.ctfilter(c)
	return s.noctfilter(c) and c:IsCanAddCounter(COUNTER_CURSEFLAME,3)
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.noctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then
		return ct>0 and Duel.IsExists(false,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,ct,nil)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,ct,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,3,tp,COUNTER_CURSEFLAME)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_CURSEFLAME,3)
	end
end

--E2
function s.atkval(e,c)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	if ct<3 then return 0 end
	return ct//3
end

--E3
function s.indcon(e)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	return ct>=30 and aux.bdocon(e)
end