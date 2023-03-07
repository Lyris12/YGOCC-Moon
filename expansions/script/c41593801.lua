--created by LeonDuvall, coded by Lyris
--Skypiercer BF-110
local s,id,o=GetID()
function s.initial_effect(c)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e, te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) end)
	e1:SetCondition(function() return c:IsStatus(STATUS_SPSUMMON_TURN) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsSetCard(0x3bb) and c:IsDiscardable()
end
function s.spcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, c)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
	Duel.DiscardHand(tp, s.cfilter, 1, 1, REASON_DISCARD+REASON_COST, c)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.DiscardHand(tp, s.cfilter, 1, 1, REASON_DISCARD+REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0x3bb) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3bb)
end
function s.thop(e, tp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	Duel.SendtoHand(g, nil, REASON_EFFECT)
	Duel.ConfirmCards(1-tp, g)
	local tc = g:GetFirst()
	if tc and tc:IsLocation(LOCATION_HAND) and Duel.IsExistingMatchingCard(s.dfilter, tp, LOCATION_MZONE, 0, 1, e:GetHandler()) then
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end
