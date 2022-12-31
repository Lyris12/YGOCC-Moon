--Night Assault - Flip Turn
--Script by APurpleApple
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.accon)
	e1:SetTarget(s.actar)
	e1:SetOperation(s.acop)
	e1:SetCountLimit(1,56132161)
	c:RegisterEffect(e1)
	--Grave
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.gytar)
	e2:SetOperation(s.gyop)
	e2:SetCountLimit(1,56132161)
	c:RegisterEffect(e2)
end
function s.acfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsSetCard(0x8af)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.acfilter,1,nil,tp)
end
function s.actarfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8af)
end
function s.actar(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actarfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.actarfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.gytar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.actarfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) end
	local tg=Duel.SelectTarget(tp,s.actarfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil,1,nil,nil)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstTarget()
	Duel.SendtoHand(tg,tp,REASON_EFFECT)
end