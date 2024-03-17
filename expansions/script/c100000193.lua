--[[
Prized Jewel of the Pack
Pregiato Gioiello del Branco
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_JEWEL)
	--[[If you control no monsters, or if you control a Beast monster, you can Special Summon this card (from your hand).]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--[[Each time another Beast monster(s) is Normal or Special Summoned to your field, place 1 Jewel Counter on this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[Increase this card's Level by the number of Jewel Counters on it.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.lvcon)
	e3:SetValue(s.lvval)
	c:RegisterEffect(e3)
	--[[You can discard 1 card; add 1 EARTH Beast monster from your Deck or GY to your hand with an equal or lower Level than this card on the field.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetCost(aux.DiscardCost())
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
--E1
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0 or Duel.IsExists(false,aux.FaceupFilter(Card.IsRace,RACE_BEAST),tp,LOCATION_MZONE,0,1,nil)) 
end

--E2
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.ctop(e)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_JEWEL,1) then
		c:AddCounter(COUNTER_JEWEL,1)
	end
end

--E3
function s.lvcon(e)
	return e:GetHandler():HasCounter(COUNTER_JEWEL)
end
function s.lvval(e,c)
	return c:GetCounter(COUNTER_JEWEL)
end

--E4
function s.thfilter(c,lv)
	return c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:HasLevel() and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,c:GetLevel()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and c:IsFaceup() and c:HasLevel()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,c:GetLevel())
	if #g>0 then
		Duel.Search(g,tp)
	end
end