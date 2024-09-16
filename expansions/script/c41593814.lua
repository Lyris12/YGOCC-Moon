--created by LeonDuvall, coded by Lyris
--Skypiercer Ingenieurkorps
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.operation)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsSetCard(0x3bb) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.target(e,tp,_,_,_,_,_,_,chk)
	local chkf=Duel.IsEnvironment(41593810,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and (not chkf
		or Duel.IsPlayerCanDraw(tp,1)) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if chkf then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) end
end
function s.activate(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)<1 or not (g:GetFirst():IsLocation(LOCATION_HAND) and Duel.IsEnvironment(41593810,tp)) then return end
	Duel.BreakEffect()
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3bb)
end
function s.thcon(e,tp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsEnvironment(41593810,tp)
end
function s.gfilter(c)
	return c:IsSetCard(0x3bb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.gfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.SelectTarget(tp,s.gfilter,tp,LOCATION_GRAVE,0,2,2,nil),2,0,0)
end
function s.thop(e,tp)
	Duel.SendtoHand(Duel.GetTargetsRelateToChain(),nil,REASON_EFFECT)
end
function s.rfilter(c,tp)
	return s.cfilter(c) and c:IsControler(tp) and c:IsOnField() and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.rfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.operation(e)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_RETURN)
end
function s.repval(e,c)
	return s.rfilter(c,e:GetHandlerPlayer())
end
