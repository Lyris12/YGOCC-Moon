--Deep Dive
--Script by APurpleApple
local s = c56132087
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE + CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56132087)
	e1:SetCost(s.cost)
	e1:SetOperation(s.topdeck)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,56132088)
	e2:SetCost(s.cost2)
	e2:SetCondition(aux.exccon)
	e2:SetOperation(s.action2)
	c:RegisterEffect(e2)
end

function s.costFilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable() and c:IsRace(RACE_SEASERPENT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.costFilter, tp, LOCATION_HAND, 0,1,nil) end
	Duel.DiscardHand(tp,s.costFilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.topdeck(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,1)
	t = Duel.GetDecktopGroup(tp,1):GetFirst()
	if t and t:IsAbleToGrave() and Duel.SelectOption(tp,1192,1190)==0
	then
		Duel.Remove(t, POS_FACEDOWN, REASON_EFFECT)
	else
		Duel.SendtoHand(t,tp,REASON_EFFECT)
	end
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(), POS_FACEDOWN, LOCATION_REMOVED)
end
function s.action2(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(Duel.GetDecktopGroup(tp,3))
end