--[[
Sword Saint Sovereign of the Solemn Star Sea
Santo Sovrano delle Spade del Solenne Subisso di Stelle
Card Author: ohmyhowswaggy
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,5,s.TLcon,aux.FilterBoolFunction(Card.IsMonster,TYPE_EFFECT))
	c:EnableReviveLimit()
	--[[If this card is Time Leap Summoned: You can target any number of Equip Spells in your GY; equip them to this card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.TimeleapSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--(Quick Effect): You can send to the GY, 1 Equip Spell from your hand, OR 1 Equip Card from your hand or field, then target 1 card your opponent controls; destroy it.
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:HOPT(nil,7)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.TLcon(e,c,tp)
	return Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil,TYPE_EQUIP)>=7
end

--E1
function s.filter(c,tp,ec)
	return c:IsSpell(TYPE_EQUIP) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and c:CheckEquipTarget(ec) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp,c) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp,c) end
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,math.min(ft,ct),nil,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetTargetCards()
	if ft<#g then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToChain() then return end
	local tc=g:GetFirst()
	while tc do
		Duel.Equip(tp,tc,c,true,true)
		tc=g:GetNext()
	end
	Duel.EquipComplete()
end

--E2
function s.cfilter(c)
	if not c:IsAbleToGraveAsCost() then return false end
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSpell(TYPE_EQUIP)
	else
		return c:GetEquipTarget()
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_SZONE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end