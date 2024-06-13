--[[
Curseflame Ancient Asorile
Antica Fiammaledetta Asorile
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3 Level 5 "Curseflame" monsters
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	--Must be Fusion Summoned (from your Extra Deck) by shuffling the above cards you control into the Deck. (You do not use "Polymerization").
	aux.AddContactFusionProcedureGlitchy(c,0,true,SUMMON_TYPE_FUSION+SUMMON_VALUE_SELF,s.cffilter,LOCATION_MZONE,0,nil,aux.ContactFusionMaterialsToDeck)
	--summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.fuslimit)
	c:RegisterEffect(e0)
	--If this card is Fusion Summoned: You can banish 3 "Curseflame" cards from your GY; place Curseflame Counters on each face-up card on the field that has a Curseflame Counter, equal to the number of Curseflame counters currently on them.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetFunctions(
		aux.FusionSummonedCond,
		aux.BanishCost(aux.ArchetypeFilter(ARCHE_CURSEFLAME),LOCATION_GRAVE,0,3),
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e1)
	--All "Curseflame" monsters you control gain 300 ATK/DEF for each Curseflame Counter on the field, during your turn only.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(aux.TurnPlayerCond(0))
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_CURSEFLAME))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
end
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(ARCHE_CURSEFLAME) and c:IsLevel(5)
end
function s.cffilter(c)
	return s.ffilter(c) and c:IsAbleToDeckOrExtraAsCost()
end

--E0
function s.fuslimit(e,se,sp,st)
	return st==SUMMON_TYPE_FUSION+SUMMON_VALUE_SELF
end

--E1
function s.ctfilter(c)
	if not c:IsFaceup() then return false end
	local ct=c:GetCounter(COUNTER_CURSEFLAME)
	return ct>0 and c:IsCanAddCounter(COUNTER_CURSEFLAME,ct)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	local ct=g:GetSum(Card.GetCounter,COUNTER_CURSEFLAME)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,tp,COUNTER_CURSEFLAME)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_CURSEFLAME,tc:GetCounter(COUNTER_CURSEFLAME))
	end
end

--E2
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)*300
end