--[[
Voidictator Servant - Rune Weaver
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--This card cannot be used as a material for the Summon of a monster from the Extra Deck while it is on the field.
	aux.CannotBeEDMaterial(c,nil,LOCATION_ONFIELD,true)
	--[[If this card is Normal or Special Summoned: You can target 1 "Voidictator" Spell/Trap in your GY and 1 from your banishment; banish the first target, and if you do, add the second target to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is banished because of a "Voidictator" card you own: You can banish 1 "Voidictator" card from your GY; banish 1 Spell/Trap your opponent controls, face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.BanishCost(aux.ArchetypeFilter(ARCHE_VOIDICTATOR),LOCATION_GRAVE))
	e2:SetSendtoFunctions(LOCATION_REMOVED,nil,Card.IsSpellTrapOnField,0,LOCATION_ONFIELD,1,1,nil,POS_FACEDOWN)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
--E1
function s.filter(c,f)
	return c:IsFaceupEx() and c:IsST() and c:IsSetCard(ARCHE_VOIDICTATOR) and (not f or f(c))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,0,1,nil,Card.IsAbleToRemove) and Duel.IsExists(true,s.filter,tp,LOCATION_REMOVED,0,1,nil,Card.IsAbleToHand) end
	local g1=Duel.Select(HINTMSG_REMOVE,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,Card.IsAbleToRemove)
	local g2=Duel.Select(HINTMSG_ATOHAND,true,tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,Card.IsAbleToHand)
	local eid=e:GetFieldID()
	g1:GetFirst():RegisterFlagEffect(id,RESET_CHAIN,0,1,eid)
	Duel.SetTargetParam(eid)
	Duel.SetCardOperationInfo(g1,CATEGORY_REMOVE)
	Duel.SetCardOperationInfo(g2,CATEGORY_TOHAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g==0 then return end
	local tc1=g:Filter(Card.HasFlagEffectLabel,nil,id,Duel.GetTargetParam()):GetFirst()
	if not tc1 or not s.filter(tc1) then return end
	g:RemoveCard(tc1)
	local tc2=g:GetFirst()
	if Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)>0 and tc2 and s.filter(tc2) then
		Duel.Search(tc2)
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end