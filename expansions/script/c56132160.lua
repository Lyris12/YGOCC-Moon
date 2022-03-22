--Night Assault - Operation Start
--Script by APurpleApple
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.star)
	e1:SetOperation(s.sop)
	e1:SetCountLimit(1,56132160)
	c:RegisterEffect(e1)
	--gy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytar)
	e2:SetOperation(s.gyop)
	e2:SetCountLimit(1,56132160)
	c:RegisterEffect(e2)
end
function s.sfilter(c)
	return c:IsSetCard(0x8af) and c:IsType(TYPE_MONSTER)
end
function s.star(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter, tp, LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil,1,nil,nil)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(tg,tp,REASON_EFFECT)
end
function s.gyfilter(c)
	return c:IsSetCard(0x8af) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.gytar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) end
	local tg=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil,1,nil,nil)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	Duel.SendtoHand(tg,tp,REASON_EFFECT)
end