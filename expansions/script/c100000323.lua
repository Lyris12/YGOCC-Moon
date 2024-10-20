--[[
Number C204: Invernal of the Million Blades
Numero C204: Invernale del Milione di Lame
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3+ Level 7 DARK monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),7,3,nil,nil,99)
	--[[If this card is Xyz Summoned: You can banish cards your opponent controls, face-down, up to the number of materials attached to this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[This card gains 1000 ATK/DEF for each material attached to it, also if it has "Number 204: Invernal of the Thousand Blades" as a material,
	it can make a number of attacks on monsters during each Battle Phase, up to the number of materials attached to it.]]
	c:UpdateATKDEF(s.atkval,nil,nil,c,LOCATION_MZONE)
	c:SetMaximumNumberOfAttacksOnMonsters(s.xatkval,nil,c,s.xatkcon)
	--[[If this card would be destroyed by battle or by a card effect, you can detach 1 material from it instead.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
end
aux.xyz_number[id]=204

--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,tp,POS_FACEDOWN)
	if chk==0 then
		return c:GetOverlayCount()>0 and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local ct=c:GetOverlayCount()
		if ct==0 then return end
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,ct,nil,POS_FACEDOWN)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

--E2
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
function s.xatkcon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,id-1)
end
function s.xatkval(e,c)
	return c:GetOverlayCount()-1
end

--E3
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end