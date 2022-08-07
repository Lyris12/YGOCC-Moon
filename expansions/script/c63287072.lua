--Anello delle Dee Acquatiche
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(700)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_AQUA)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	return ec and c:IsAbleToGrave() and ec:IsAbleToGrave() and rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev) 
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	if Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) and Duel.SendtoGrave(ec,REASON_EFFECT)>0 and ec:IsLocation(LOCATION_GRAVE) and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.BreakEffect()
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end