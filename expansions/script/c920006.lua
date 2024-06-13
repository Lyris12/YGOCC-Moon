--[[
Curseflame Cleave
Fendente Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--Destroy all face-up cards on the field with a Curseflame Counter, except "Curseflame" cards you control, then, if you control a face-up "Curseflame" monster that began the Duel in the Extra Deck, inflict 300 damage to your opponent for each card that was destroyed by this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--If this card is in your GY, except the turn it was sent there: You can target 1 "Curseflame" monster you control; return it to the hand, and if you do, Set this card, but banish it when it leaves the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		aux.exccon,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c)
	return c:HasCounter(COUNTER_CURSEFLAME) and not c:IsSetCard(ARCHE_CURSEFLAME)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CURSEFLAME) and c:IsOriginalType(TYPE_EXTRA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):GetCount()
		if ct>0 and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			local p=Duel.GetTargetPlayer()
			Duel.BreakEffect()
			Duel.Damage(p,ct*300,REASON_EFFECT)
		end
	end
end

--E2
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CURSEFLAME) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return c:IsSSetable() and Duel.IsExists(true,s.thfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_RTOHAND,true,tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
	Duel.SetCardOperationInfo(c,CATEGORY_LEAVE_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SearchAndCheck(tc) then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsSSetable() then
			Duel.SSetAndRedirect(tp,c,e)
		end
	end
end